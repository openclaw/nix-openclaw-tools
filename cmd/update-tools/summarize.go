package main

import (
	"context"
	"errors"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"regexp"
	"runtime"
	"strings"

	"github.com/openclaw/nix-openclaw-tools/internal"
)

func updateSummarize(repoRoot string) error {
	log.Printf("[update-tools] summarize")
	summarizeFile := filepath.Join(repoRoot, "nix", "pkgs", "summarize.nix")
	orig, err := os.ReadFile(summarizeFile)
	if err != nil {
		return err
	}

	rel, err := internal.LatestRelease("steipete/summarize")
	if err != nil {
		return err
	}
	version := strings.TrimPrefix(rel.TagName, "v")
	var assetURL string
	for _, a := range rel.Assets {
		if matched, _ := regexp.MatchString(`summarize-macos-arm64-v[0-9.]+\.tar\.gz`, a.Name); matched {
			assetURL = a.BrowserDownloadURL
			break
		}
	}
	if assetURL == "" {
		return fmt.Errorf("no asset matched for summarize")
	}
	assetHash, err := internal.PrefetchHash(assetURL)
	if err != nil {
		return err
	}
	srcURL := fmt.Sprintf("https://github.com/steipete/summarize/archive/refs/tags/v%s.tar.gz", version)
	srcHash, err := internal.PrefetchHash(srcURL)
	if err != nil {
		return err
	}

	if err := internal.ReplaceOnce(summarizeFile, regexp.MustCompile(`version = "[^"]+";`), fmt.Sprintf(`version = "%s";`, version)); err != nil {
		return err
	}
	if err := updateSourceBlock(summarizeFile, "aarch64-darwin", assetURL, assetHash); err != nil {
		return err
	}
	srcRe := regexp.MustCompile(`(?s)src = fetchurl \{.*?hash = "sha256-[^"]+";`)
	if err := internal.ReplaceOnceFunc(summarizeFile, srcRe, func(s string) string {
		return regexp.MustCompile(`hash = "sha256-[^"]+";`).ReplaceAllString(s, fmt.Sprintf(`hash = "%s";`, srcHash))
	}); err != nil {
		return err
	}
	pnpmRe := regexp.MustCompile(`(?s)pnpmDeps.*hash = "sha256-[^"]+";`)
	if err := internal.ReplaceOnceFunc(summarizeFile, pnpmRe, func(s string) string {
		return regexp.MustCompile(`hash = "sha256-[^"]+";`).ReplaceAllString(s, `hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";`)
	}); err != nil {
		return err
	}

	log.Printf("[update-tools] summarize: deriving pnpm hash")
	logText, buildErr := internal.NixBuildSummarize()
	if errors.Is(buildErr, context.Canceled) || errors.Is(buildErr, context.DeadlineExceeded) {
		_ = os.WriteFile(summarizeFile, orig, 0644)
		return fmt.Errorf("summarize build interrupted: %w", buildErr)
	}
	pnpmHash := internal.ExtractGotHash(logText)
	if pnpmHash == "" && runtime.GOOS == "darwin" {
		log.Printf("[update-tools] summarize: no pnpm hash on darwin, trying x86_64-linux")
		logText, buildErr = internal.NixBuildSummarizeSystem("x86_64-linux")
		if errors.Is(buildErr, context.Canceled) || errors.Is(buildErr, context.DeadlineExceeded) {
			_ = os.WriteFile(summarizeFile, orig, 0644)
			return fmt.Errorf("summarize build interrupted: %w", buildErr)
		}
		pnpmHash = internal.ExtractGotHash(logText)
	}
	if pnpmHash == "" {
		_ = os.WriteFile(summarizeFile, orig, 0644)
		return fmt.Errorf("summarize pnpm hash not found (build err: %v)\n%s", buildErr, logText)
	}
	if err := internal.ReplaceOnceFunc(summarizeFile, pnpmRe, func(s string) string {
		return regexp.MustCompile(`hash = "sha256-[^"]+";`).ReplaceAllString(s, fmt.Sprintf(`hash = "%s";`, pnpmHash))
	}); err != nil {
		return err
	}
	return nil
}
