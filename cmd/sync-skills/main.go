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
	workdir, err := os.MkdirTemp("", "clawdbot-skills-")
	if err != nil {
		log.Fatal(err)
	}
	defer os.RemoveAll(workdir)

	mappings := []Mapping{
		{"summarize", "skills/summarize"},
		{"discrawl", "skills/discrawl"},
		{"gogcli", "skills/gog"},
		{"camsnap", "skills/camsnap"},
		{"sonoscli", "skills/sonoscli"},
		{"bird", "skills/bird"},
		{"peekaboo", "skills/peekaboo"},
		{"sag", "skills/sag"},
		{"imsg", "skills/imsg"},
	}

	log.Printf("[sync-skills] cloning clawdbot main")
	if err := run("", "git", "clone", "--depth", "1", "--filter=blob:none", "--sparse", "https://github.com/clawdbot/clawdbot.git", workdir); err != nil {
		log.Fatal(err)
	}
	paths := []string{}
	for _, m := range mappings {
		paths = append(paths, m.Up)
	}
	args := append([]string{"sparse-checkout", "set"}, paths...)
	if err := run(workdir, "git", args...); err != nil {
		log.Fatal(err)
	}

	updated := false
	for _, m := range mappings {
		src := filepath.Join(workdir, m.Up, "SKILL.md")
		dest := filepath.Join(repoRoot, "tools", m.Tool, "skills", filepath.Base(m.Up), "SKILL.md")
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
				log.Fatalf("copy %s -> %s: %v", src, dest, err)
			}
			updated = true
			log.Printf("[sync-skills] updated %s", m.Tool)
		}
	}

	if !updated {
		log.Printf("[sync-skills] no changes")
	}
}
