package internal

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"os/exec"
	"regexp"
	"strings"
	"time"
)

var PrefetchTimeout = 10 * time.Minute

type PrefetchResult struct {
	Hash string `json:"hash"`
}

type PrefetchGitHubResult struct {
	Hash string `json:"hash"`
}

func PrefetchHash(url string) (string, error) {
	ctx, cancel := context.WithTimeout(context.Background(), PrefetchTimeout)
	defer cancel()
	cmd := exec.CommandContext(ctx, "nix", "store", "prefetch-file", "--json", url)
	var stdout bytes.Buffer
	var stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	if err := cmd.Run(); err != nil {
		if ctx.Err() != nil {
			return "", fmt.Errorf("prefetch failed: %w", ctx.Err())
		}
		return "", fmt.Errorf("prefetch failed: %v\nstdout:\n%s\nstderr:\n%s", err, stdout.String(), stderr.String())
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
	ctx, cancel := context.WithTimeout(context.Background(), PrefetchTimeout)
	defer cancel()
	cmd := exec.CommandContext(ctx, "nix", "run", "nixpkgs#nix-prefetch-github", "--", "--json", "--quiet", owner, repo, "--rev", rev)
	var out bytes.Buffer
	cmd.Stdout = &out
	cmd.Stderr = &out
	if err := cmd.Run(); err != nil {
		if ctx.Err() != nil {
			return "", fmt.Errorf("prefetch github failed: %w", ctx.Err())
		}
		return "", fmt.Errorf("prefetch github failed: %v: %s", err, out.String())
	}
	raw := out.String()
	start := strings.Index(raw, "{")
	end := strings.LastIndex(raw, "}")
	if start == -1 || end == -1 || end <= start {
		return "", fmt.Errorf("prefetch github returned non-json: %s", raw)
	}
	payload := raw[start : end+1]
	var res PrefetchGitHubResult
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
	cmd := exec.Command("nix", args...)
	var out bytes.Buffer
	cmd.Stdout = &out
	cmd.Stderr = &out
	err := cmd.Run()
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
