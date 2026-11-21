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
	for _, mode := range []string{"success", "stale-base", "dispatch-failure", "missing-run", "pending", "ci-failure", "wrong-ci-head", "blocked-merge", "wrong-pr-head", "wrong-tree", "main-dispatch-failure"} {
		t.Run(mode, func(t *testing.T) {
			dir := t.TempDir()
			checkout := filepath.Join(dir, "checkout")
			remote := filepath.Join(dir, "remote.git")
			bin := filepath.Join(dir, "bin")
			for _, path := range []string{checkout, bin} {
				if err := os.Mkdir(path, 0o755); err != nil {
					t.Fatal(err)
				}
			}
			env := append(os.Environ(), "PATH="+bin+string(os.PathListSeparator)+os.Getenv("PATH"),
				"GIT_CONFIG_GLOBAL=/dev/null", "GIT_CONFIG_NOSYSTEM=1", "GIT_TERMINAL_PROMPT=0",
				"GITHUB_REPOSITORY=openclaw/nix-openclaw-tools", "MODE="+mode,
				"CALL_LOG="+filepath.Join(dir, "calls"), "RUN_REF="+filepath.Join(dir, "ref"))
			git := func(args ...string) string {
				t.Helper()
				cmd := exec.Command("git", args...)
				cmd.Dir, cmd.Env = checkout, env
				output, err := cmd.CombinedOutput()
				if err != nil {
					t.Fatalf("git %v: %v\n%s", args, err, output)
				}
				return strings.TrimSpace(string(output))
			}
			git("init", "--bare", remote)
			git("init", "-b", "main")
			git("config", "user.name", "Test")
			git("config", "user.email", "test@example.invalid")
			git("config", "commit.gpgsign", "false")
			file := filepath.Join(checkout, "package.nix")
			write := func(path, contents string, mode os.FileMode) {
				t.Helper()
				if err := os.WriteFile(path, []byte(contents), mode); err != nil {
					t.Fatal(err)
				}
			}
			write(file, "before\n", 0o644)
			git("add", "package.nix")
			git("commit", "-m", "fixture")
			base := git("rev-parse", "HEAD")
			git("remote", "add", "origin", remote)
			git("push", "-u", "origin", "main")
			git("switch", "-c", "automation/update-tools")
			write(file, "after\n", 0o644)
			git("commit", "-am", "candidate")
			head := git("rev-parse", "HEAD")
			git("push", "origin", "HEAD")
			git("switch", "main")
			env = append(env, "EXPECTED_HEAD="+head)
			if mode == "stale-base" {
				write(filepath.Join(checkout, "unrelated"), "new main\n", 0o644)
				git("add", "unrelated")
				git("commit", "-m", "concurrent change")
				git("push", "origin", "main")
			}
			write(filepath.Join(bin, "sleep"), "#!/bin/sh\nexit 0\n", 0o755)
			write(filepath.Join(bin, "gh"), `#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >> "$CALL_LOG"
case "$1 $2" in
  'workflow run')
    ref=${@: -1}
    [[ $MODE != dispatch-failure ]]
    [[ $MODE != main-dispatch-failure || $ref != main ]]
    printf '%s' "$ref" > "$RUN_REF"
    ;;
  'run list')
    [[ "$*" == *'--event workflow_dispatch'* && "$*" == *'--commit '* ]]
    [[ $MODE != missing-run ]] || exit 0
    if [[ $(cat "$RUN_REF") == main ]]; then echo 22; else echo 21; fi
    ;;
  'api repos/openclaw/nix-openclaw-tools/git/ref/heads/main')
    git ls-remote origin refs/heads/main | cut -f1
    ;;
  'api repos/openclaw/nix-openclaw-tools/actions/runs/21')
    head=$EXPECTED_HEAD
    [[ $MODE != wrong-ci-head ]] || head=wrong
    status=completed
    conclusion=success
    [[ $MODE != pending ]] || status=in_progress
    [[ $MODE != ci-failure ]] || conclusion=failure
    printf 'workflow_dispatch\t%s\t%s\t%s\n' "$head" "$status" "$conclusion"
    ;;
  'pr merge')
    [[ $MODE != blocked-merge ]]
    [[ "$*" == *"--squash --match-head-commit $EXPECTED_HEAD" ]]
    git merge --squash automation/update-tools >&2
    [[ $MODE != wrong-tree ]] || printf 'wrong\n' > package.nix
    git add package.nix
    git commit -m 'squashed publication' >&2
    git push origin main >&2
    ;;
  'api repos/openclaw/nix-openclaw-tools/pulls/7')
    head=$EXPECTED_HEAD
    [[ $MODE != wrong-pr-head ]] || head=wrong
    printf 'true\t%s\t%s\n' "$head" "$(git rev-parse main)"
    ;;
  *) echo "Unexpected gh request: $*" >&2; exit 2 ;;
esac
`, 0o755)
			cmd := exec.Command("bash", script, "7", head, base, "automation/update-tools", "package.nix")
			cmd.Dir, cmd.Env = checkout, env
			output, err := cmd.CombinedOutput()
			if (err == nil) != (mode == "success") {
				t.Fatalf("mode=%s error=%v\n%s", mode, err, output)
			}
			calls, _ := os.ReadFile(filepath.Join(dir, "calls"))
			merged := strings.Contains(string(calls), "pr merge ") && mode != "blocked-merge"
			wantMerged := mode == "success" || mode == "wrong-pr-head" || mode == "wrong-tree" || mode == "main-dispatch-failure"
			if merged != wantMerged {
				t.Fatalf("merged=%v want=%v\n%s", merged, wantMerged, calls)
			}
			mainDispatched := strings.Contains(string(calls), "workflow run ci.yml --repo openclaw/nix-openclaw-tools --ref main")
			if mainDispatched != (mode == "success" || mode == "main-dispatch-failure") {
				t.Fatalf("unexpected main dispatch\n%s", calls)
			}
			if mode == "success" {
				if head == git("rev-parse", "main") {
					t.Fatal("fixture must exercise squash with a distinct merge SHA")
				}
				if !strings.Contains(string(output), "Published https://github.com/") {
					t.Fatalf("missing publication receipt: %s", output)
				}
			}
		})
	}
}
