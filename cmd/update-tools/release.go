package main

import (
	"fmt"
	"log"
	"os"
	"regexp"
	"strings"

	"github.com/openclaw/nix-openclaw-tools/internal"
)

type Tool struct {
	Name    string
	Repo    string
	Assets  []AssetSpec
	NixFile string
}

type AssetSpec struct {
	System string
	Regex  *regexp.Regexp
}

func updateTool(tool Tool) error {
	log.Printf("[update-tools] %s", tool.Name)
	rel, err := internal.LatestRelease(tool.Repo)
	if err != nil {
		return err
	}
	version := strings.TrimPrefix(rel.TagName, "v")
	if err := internal.ReplaceOnce(tool.NixFile, regexp.MustCompile(`version = "[^"]+";`), fmt.Sprintf(`version = "%s";`, version)); err != nil {
		return err
	}

	for _, asset := range tool.Assets {
		var assetURL string
		for _, a := range rel.Assets {
			if asset.Regex.MatchString(a.Name) {
				assetURL = a.BrowserDownloadURL
				break
			}
		}
		if assetURL == "" {
			return fmt.Errorf("no asset matched for %s (%s)", tool.Name, asset.System)
		}
		hash, err := internal.PrefetchHash(assetURL)
		if err != nil {
			return err
		}
		if err := updateSourceBlock(tool.NixFile, asset.System, assetURL, hash); err != nil {
			return err
		}
	}

	return nil
}

func updateSourceBlock(path, system, url, hash string) error {
	blockRe := regexp.MustCompile(fmt.Sprintf(`(?s)"%s" = \{.*?\};`, regexp.QuoteMeta(system)))
	return internal.ReplaceOnceFunc(path, blockRe, func(s string) string {
		out := regexp.MustCompile(`url = "[^"]+";`).ReplaceAllString(s, fmt.Sprintf(`url = "%s";`, url))
		out = regexp.MustCompile(`hash = "sha256-[^"]+";`).ReplaceAllString(out, fmt.Sprintf(`hash = "%s";`, hash))
		return out
	})
}

func readVersion(path string) (string, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return "", err
	}
	match := regexp.MustCompile(`version = "([^"]+)";`).FindStringSubmatch(string(data))
	if len(match) < 2 {
		return "", fmt.Errorf("version not found in %s", path)
	}
	return match[1], nil
}
