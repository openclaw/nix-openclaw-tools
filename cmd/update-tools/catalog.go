package main

import (
	"path/filepath"
	"regexp"
)

func releaseTools(repoRoot string) []Tool {
	return []Tool{
		{
			Name: "discrawl",
			Repo: "openclaw/discrawl",
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
			Repo: "openclaw/gogcli",
			Assets: []AssetSpec{
				{System: "aarch64-darwin", Regex: regexp.MustCompile(`gogcli_[0-9.]+_darwin_arm64\.tar\.gz`)},
				{System: "x86_64-linux", Regex: regexp.MustCompile(`gogcli_[0-9.]+_linux_amd64\.tar\.gz`)},
				{System: "aarch64-linux", Regex: regexp.MustCompile(`gogcli_[0-9.]+_linux_arm64\.tar\.gz`)},
			},
			NixFile: filepath.Join(repoRoot, "nix", "pkgs", "gogcli.nix"),
		},
		{
			Name: "goplaces",
			Repo: "openclaw/goplaces",
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
				{System: "aarch64-darwin", Regex: regexp.MustCompile(`camsnap(?:_[0-9.]+_darwin_arm64|-macos-arm64)\.tar\.gz`)},
				{System: "x86_64-linux", Regex: regexp.MustCompile(`camsnap_[0-9.]+_linux_amd64\.tar\.gz`)},
				{System: "aarch64-linux", Regex: regexp.MustCompile(`camsnap_[0-9.]+_linux_arm64\.tar\.gz`)},
			},
			NixFile: filepath.Join(repoRoot, "nix", "pkgs", "camsnap.nix"),
		},
		{
			Name: "sonoscli",
			Repo: "steipete/sonoscli",
			Assets: []AssetSpec{
				{System: "aarch64-darwin", Regex: regexp.MustCompile(`sonoscli_[0-9.]+_darwin_arm64\.tar\.gz`)},
				{System: "x86_64-linux", Regex: regexp.MustCompile(`sonoscli_[0-9.]+_linux_amd64\.tar\.gz`)},
				{System: "aarch64-linux", Regex: regexp.MustCompile(`sonoscli_[0-9.]+_linux_arm64\.tar\.gz`)},
			},
			NixFile: filepath.Join(repoRoot, "nix", "pkgs", "sonoscli.nix"),
		},
		{
			Name: "peekaboo",
			Repo: "openclaw/Peekaboo",
			Assets: []AssetSpec{
				{System: "aarch64-darwin", Regex: regexp.MustCompile(`peekaboo-macos-(?:arm64|universal)\.tar\.gz`)},
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
				{System: "aarch64-darwin", Regex: regexp.MustCompile(`sag_[0-9.]+_darwin_arm64\.tar\.gz`)},
				{System: "x86_64-linux", Regex: regexp.MustCompile(`sag_[0-9.]+_linux_amd64\.tar\.gz`)},
			},
			NixFile: filepath.Join(repoRoot, "nix", "pkgs", "sag.nix"),
		},
		{
			Name: "imsg",
			Repo: "openclaw/imsg",
			Assets: []AssetSpec{
				{System: "aarch64-darwin", Regex: regexp.MustCompile(`imsg-macos\.zip`)},
			},
			NixFile: filepath.Join(repoRoot, "nix", "pkgs", "imsg.nix"),
		},
	}
}
