package main

import (
	"bytes"
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
	"path/filepath"
)

type Mapping struct {
	Tool string
	Up   string
}

var skillMappings = []Mapping{
	{"summarize", "skills/summarize"},
	{"discrawl", "skills/discrawl"},
	{"wacrawl", "skills/wacrawl"},
	{"gogcli", "skills/gog"},
	{"goplaces", "skills/goplaces"},
	{"camsnap", "skills/camsnap"},
	{"sonoscli", "skills/sonoscli"},
	{"peekaboo", "skills/peekaboo"},
	{"sag", "skills/sag"},
	{"imsg", "extensions/imessage/skills/imsg"},
}

func destSkillPath(repoRoot string, m Mapping) string {
	return filepath.Join(repoRoot, "tools", m.Tool, "skills", filepath.Base(m.Up), "SKILL.md")
}

func syncFrom(srcRoot, repoRoot string, mappings []Mapping) (bool, error) {
	updated := false
	for _, m := range mappings {
		src := filepath.Join(srcRoot, m.Up, "SKILL.md")
		dest := destSkillPath(repoRoot, m)
		if _, err := os.Stat(src); err != nil {
			log.Printf("[sync-skills] missing %s", src)
			continue
		}
		same := false
		if b1, err1 := os.ReadFile(src); err1 == nil {
			if b2, err2 := os.ReadFile(dest); err2 == nil && bytes.Equal(b1, b2) {
				same = true
			}
		}
		if !same {
			if err := copyFile(src, dest); err != nil {
				return updated, fmt.Errorf("copy %s -> %s: %v", src, dest, err)
			}
			updated = true
			log.Printf("[sync-skills] updated %s", m.Tool)
		}
	}
	return updated, nil
}

func run(dir string, name string, args ...string) error {
	cmd := exec.Command(name, args...)
	cmd.Dir = dir
	var out bytes.Buffer
	cmd.Stdout = &out
	cmd.Stderr = &out
	if err := cmd.Run(); err != nil {
		return fmt.Errorf("%s %v: %v: %s", name, args, err, out.String())
	}
	return nil
}

func copyFile(src, dst string) error {
	in, err := os.Open(src)
	if err != nil {
		return err
	}
	defer in.Close()
	if err := os.MkdirAll(filepath.Dir(dst), 0755); err != nil {
		return err
	}
	out, err := os.Create(dst)
	if err != nil {
		return err
	}
	defer out.Close()
	if _, err := io.Copy(out, in); err != nil {
		return err
	}
	return out.Close()
}

func main() {
	repoRoot, err := os.Getwd()
	if err != nil {
		log.Fatal(err)
	}
	workdir, err := os.MkdirTemp("", "openclaw-skills-")
	if err != nil {
		log.Fatal(err)
	}
	defer os.RemoveAll(workdir)

	log.Printf("[sync-skills] cloning openclaw main")
	if err := run("", "git", "clone", "--depth", "1", "--filter=blob:none", "--sparse", "https://github.com/openclaw/openclaw.git", workdir); err != nil {
		log.Fatal(err)
	}
	paths := []string{}
	for _, m := range skillMappings {
		paths = append(paths, m.Up)
	}
	args := append([]string{"sparse-checkout", "set"}, paths...)
	if err := run(workdir, "git", args...); err != nil {
		log.Fatal(err)
	}

	updated, err := syncFrom(workdir, repoRoot, skillMappings)
	if err != nil {
		log.Fatal(err)
	}
	if !updated {
		log.Printf("[sync-skills] no changes")
	}
}
