package main

import (
	"fmt"
	"log"
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
	return editPackage(tool.NixFile, func(e *nixExpression) error {
		rel, err := internal.LatestRelease(tool.Repo)
		if err != nil {
			return err
		}
		version := strings.TrimPrefix(rel.TagName, "v")
		if err := e.replace(versionPattern, fmt.Sprintf(`version = "%s";`, version)); err != nil {
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
			if err := e.setSource(asset.System, assetURL, hash); err != nil {
				return err
			}
		}
		return nil
	})
}
