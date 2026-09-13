package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"strings"

	"github.com/openclaw/nix-openclaw-tools/internal"
)

func fetchText(url string) (string, error) {
	req, err := http.NewRequest(http.MethodGet, url, nil)
	if err != nil {
		return "", err
	}
	if token := os.Getenv("GH_TOKEN"); token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}
	resp, err := internal.HTTPClient.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		body, _ := io.ReadAll(resp.Body)
		return "", fmt.Errorf("fetch %s: %s: %s", url, resp.Status, string(body))
	}
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}
	return string(body), nil
}

func qmdNodeModulesHash(upstreamFlake, system string) (string, error) {
	re := regexp.MustCompile(fmt.Sprintf(`"?%s"?\s*=\s*"([^"]+)";`, regexp.QuoteMeta(system)))
	match := re.FindStringSubmatch(upstreamFlake)
	if len(match) < 2 {
		return "", fmt.Errorf("qmd nodeModules hash for %s not found upstream", system)
	}
	hash := match[1]
	if strings.Contains(hash, "AAAAAAAA") || strings.Contains(hash, "fake") {
		return "", fmt.Errorf("qmd nodeModules hash for %s is not populated upstream", system)
	}
	return hash, nil
}

func updateQMD(repoRoot string) error {
	log.Printf("[update-tools] qmd")
	qmdFile := filepath.Join(repoRoot, "nix", "pkgs", "qmd.nix")
	return editPackage(qmdFile, func(e *nixExpression) error {
		match := versionPattern.FindStringSubmatch(e.text)
		if len(match) < 2 {
			return fmt.Errorf("version not found in %s", qmdFile)
		}
		currentVersion := match[1]

		rel, err := internal.LatestRelease("tobi/qmd")
		if err != nil {
			return err
		}
		version := strings.TrimPrefix(rel.TagName, "v")
		if currentVersion == version {
			return nil
		}

		srcHash, err := internal.PrefetchGitHub("tobi", "qmd", "v"+version)
		if err != nil {
			return err
		}
		upstreamFlake, err := fetchText(fmt.Sprintf("https://raw.githubusercontent.com/tobi/qmd/v%s/flake.nix", version))
		if err != nil {
			return err
		}
		nodeHashes := map[string]string{}
		for _, system := range []string{"aarch64-darwin", "x86_64-linux"} {
			hash, err := qmdNodeModulesHash(upstreamFlake, system)
			if err != nil {
				return err
			}
			nodeHashes[system] = hash
		}

		if err := e.replace(versionPattern, fmt.Sprintf(`version = "%s";`, version)); err != nil {
			return err
		}
		srcRe := regexp.MustCompile(`(?s)src = fetchFromGitHub \{.*?\};`)
		if err := e.replaceInBlock(srcRe, hashPattern, fmt.Sprintf(`hash = "%s";`, srcHash)); err != nil {
			return err
		}

		for system, hash := range nodeHashes {
			re := regexp.MustCompile(fmt.Sprintf(`"%s" = "sha256-[^"]+";`, regexp.QuoteMeta(system)))
			if err := e.replace(re, fmt.Sprintf(`"%s" = "%s";`, system, hash)); err != nil {
				return err
			}
		}
		return nil
	})
}
