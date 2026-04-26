package main

import (
	"fmt"
	"log"
	"os"
	"path/filepath"
	"regexp"
	"runtime"
	"strings"

	"github.com/clawdbot/nix-steipete-tools/internal"
)

type Tool struct {
	Name     string
	Repo     string
	Assets   []AssetSpec
	NixFile  string
	Optional bool
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
	pnpmHash := internal.ExtractGotHash(logText)
	if pnpmHash == "" && runtime.GOOS == "darwin" {
		log.Printf("[update-tools] summarize: no pnpm hash on darwin, trying x86_64-linux")
		logText, buildErr = internal.NixBuildSummarizeSystem("x86_64-linux")
		pnpmHash = internal.ExtractGotHash(logText)
	}
	if pnpmHash == "" {
		_ = os.WriteFile(summarizeFile, orig, 0644)
		return fmt.Errorf("summarize pnpm hash not found (build err: %v)", buildErr)
	}
	if err := internal.ReplaceOnceFunc(summarizeFile, pnpmRe, func(s string) string {
		return regexp.MustCompile(`hash = "sha256-[^"]+";`).ReplaceAllString(s, fmt.Sprintf(`hash = "%s";`, pnpmHash))
	}); err != nil {
		return err
	}
	return nil
}

func main() {
	repoRoot, err := os.Getwd()
	if err != nil {
		log.Fatal(err)
	}

	tools := []Tool{
		{
			Name: "discrawl",
			Repo: "steipete/discrawl",
			Assets: []AssetSpec{
				{System: "aarch64-darwin", Regex: regexp.MustCompile(`discrawl_[0-9.]+_darwin_arm64\.tar\.gz`)},
				{System: "x86_64-linux", Regex: regexp.MustCompile(`discrawl_[0-9.]+_linux_amd64\.tar\.gz`)},
				{System: "aarch64-linux", Regex: regexp.MustCompile(`discrawl_[0-9.]+_linux_arm64\.tar\.gz`)},
			},
			NixFile: filepath.Join(repoRoot, "nix", "pkgs", "discrawl.nix"),
		},
		{
			Name: "wacrawl",
			Repo: "steipete/wacrawl",
			Assets: []AssetSpec{
				{System: "aarch64-darwin", Regex: regexp.MustCompile(`wacrawl_[0-9.]+_darwin_arm64\.tar\.gz`)},
				{System: "x86_64-linux", Regex: regexp.MustCompile(`wacrawl_[0-9.]+_linux_amd64\.tar\.gz`)},
				{System: "aarch64-linux", Regex: regexp.MustCompile(`wacrawl_[0-9.]+_linux_arm64\.tar\.gz`)},
			},
			NixFile: filepath.Join(repoRoot, "nix", "pkgs", "wacrawl.nix"),
		},
		{
			Name: "gogcli",
			Repo: "steipete/gogcli",
			Assets: []AssetSpec{
				{System: "aarch64-darwin", Regex: regexp.MustCompile(`gogcli_[0-9.]+_darwin_arm64\.tar\.gz`)},
				{System: "x86_64-linux", Regex: regexp.MustCompile(`gogcli_[0-9.]+_linux_amd64\.tar\.gz`)},
				{System: "aarch64-linux", Regex: regexp.MustCompile(`gogcli_[0-9.]+_linux_arm64\.tar\.gz`)},
			},
			NixFile: filepath.Join(repoRoot, "nix", "pkgs", "gogcli.nix"),
		},
		{
			Name: "goplaces",
			Repo: "steipete/goplaces",
			Assets: []AssetSpec{
				{System: "aarch64-darwin", Regex: regexp.MustCompile(`goplaces_[0-9.]+_darwin_arm64\.tar\.gz`)},
				{System: "x86_64-darwin", Regex: regexp.MustCompile(`goplaces_[0-9.]+_darwin_amd64\.tar\.gz`)},
				{System: "x86_64-linux", Regex: regexp.MustCompile(`goplaces_[0-9.]+_linux_amd64\.tar\.gz`)},
				{System: "aarch64-linux", Regex: regexp.MustCompile(`goplaces_[0-9.]+_linux_arm64\.tar\.gz`)},
			},
			NixFile: filepath.Join(repoRoot, "nix", "pkgs", "goplaces.nix"),
		},
		{
			Name: "camsnap",
			Repo: "steipete/camsnap",
			Assets: []AssetSpec{
				{System: "aarch64-darwin", Regex: regexp.MustCompile(`camsnap-macos-arm64\.tar\.gz`)},
				{System: "x86_64-linux", Regex: regexp.MustCompile(`camsnap_[0-9.]+_linux_amd64\.tar\.gz`)},
				{System: "aarch64-linux", Regex: regexp.MustCompile(`camsnap_[0-9.]+_linux_arm64\.tar\.gz`)},
			},
			NixFile: filepath.Join(repoRoot, "nix", "pkgs", "camsnap.nix"),
		},
		{
			Name: "sonoscli",
			Repo: "steipete/sonoscli",
			Assets: []AssetSpec{
				{System: "aarch64-darwin", Regex: regexp.MustCompile(`sonoscli-macos-arm64\.tar\.gz`)},
				{System: "x86_64-linux", Regex: regexp.MustCompile(`sonoscli_[0-9.]+_linux_amd64\.tar\.gz`)},
				{System: "aarch64-linux", Regex: regexp.MustCompile(`sonoscli_[0-9.]+_linux_arm64\.tar\.gz`)},
			},
			NixFile: filepath.Join(repoRoot, "nix", "pkgs", "sonoscli.nix"),
		},
		{
			Name:     "bird",
			Repo:     "steipete/bird",
			Optional: true, // repo got nuked; keep packaging pinned, but don't fail the updater
			Assets: []AssetSpec{
				{System: "aarch64-darwin", Regex: regexp.MustCompile(`bird-macos-universal-v[0-9.]+\.tar\.gz`)},
			},
			NixFile: filepath.Join(repoRoot, "nix", "pkgs", "bird.nix"),
		},
		{
			Name: "peekaboo",
			Repo: "steipete/peekaboo",
			Assets: []AssetSpec{
				{System: "aarch64-darwin", Regex: regexp.MustCompile(`peekaboo-macos-universal\.tar\.gz`)},
			},
			NixFile: filepath.Join(repoRoot, "nix", "pkgs", "peekaboo.nix"),
		},
		{
			Name: "poltergeist",
			Repo: "steipete/poltergeist",
			Assets: []AssetSpec{
				{System: "aarch64-darwin", Regex: regexp.MustCompile(`poltergeist-macos-universal-v[0-9.]+\.tar\.gz`)},
			},
			NixFile: filepath.Join(repoRoot, "nix", "pkgs", "poltergeist.nix"),
		},
		{
			Name: "sag",
			Repo: "steipete/sag",
			Assets: []AssetSpec{
				{System: "aarch64-darwin", Regex: regexp.MustCompile(`sag_[0-9.]+_darwin_universal\.tar\.gz`)},
				{System: "x86_64-linux", Regex: regexp.MustCompile(`sag_[0-9.]+_linux_amd64\.tar\.gz`)},
			},
			NixFile: filepath.Join(repoRoot, "nix", "pkgs", "sag.nix"),
		},
		{
			Name: "imsg",
			Repo: "steipete/imsg",
			Assets: []AssetSpec{
				{System: "aarch64-darwin", Regex: regexp.MustCompile(`imsg-macos\.zip`)},
			},
			NixFile: filepath.Join(repoRoot, "nix", "pkgs", "imsg.nix"),
		},
	}

	if err := updateSummarize(repoRoot); err != nil {
		log.Fatalf("update summarize failed: %v", err)
	}
	for _, tool := range tools {
		if err := updateTool(tool); err != nil {
			if tool.Optional {
				log.Printf("[update-tools] skipping optional tool %s: %v", tool.Name, err)
				continue
			}
			log.Fatalf("update %s failed: %v", tool.Name, err)
		}
	}

}
