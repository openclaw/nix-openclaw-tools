package main

import (
	"bytes"
	"context"
	"errors"
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"path/filepath"
	"time"

	"github.com/openclaw/nix-openclaw-tools/internal"
)

var runTimeout = 5 * time.Minute

type Mapping struct {
	Tool string
	Up   string
}

var skillMappings = []Mapping{
	{"summarize", "skills/summarize"},
	{"discrawl", ".agents/skills/discrawl"},
	{"gogcli", "skills/gog"},
	{"goplaces", "skills/goplaces"},
	{"camsnap", "skills/camsnap"},
	{"sonoscli", "skills/sonoscli"},
	{"peekaboo", "skills/peekaboo"},
	{"sag", "skills/sag"},
	{"imsg", "extensions/imessage/skills/imsg"},
}

type skillSource struct {
	Repo     string
	Mappings []Mapping
}

var skillSources = []skillSource{
	{Repo: "openclaw/openclaw", Mappings: skillMappings},
	{Repo: "openclaw/wacrawl", Mappings: []Mapping{{"wacrawl", ".agents/skills/wacrawl"}}},
}

func destSkillPath(repoRoot string, m Mapping) string {
	return filepath.Join(repoRoot, "tools", m.Tool, "skills", filepath.Base(m.Up), "SKILL.md")
}

func syncFrom(srcRoot, repoRoot string, mappings []Mapping) (bool, error) {
	updated := false
	var missing []error
	for _, m := range mappings {
		src := filepath.Join(srcRoot, m.Up, "SKILL.md")
		dest := destSkillPath(repoRoot, m)
		upstream, err := os.ReadFile(src)
		if errors.Is(err, os.ErrNotExist) {
			log.Printf("[sync-skills] missing %s", src)
			missing = append(missing, fmt.Errorf("read %s: %w", src, err))
			continue
		}
		if err != nil {
			return updated, fmt.Errorf("read %s: %w", src, err)
		}
		local, err := os.ReadFile(dest)
		if err != nil && !errors.Is(err, os.ErrNotExist) {
			return updated, fmt.Errorf("read %s: %w", dest, err)
		}
		if err == nil && bytes.Equal(upstream, local) {
			continue
		}
		if err := copyFile(src, dest); err != nil {
			return updated, fmt.Errorf("copy %s -> %s: %w", src, dest, err)
		}
		updated = true
		log.Printf("[sync-skills] updated %s", m.Tool)
	}
	return updated, errors.Join(missing...)
}

func run(dir string, name string, args ...string) error {
	var out bytes.Buffer
	if err := internal.RunCommand(dir, runTimeout, &out, &out, name, args...); err != nil {
		return fmt.Errorf("%s %v: %w: %s", name, args, err, out.String())
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

func syncSource(repoRoot string, source skillSource) (updated bool, err error) {
	workdir, err := os.MkdirTemp("", "openclaw-skills-")
	if err != nil {
		return false, err
	}
	defer func() {
		if cleanupErr := os.RemoveAll(workdir); cleanupErr != nil {
			err = errors.Join(err, fmt.Errorf("clean clone: %w", cleanupErr))
		}
	}()

	log.Printf("[sync-skills] cloning %s main", source.Repo)
	if err := run("", "git", "clone", "--depth", "1", "--filter=blob:none", "--sparse", "https://github.com/"+source.Repo+".git", workdir); err != nil {
		return false, err
	}
	paths := make([]string, 0, len(source.Mappings))
	for _, m := range source.Mappings {
		paths = append(paths, m.Up)
	}
	args := append([]string{"sparse-checkout", "set"}, paths...)
	if err := run(workdir, "git", args...); err != nil {
		return false, err
	}
	return syncFrom(workdir, repoRoot, source.Mappings)
}

func syncSkills(repoRoot string) error {
	updated := false
	var failures []error
	for _, source := range skillSources {
		changed, err := syncSource(repoRoot, source)
		updated = updated || changed
		if err != nil {
			failures = append(failures, fmt.Errorf("sync %s: %w", source.Repo, err))
			if errors.Is(err, context.Canceled) {
				break
			}
		}
	}
	if len(failures) == 0 && !updated {
		log.Printf("[sync-skills] no changes")
	}
	return errors.Join(failures...)
}

func main() {
	flag.DurationVar(&runTimeout, "git-timeout", 5*time.Minute, "deadline per Git command (0 disables)")
	flag.Parse()
	if runTimeout < 0 {
		log.Fatal("git-timeout must not be negative")
	}
	repoRoot, err := os.Getwd()
	if err != nil {
		log.Fatal(err)
	}
	if err := syncSkills(repoRoot); err != nil {
		log.Fatal(err)
	}
}
