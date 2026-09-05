package internal

import (
	"context"
	"errors"
	"fmt"
	"os"
	"testing"
	"time"
)

func TestMain(m *testing.M) {
	switch os.Getenv("OPENCLAW_FAKE_NIX") {
	case "sleep":
		time.Sleep(time.Hour)
		os.Exit(0)
	case "ok":
		fmt.Fprintln(os.Stderr, `got:    sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=`)
		os.Exit(0)
	}
	if os.Getenv("OPENCLAW_SUMMARIZE_DEADLINE_DEMO") == "1" {
		os.Exit(runSummarizeDeadlineDemo())
	}
	os.Exit(m.Run())
}

func runSummarizeDeadlineDemo() int {
	summarizeTimeout = 200 * time.Millisecond
	summarizeNix = os.Args[0]
	if err := os.Setenv("OPENCLAW_FAKE_NIX", "sleep"); err != nil {
		fmt.Fprintf(os.Stderr, "setenv: %v\n", err)
		return 1
	}
	start := time.Now()
	out, err := NixBuildSummarizeSystem("x86_64-linux")
	elapsed := time.Since(start)
	fmt.Fprintf(os.Stderr, "elapsed=%s err=%v\n", elapsed.Round(time.Millisecond), err)
	if out != "" {
		fmt.Fprintf(os.Stderr, "output=%q\n", out)
	}
	if errors.Is(err, context.DeadlineExceeded) {
		fmt.Fprintln(os.Stderr, "deadline-abort=yes")
		return 0
	}
	fmt.Fprintln(os.Stderr, "deadline-abort=no")
	return 1
}

func TestNixBuildSummarizeSystemHonorsDeadline(t *testing.T) {
	oldTimeout := summarizeTimeout
	oldNix := summarizeNix
	summarizeTimeout = 200 * time.Millisecond
	summarizeNix = os.Args[0]
	t.Setenv("OPENCLAW_FAKE_NIX", "sleep")
	t.Cleanup(func() {
		summarizeTimeout = oldTimeout
		summarizeNix = oldNix
	})

	done := make(chan error, 1)
	go func() {
		_, err := NixBuildSummarizeSystem("x86_64-linux")
		done <- err
	}()

	select {
	case err := <-done:
		if err == nil {
			t.Fatal("expected deadline error, got nil")
		}
		if !errors.Is(err, context.DeadlineExceeded) {
			t.Fatalf("error = %v, want context.DeadlineExceeded", err)
		}
	case <-time.After(2 * time.Second):
		t.Fatal("NixBuildSummarizeSystem ignored the deadline and is still running")
	}
}

func TestNixBuildSummarizeHonorsDeadline(t *testing.T) {
	oldTimeout := summarizeTimeout
	oldNix := summarizeNix
	summarizeTimeout = 200 * time.Millisecond
	summarizeNix = os.Args[0]
	t.Setenv("OPENCLAW_FAKE_NIX", "sleep")
	t.Cleanup(func() {
		summarizeTimeout = oldTimeout
		summarizeNix = oldNix
	})

	done := make(chan error, 1)
	go func() {
		_, err := NixBuildSummarize()
		done <- err
	}()

	select {
	case err := <-done:
		if err == nil {
			t.Fatal("expected deadline error, got nil")
		}
		if !errors.Is(err, context.DeadlineExceeded) {
			t.Fatalf("error = %v, want context.DeadlineExceeded", err)
		}
	case <-time.After(2 * time.Second):
		t.Fatal("NixBuildSummarize ignored the deadline and is still running")
	}
}

func TestNixBuildSummarizeSystemReturnsOutput(t *testing.T) {
	oldNix := summarizeNix
	summarizeNix = os.Args[0]
	t.Setenv("OPENCLAW_FAKE_NIX", "ok")
	t.Cleanup(func() {
		summarizeNix = oldNix
	})

	out, err := NixBuildSummarizeSystem("")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if got := ExtractGotHash(out); got != "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=" {
		t.Fatalf("got hash %q from output %q", got, out)
	}
}
