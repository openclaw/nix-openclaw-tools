//go:build unix

package main

import (
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"testing"

	"github.com/openclaw/nix-openclaw-tools/internal"
)

func releaseFixture(t *testing.T, assets string) {
	t.Helper()
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, `{"tag_name":"v2.0.0","assets":%s}`, assets)
	}))
	t.Cleanup(server.Close)
	oldBase, oldClient := internal.GitHubAPIBase, internal.HTTPClient
	internal.GitHubAPIBase, internal.HTTPClient = server.URL, server.Client()
	t.Cleanup(func() { internal.GitHubAPIBase, internal.HTTPClient = oldBase, oldClient })
	t.Setenv("GH_TOKEN", "")
	dir := t.TempDir()
	if err := os.WriteFile(filepath.Join(dir, "nix"), []byte("#!/bin/sh\nprintf '%s\\n' '{\"hash\":\"sha256-new\"}'\n"), 0o755); err != nil {
		t.Fatal(err)
	}
	t.Setenv("PATH", dir+string(os.PathListSeparator)+os.Getenv("PATH"))
}

func packageFixture(t *testing.T, name, contents string) (string, string) {
	t.Helper()
	root := t.TempDir()
	path := filepath.Join(root, "nix", "pkgs", name+".nix")
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(path, []byte(contents), 0o644); err != nil {
		t.Fatal(err)
	}
	return root, path
}

func assertPackageUnchanged(t *testing.T, path, original string) {
	t.Helper()
	got, err := os.ReadFile(path)
	if err != nil {
		t.Fatal(err)
	}
	if string(got) != original {
		t.Fatalf("failed update changed package:\n%s\nwant:\n%s", got, original)
	}
}

func TestUpdateToolLeavesPackageIntactWhenLaterAssetIsMissing(t *testing.T) {
	releaseFixture(t, `[{"name":"tool-linux-amd64.tar.gz","browser_download_url":"https://example.invalid/new.tar.gz"}]`)
	const original = `version = "1.0.0";
sources = {
  "x86_64-linux" = { url = "https://example.invalid/old.tar.gz"; hash = "sha256-old"; };
  "aarch64-linux" = { url = "https://example.invalid/old-arm.tar.gz"; hash = "sha256-old-arm"; };
};`
	_, path := packageFixture(t, "tool", original)
	err := updateTool(Tool{Name: "tool", Repo: "owner/tool", NixFile: path, Assets: []AssetSpec{
		{System: "x86_64-linux", Regex: regexp.MustCompile(`tool-linux-amd64\.tar\.gz`)},
		{System: "aarch64-linux", Regex: regexp.MustCompile(`tool-linux-arm64\.tar\.gz`)},
	}})
	if err == nil {
		t.Fatal("expected missing asset error")
	}
	assertPackageUnchanged(t, path, original)
}

func TestUpdateToolRejectsMissingHashWithoutChangingPackage(t *testing.T) {
	releaseFixture(t, `[{"name":"tool.tar.gz","browser_download_url":"https://example.invalid/new.tar.gz"}]`)
	const original = `version = "1.0.0";
sources = { "x86_64-linux" = { url = "https://example.invalid/old.tar.gz"; }; };`
	_, path := packageFixture(t, "tool", original)
	err := updateTool(Tool{Name: "tool", Repo: "owner/tool", NixFile: path, Assets: []AssetSpec{
		{System: "x86_64-linux", Regex: regexp.MustCompile(`tool\.tar\.gz`)},
	}})
	if err == nil {
		t.Error("expected missing hash error")
	}
	assertPackageUnchanged(t, path, original)
}

func TestUpdateSummarizeLeavesPackageIntactWhenSourceBlockIsMissing(t *testing.T) {
	releaseFixture(t, `[{"name":"summarize-macos-arm64-v2.0.0.tar.gz","browser_download_url":"https://example.invalid/new.tar.gz"}]`)
	const original = `version = "1.0.0";
binSources = { "aarch64-darwin" = { url = "https://example.invalid/old.tar.gz"; hash = "sha256-old"; }; };`
	root, path := packageFixture(t, "summarize", original)
	if err := updateSummarize(root); err == nil {
		t.Fatal("expected missing source block error")
	}
	assertPackageUnchanged(t, path, original)
}

type responseTransport func(*http.Request) (*http.Response, error)

func (f responseTransport) RoundTrip(r *http.Request) (*http.Response, error) { return f(r) }

func TestUpdateQMDRejectsSourceHashOutsideItsBlock(t *testing.T) {
	releaseFixture(t, `[]`)
	client := internal.HTTPClient
	internal.HTTPClient = &http.Client{Transport: responseTransport(func(r *http.Request) (*http.Response, error) {
		if r.URL.Host == "raw.githubusercontent.com" {
			return &http.Response{StatusCode: http.StatusOK, Body: io.NopCloser(strings.NewReader(`nodeModulesHashes = {
  "aarch64-darwin" = "sha256-darwin-new";
  "x86_64-linux" = "sha256-linux-new";
};`))}, nil
		}
		return client.Transport.RoundTrip(r)
	})}
	const original = `version = "1.0.0";
src = fetchFromGitHub { owner = "tobi"; repo = "qmd"; rev = "v1.0.0"; };
nodeModulesHashes = {
  "aarch64-darwin" = "sha256-darwin-old";
  "x86_64-linux" = "sha256-linux-old";
};
unrelated = { hash = "sha256-unrelated"; };`
	root, path := packageFixture(t, "qmd", original)
	if err := updateQMD(root); err == nil {
		t.Error("expected missing source hash error")
	}
	assertPackageUnchanged(t, path, original)
}
