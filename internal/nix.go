package internal

import (
	"bytes"
	"encoding/json"
	"fmt"
	"regexp"
	"strings"
	"time"
)

var PrefetchTimeout = 10 * time.Minute

var SummarizeTimeout = 45 * time.Minute

type PrefetchResult struct {
	Hash string `json:"hash"`
}

func PrefetchHash(url string) (string, error) {
	var stdout bytes.Buffer
	var stderr bytes.Buffer
	if err := RunCommand("", PrefetchTimeout, &stdout, &stderr, "nix", "store", "prefetch-file", "--json", url); err != nil {
		return "", fmt.Errorf("prefetch failed: %w\nstdout:\n%s\nstderr:\n%s", err, stdout.String(), stderr.String())
	}
	var res PrefetchResult
	if err := json.Unmarshal(stdout.Bytes(), &res); err != nil {
		return "", fmt.Errorf("prefetch json parse failed: %v\nstdout:\n%s\nstderr:\n%s", err, stdout.String(), stderr.String())
	}
	if res.Hash == "" {
		return "", fmt.Errorf("empty hash for %s", url)
	}
	return res.Hash, nil
}

func PrefetchGitHub(owner, repo, rev string) (string, error) {
	var out bytes.Buffer
	if err := RunCommand("", PrefetchTimeout, &out, &out, "nix", "run", "--inputs-from", ".", "nixpkgs#nix-prefetch-github", "--", "--json", "--quiet", owner, repo, "--rev", rev); err != nil {
		return "", fmt.Errorf("prefetch github failed: %w: %s", err, out.String())
	}
	raw := out.String()
	start := strings.Index(raw, "{")
	end := strings.LastIndex(raw, "}")
	if start == -1 || end == -1 || end <= start {
		return "", fmt.Errorf("prefetch github returned non-json: %s", raw)
	}
	payload := raw[start : end+1]
	var res PrefetchResult
	if err := json.Unmarshal([]byte(payload), &res); err != nil {
		return "", err
	}
	if res.Hash == "" {
		return "", fmt.Errorf("empty hash for %s/%s@%s", owner, repo, rev)
	}
	return res.Hash, nil
}

func NixBuildSummarize() (string, error) {
	return NixBuildSummarizeSystem("")
}

func NixBuildSummarizeSystem(system string) (string, error) {
	args := []string{"build", ".#summarize"}
	if system != "" {
		args = append(args, "--system", system)
	}
	var out bytes.Buffer
	err := RunCommand("", SummarizeTimeout, &out, &out, "nix", args...)
	return out.String(), err
}

func ExtractGotHash(log string) string {
	// Nix typically prints something like:
	//   got:    sha256-....
	// but sometimes wraps/indents. Keep this forgiving.
	re := regexp.MustCompile(`(?i)got:\s*"?(sha256-[A-Za-z0-9+/=]+)"?`)
	for _, line := range strings.Split(log, "\n") {
		match := re.FindStringSubmatch(line)
		if len(match) > 1 {
			return match[1]
		}
	}
	return ""
}
