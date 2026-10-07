//go:build unix

package main

import (
	"encoding/json"
	"os"
	"strings"
	"testing"

	"github.com/openclaw/nix-openclaw-tools/internal"
)

func TestUpdateWacliSelectsNativeArchivesAtomically(t *testing.T) {
	original, err := os.ReadFile("../../nix/pkgs/wacli.nix")
	if err != nil {
		t.Fatal(err)
	}
	platforms := []string{"darwin_arm64", "linux_amd64", "linux_arm64"}
	for _, missing := range append([]string{""}, platforms...) {
		t.Run("missing="+missing, func(t *testing.T) {
			var assets []internal.Asset
			for _, platform := range append([]string{"darwin_amd64", "universal_darwin_all"}, platforms...) {
				name := "wacli_2.0.0_" + platform + ".tar.gz"
				for _, candidate := range []string{name + ".sha256", name + ".sig", "debug-" + name, name} {
					if candidate == name && platform == missing {
						continue
					}
					assets = append(assets, internal.Asset{Name: candidate, BrowserDownloadURL: "https://example.invalid/" + candidate})
				}
			}
			data, err := json.Marshal(assets)
			if err != nil {
				t.Fatal(err)
			}
			releaseFixture(t, string(data))
			root, path := packageFixture(t, "wacli", string(original))
			for _, tool := range releaseTools(root) {
				if tool.Name != "wacli" {
					continue
				}
				if tool.Repo != "openclaw/wacli" || len(tool.Assets) != 3 {
					t.Fatalf("unexpected release catalog entry: %#v", tool)
				}
				err := updateTool(tool)
				if missing != "" {
					if err == nil || !strings.Contains(err.Error(), "no asset matched for wacli") {
						t.Fatalf("expected missing native archive error, got %v", err)
					}
					assertPackageUnchanged(t, path, string(original))
					return
				}
				if err != nil {
					t.Fatal(err)
				}
				got, err := os.ReadFile(path)
				if err != nil {
					t.Fatal(err)
				}
				if !strings.Contains(string(got), `version = "2.0.0";`) || strings.Count(string(got), `hash = "sha256-new";`) != 3 {
					t.Fatalf("version or hashes not updated: %s", got)
				}
				for _, platform := range platforms {
					if !strings.Contains(string(got), `url = "https://example.invalid/wacli_2.0.0_`+platform+`.tar.gz";`) {
						t.Fatalf("missing native archive for %s: %s", platform, got)
					}
				}
				return
			}
			t.Fatal("wacli missing from release catalog")
		})
	}
}
