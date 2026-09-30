package internal

import (
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
)

func TestPublishUpdates(t *testing.T) {
	script, err := filepath.Abs("../scripts/publish-updates.sh")
	if err != nil {
		t.Fatal(err)
	}
	for _, tc := range []struct {
		name          string
		changed       bool
		pushFails     bool
		dispatchFails bool
	}{
		{name: "unchanged"},
		{name: "changed", changed: true},
		{name: "failed push", changed: true, pushFails: true},
		{name: "failed dispatch", changed: true, dispatchFails: true},
	} {
		t.Run(tc.name, func(t *testing.T) {
			dir := t.TempDir()
			remote := filepath.Join(dir, "remote.git")
			checkout := filepath.Join(dir, "checkout")
			bin := filepath.Join(dir, "bin")
			if err := os.Mkdir(bin, 0o755); err != nil {
				t.Fatal(err)
			}
			log := filepath.Join(dir, "dispatch")
			// Dispatch must observe the new commit in the remote, not merely locally.
			gh := "#!/bin/sh\nset -eu\ntest \"$(git rev-parse HEAD)\" = \"$(git ls-remote origin refs/heads/main | cut -f1)\"\nprintf '%s\\n' \"$*\" > \"$DISPATCH_LOG\"\nexit \"$DISPATCH_EXIT\"\n"
			if err := os.WriteFile(filepath.Join(bin, "gh"), []byte(gh), 0o755); err != nil {
				t.Fatal(err)
			}
			dispatchExit := "0"
			if tc.dispatchFails {
				dispatchExit = "1"
			}
			env := append(os.Environ(), "PATH="+bin+string(os.PathListSeparator)+os.Getenv("PATH"),
				"GIT_CONFIG_GLOBAL=/dev/null", "GIT_CONFIG_NOSYSTEM=1", "GIT_TERMINAL_PROMPT=0",
				"GITHUB_REPOSITORY=openclaw/nix-openclaw-tools", "DISPATCH_LOG="+log, "DISPATCH_EXIT="+dispatchExit)
			git := func(args ...string) {
				t.Helper()
				cmd := exec.Command("git", args...)
				cmd.Dir = dir
				cmd.Env = env
				if output, err := cmd.CombinedOutput(); err != nil {
					t.Fatalf("git %v: %v\n%s", args, err, output)
				}
			}
			git("init", "--bare", remote)
			git("init", "-b", "main", checkout)
			dir = checkout
			git("config", "user.name", "Test")
			git("config", "user.email", "test@example.invalid")
			file := filepath.Join(checkout, "package.nix")
			if err := os.WriteFile(file, []byte("before\n"), 0o644); err != nil {
				t.Fatal(err)
			}
			git("add", "package.nix")
			git("commit", "-m", "fixture")
			git("remote", "add", "origin", remote)
			git("push", "-u", "origin", "main")
			if tc.changed {
				if err := os.WriteFile(file, []byte("after\n"), 0o644); err != nil {
					t.Fatal(err)
				}
			}
			if tc.pushFails {
				git("remote", "set-url", "origin", filepath.Join(checkout, "missing.git"))
			}
			cmd := exec.Command("bash", script, "chore: update fixture")
			cmd.Dir = checkout
			cmd.Env = env
			output, err := cmd.CombinedOutput()
			wantFailure := tc.pushFails || tc.dispatchFails
			if (err != nil) != wantFailure {
				t.Fatalf("publish error = %v, want failure %v\n%s", err, wantFailure, output)
			}
			dispatch, err := os.ReadFile(log)
			wantDispatch := tc.changed && !tc.pushFails
			if !wantDispatch {
				if !os.IsNotExist(err) {
					t.Fatalf("unexpected dispatch: %q, error %v", dispatch, err)
				}
				return
			}
			if err != nil {
				t.Fatalf("CI was not dispatched after publishing changes: %v\n%s", err, output)
			}
			if got, want := strings.TrimSpace(string(dispatch)), "workflow run ci.yml --repo openclaw/nix-openclaw-tools --ref main"; got != want {
				t.Fatalf("dispatch = %q, want %q", got, want)
			}
		})
	}
}
