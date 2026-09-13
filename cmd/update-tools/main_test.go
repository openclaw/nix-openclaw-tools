package main

import (
	"context"
	"errors"
	"strings"
	"testing"
)

func TestQMDNodeModulesHash(t *testing.T) {
	upstream := `
nodeModulesHashes = {
  x86_64-linux = "sha256-linux";
  aarch64-darwin = "sha256-darwin";
};
`

	got, err := qmdNodeModulesHash(upstream, "aarch64-darwin")
	if err != nil {
		t.Fatal(err)
	}
	if got != "sha256-darwin" {
		t.Fatalf("got %q", got)
	}
}

func TestQMDNodeModulesHashRejectsFake(t *testing.T) {
	upstream := `
nodeModulesHashes = {
  aarch64-darwin = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
};
`

	_, err := qmdNodeModulesHash(upstream, "aarch64-darwin")
	if err == nil {
		t.Fatal("expected fake hash to be rejected")
	}
}

func TestRunUpdatesContinuesAfterFailure(t *testing.T) {
	failure := errors.New("upstream unavailable")
	called := false
	err := runUpdates([]toolUpdate{
		{"broken", func() error { return failure }},
		{"healthy", func() error { called = true; return nil }},
	})
	if !called || !errors.Is(err, failure) || !strings.Contains(err.Error(), "broken") {
		t.Fatalf("called=%t err=%v", called, err)
	}
}

func TestRunUpdatesStopsAfterCancellation(t *testing.T) {
	called := false
	err := runUpdates([]toolUpdate{
		{"cancelled", func() error { return context.Canceled }},
		{"later", func() error { called = true; return nil }},
	})
	if called || !errors.Is(err, context.Canceled) {
		t.Fatalf("called=%t err=%v", called, err)
	}
}
