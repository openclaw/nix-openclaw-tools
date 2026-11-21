package internal

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/url"
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
	return prefetchHash(url, false)
}

func prefetchHash(url string, unpack bool) (string, error) {
	var stdout bytes.Buffer
	var stderr bytes.Buffer
	args := []string{"store", "prefetch-file", "--json"}
	if unpack {
		args = append(args, "--unpack")
	}
	args = append(args, url)
	if err := RunCommand("", PrefetchTimeout, &stdout, &stderr, "nix", args...); err != nil {
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
	archive := fmt.Sprintf("https://github.com/%s/%s/archive/%s.tar.gz", url.PathEscape(owner), url.PathEscape(repo), url.PathEscape(rev))
	return prefetchHash(archive, true)
}

func NixBuildSummarize() (string, error) {
	return NixBuildSummarizeSystem("")
}

func NixBuildSummarizeSystem(system string) (string, error) {
	args := []string{"build", ".#summarize", "--no-link"}
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
