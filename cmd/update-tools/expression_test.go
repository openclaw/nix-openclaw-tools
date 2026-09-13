package main

import (
	"errors"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"testing"
)

func TestEditPackageRestoresTemporaryBuildInput(t *testing.T) {
	path := filepath.Join(t.TempDir(), "tool.nix")
	const original = `version = "1.0.0";`
	if err := os.WriteFile(path, []byte(original), 0o640); err != nil {
		t.Fatal(err)
	}
	failure := errors.New("build failed")
	err := editPackage(path, func(e *nixExpression) error {
		if err := e.replace(versionPattern, `version = "2.0.0";`); err != nil {
			return err
		}
		if err := e.save(); err != nil {
			return err
		}
		data, err := os.ReadFile(path)
		if err != nil || string(data) == original {
			t.Fatalf("temporary build input not saved: %s, %v", data, err)
		}
		return failure
	})
	if !errors.Is(err, failure) {
		t.Fatalf("error = %v", err)
	}
	data, err := os.ReadFile(path)
	if err != nil || string(data) != original {
		t.Fatalf("rollback = %s, %v", data, err)
	}
	info, err := os.Stat(path)
	if err != nil || info.Mode().Perm() != 0o640 {
		t.Fatalf("mode not preserved: %v, %v", info, err)
	}
	files, err := os.ReadDir(filepath.Dir(path))
	if err != nil || len(files) != 1 {
		t.Fatalf("temporary files remain: %v, %v", files, err)
	}
}

func TestReplaceMatchRejectsAmbiguousFields(t *testing.T) {
	if _, err := replaceMatch(`version = "1"; version = "2";`, versionPattern, `version = "3";`); err == nil {
		t.Fatal("expected duplicate version error")
	}
}

func TestEditPackagePreservesLiteralReplacement(t *testing.T) {
	path := filepath.Join(t.TempDir(), "tool.nix")
	if err := os.WriteFile(path, []byte(`url = "old"; hash = "sha256-old";`), 0o644); err != nil {
		t.Fatal(err)
	}
	const replacement = `url = "https://example.invalid/$release.tar.gz";`
	if err := editPackage(path, func(e *nixExpression) error {
		if err := e.replace(urlPattern, replacement); err != nil {
			return err
		}
		return e.replace(regexp.MustCompile(`hash = "[^"]+";`), `hash = "sha256-new";`)
	}); err != nil {
		t.Fatal(err)
	}
	data, err := os.ReadFile(path)
	if err != nil || !strings.Contains(string(data), replacement) || !strings.Contains(string(data), "sha256-new") {
		t.Fatalf("saved candidate = %s, %v", data, err)
	}
}
