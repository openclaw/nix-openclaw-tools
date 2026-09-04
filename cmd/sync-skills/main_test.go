package main

import (
	"os"
	"path/filepath"
	"testing"
)

func writeSkill(t *testing.T, root, rel, body string) {
	t.Helper()
	path := filepath.Join(root, rel)
	if err := os.MkdirAll(filepath.Dir(path), 0755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(path, []byte(body), 0644); err != nil {
		t.Fatal(err)
	}
}

func readSkill(t *testing.T, root, rel string) string {
	t.Helper()
	b, err := os.ReadFile(filepath.Join(root, rel))
	if err != nil {
		t.Fatal(err)
	}
	return string(b)
}

func mappingByTool(tool string) (Mapping, bool) {
	for _, m := range skillMappings {
		if m.Tool == tool {
			return m, true
		}
	}
	return Mapping{}, false
}

func TestSkillMappingsIncludeGoplacesAndMovedImsg(t *testing.T) {
	goplaces, ok := mappingByTool("goplaces")
	if !ok {
		t.Fatal("skillMappings missing goplaces")
	}
	if goplaces.Up != "skills/goplaces" {
		t.Fatalf("goplaces.Up = %q", goplaces.Up)
	}

	imsg, ok := mappingByTool("imsg")
	if !ok {
		t.Fatal("skillMappings missing imsg")
	}
	if imsg.Up != "extensions/imessage/skills/imsg" {
		t.Fatalf("imsg.Up = %q, want extensions/imessage/skills/imsg", imsg.Up)
	}
	wantDest := filepath.Join("/repo", "tools", "imsg", "skills", "imsg", "SKILL.md")
	if dest := destSkillPath("/repo", imsg); dest != wantDest {
		t.Fatalf("imsg dest = %q, want %q", dest, wantDest)
	}
}

func TestSyncFromCopiesGoplacesAndMovedImsg(t *testing.T) {
	src := t.TempDir()
	repo := t.TempDir()
	writeSkill(t, src, "skills/goplaces/SKILL.md", "goplaces-upstream")
	writeSkill(t, src, "extensions/imessage/skills/imsg/SKILL.md", "imsg-upstream")
	writeSkill(t, repo, "tools/goplaces/skills/goplaces/SKILL.md", "stale-goplaces")
	writeSkill(t, repo, "tools/imsg/skills/imsg/SKILL.md", "stale-imsg")

	updated, err := syncFrom(src, repo, skillMappings)
	if err != nil {
		t.Fatal(err)
	}
	if !updated {
		t.Fatal("expected updates")
	}
	if got := readSkill(t, repo, "tools/goplaces/skills/goplaces/SKILL.md"); got != "goplaces-upstream" {
		t.Fatalf("goplaces dest = %q", got)
	}
	if got := readSkill(t, repo, "tools/imsg/skills/imsg/SKILL.md"); got != "imsg-upstream" {
		t.Fatalf("imsg dest = %q", got)
	}
}
