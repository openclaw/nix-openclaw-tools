package internal

import (
	"context"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"syscall"
	"testing"
	"time"
)

func installHangCommand(t *testing.T, name string) string {
	t.Helper()
	dir := t.TempDir()
	pidfile := filepath.Join(dir, "pid")
	script := filepath.Join(dir, name)
	body := "#!/bin/sh\necho $$ > \"" + pidfile + "\"\nexec sleep 3600\n"
	if err := os.WriteFile(script, []byte(body), 0o755); err != nil {
		t.Fatal(err)
	}
	t.Setenv("PATH", dir+string(os.PathListSeparator)+os.Getenv("PATH"))
	return pidfile
}

func waitForPID(t *testing.T, pidfile string) int {
	t.Helper()
	deadline := time.Now().Add(2 * time.Second)
	for time.Now().Before(deadline) {
		b, err := os.ReadFile(pidfile)
		if err == nil {
			var pid int
			if _, err := fmt.Sscanf(string(b), "%d", &pid); err == nil && pid > 0 {
				return pid
			}
		}
		time.Sleep(10 * time.Millisecond)
	}
	t.Fatalf("hung child did not write pid file %s", pidfile)
	return 0
}

func assertHungChildKilled(t *testing.T, pidfile string, done <-chan error) {
	t.Helper()
	deadline := time.After(3 * time.Second)
	var pid int
	t.Cleanup(func() {
		if pid > 0 {
			_ = syscall.Kill(pid, syscall.SIGKILL)
		}
	})
	for {
		if pid == 0 {
			if b, err := os.ReadFile(pidfile); err == nil {
				_, _ = fmt.Sscanf(string(b), "%d", &pid)
			}
		}
		select {
		case err := <-done:
			if !errors.Is(err, context.DeadlineExceeded) {
				t.Fatalf("error = %v, want context.DeadlineExceeded", err)
			}
			if pid == 0 {
				pid = waitForPID(t, pidfile)
			}
			if err := syscall.Kill(pid, 0); err == nil {
				t.Fatalf("hung child pid %d still running after command returned", pid)
			}
			return
		case <-deadline:
			t.Fatal("command did not return; hung child was not killed")
			return
		default:
			time.Sleep(10 * time.Millisecond)
		}
	}
}

func TestPrefetchHashKillsHungChild(t *testing.T) {
	old := PrefetchTimeout
	PrefetchTimeout = time.Second
	t.Cleanup(func() { PrefetchTimeout = old })

	pidfile := installHangCommand(t, "nix")
	done := make(chan error, 1)
	go func() {
		_, err := PrefetchHash("https://example.invalid/file.tar.gz")
		done <- err
	}()
	assertHungChildKilled(t, pidfile, done)
}

func TestPrefetchGitHubKillsHungChild(t *testing.T) {
	old := PrefetchTimeout
	PrefetchTimeout = time.Second
	t.Cleanup(func() { PrefetchTimeout = old })

	pidfile := installHangCommand(t, "nix")
	done := make(chan error, 1)
	go func() {
		_, err := PrefetchGitHub("tobi", "qmd", "v0.0.0")
		done <- err
	}()
	assertHungChildKilled(t, pidfile, done)
}
