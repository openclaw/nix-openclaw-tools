//go:build unix

package internal

import (
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
)

// Exercise the Nix check's shell body against the release bundle layout.
func TestMacOSRuntimeAssets(t *testing.T) {
	expression, err := os.ReadFile("../nix/checks/macos-runtime-assets.nix")
	if err != nil {
		t.Fatal(err)
	}
	_, body, ok := strings.Cut(string(expression), "{} ''\n")
	if !ok {
		t.Fatal("missing runtime check shell body")
	}
	body, ok = strings.CutSuffix(body, "''\n")
	if !ok {
		t.Fatal("missing runtime check shell terminator")
	}
	assets := []string{
		"imsg/bin/PhoneNumberKit_PhoneNumberKit.bundle/Contents/Resources/PhoneNumberMetadata.json",
		"imsg/bin/SQLite.swift_SQLite.bundle/Contents/Resources/PrivacyInfo.xcprivacy",
		"imsg/bin/imsg-bridge-helper.dylib",
		"peekaboo/bin/libswiftCompatibilitySpan.dylib",
	}
	for _, missing := range append([]string{""}, assets...) {
		t.Run("missing="+missing, func(t *testing.T) {
			root := t.TempDir()
			for _, asset := range assets {
				if asset == missing {
					continue
				}
				path := filepath.Join(root, asset)
				if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
					t.Fatal(err)
				}
				if err := os.WriteFile(path, []byte("fixture"), 0o644); err != nil {
					t.Fatal(err)
				}
			}
			for _, tool := range []string{"imsg", "peekaboo"} {
				path := filepath.Join(root, tool, "bin", tool)
				if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
					t.Fatal(err)
				}
				if err := os.WriteFile(path, []byte("#!/bin/sh\ntest \"$1\" = --version\n"), 0o755); err != nil {
					t.Fatal(err)
				}
			}
			script := strings.NewReplacer("${imsg}", filepath.Join(root, "imsg"), "${peekaboo}", filepath.Join(root, "peekaboo")).Replace(body)
			cmd := exec.Command("sh", "-eu", "-c", script)
			cmd.Env = append(os.Environ(), "out="+filepath.Join(root, "result"))
			output, err := cmd.CombinedOutput()
			if missing == "" && err != nil {
				t.Fatalf("complete release assets rejected: %v\n%s", err, output)
			}
			if missing != "" && err == nil {
				t.Fatalf("missing release asset %s accepted", missing)
			}
		})
	}
}
