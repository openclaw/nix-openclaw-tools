package main

import (
	"os"
	"path/filepath"
	"strings"
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

func TestSyncFromCopiesAvailableSkillsAndReportsMissing(t *testing.T) {
	src := t.TempDir()
	repo := t.TempDir()
	writeSkill(t, src, "skills/goplaces/SKILL.md", "goplaces-upstream")
	writeSkill(t, src, "extensions/imessage/skills/imsg/SKILL.md", "imsg-upstream")
	writeSkill(t, repo, "tools/goplaces/skills/goplaces/SKILL.md", "stale-goplaces")
	writeSkill(t, repo, "tools/imsg/skills/imsg/SKILL.md", "stale-imsg")

	updated, err := syncFrom(src, repo, skillMappings)
	if err == nil || !strings.Contains(err.Error(), "skills/summarize") {
		t.Fatalf("expected missing upstream skill error, got %v", err)
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

func TestDiscrawlMappingUsesCurrentUpstreamPath(t *testing.T) {
	mapping, ok := mappingByTool("discrawl")
	if !ok || mapping.Up != ".agents/skills/discrawl" {
		t.Fatalf("discrawl mapping = %#v", mapping)
	}
}

func TestSyncCurrentArchiveSkillsAndRepeat(t *testing.T) {
	dest := t.TempDir()
	for _, source := range skillSources {
		src := t.TempDir()
		for _, mapping := range source.Mappings {
			writeSkill(t, src, filepath.Join(mapping.Up, "SKILL.md"), source.Repo+":"+mapping.Tool)
		}
		updated, err := syncFrom(src, dest, source.Mappings)
		if err != nil || !updated {
			t.Fatalf("first sync: updated=%t, err=%v", updated, err)
		}
		updated, err = syncFrom(src, dest, source.Mappings)
		if err != nil || updated {
			t.Fatalf("repeat sync: updated=%t, err=%v", updated, err)
		}
	}
	for tool, want := range map[string]string{"discrawl": "openclaw/openclaw:discrawl", "wacrawl": "openclaw/wacrawl:wacrawl"} {
		if got := readSkill(t, dest, "tools/"+tool+"/skills/"+tool+"/SKILL.md"); got != want {
			t.Fatalf("%s = %q, want %q", tool, got, want)
		}
	}
}

func TestSyncReportsUnreadableSource(t *testing.T) {
	src := t.TempDir()
	if err := os.MkdirAll(filepath.Join(src, "skills/tool/SKILL.md"), 0o755); err != nil {
		t.Fatal(err)
	}
	if _, err := syncFrom(src, t.TempDir(), []Mapping{{"tool", "skills/tool"}}); err == nil {
		t.Fatal("expected source read error, not a silent missing-skill skip")
	}
}
