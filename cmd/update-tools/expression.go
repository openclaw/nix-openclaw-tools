package main

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
)

var (
	versionPattern = regexp.MustCompile(`version = "([^"]+)";`)
	urlPattern     = regexp.MustCompile(`url = "[^"]+";`)
	hashPattern    = regexp.MustCompile(`hash = "sha256-[^"]+";`)
)

type nixExpression struct {
	path     string
	original string
	text     string
	mode     os.FileMode
	saved    bool
}

// editPackage commits a complete candidate and rolls back temporary build inputs.
func editPackage(path string, update func(*nixExpression) error) (err error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return err
	}
	info, err := os.Stat(path)
	if err != nil {
		return err
	}
	e := &nixExpression{path: path, original: string(data), text: string(data), mode: info.Mode().Perm()}
	defer func() {
		if err != nil && e.saved {
			if restoreErr := writeAtomic(path, e.original, e.mode); restoreErr != nil {
				err = errors.Join(err, fmt.Errorf("restore %s: %w", path, restoreErr))
			}
		}
	}()
	if err := update(e); err != nil {
		return err
	}
	return e.save()
}

func replaceMatch(text string, pattern *regexp.Regexp, value string) (string, error) {
	matches := pattern.FindAllStringIndex(text, -1)
	if len(matches) != 1 {
		return "", fmt.Errorf("expected one match for %s, found %d", pattern, len(matches))
	}
	match := matches[0]
	return text[:match[0]] + value + text[match[1]:], nil
}

func (e *nixExpression) replace(pattern *regexp.Regexp, value string) error {
	text, err := replaceMatch(e.text, pattern, value)
	if err != nil {
		return fmt.Errorf("%s: %w", e.path, err)
	}
	e.text = text
	return nil
}

func (e *nixExpression) replaceInBlock(block, field *regexp.Regexp, value string) error {
	matches := block.FindAllString(e.text, -1)
	if len(matches) != 1 {
		return fmt.Errorf("%s: expected one block for %s, found %d", e.path, block, len(matches))
	}
	text, err := replaceMatch(matches[0], field, value)
	if err != nil {
		return fmt.Errorf("%s: %w", e.path, err)
	}
	return e.replace(block, text)
}

func (e *nixExpression) setSource(system, url, hash string) error {
	block := regexp.MustCompile(fmt.Sprintf(`(?s)"%s" = \{.*?\};`, regexp.QuoteMeta(system)))
	if err := e.replaceInBlock(block, urlPattern, fmt.Sprintf(`url = "%s";`, url)); err != nil {
		return err
	}
	return e.replaceInBlock(block, hashPattern, fmt.Sprintf(`hash = "%s";`, hash))
}

func (e *nixExpression) save() error {
	if e.text == e.original && !e.saved {
		return nil
	}
	if err := writeAtomic(e.path, e.text, e.mode); err != nil {
		return err
	}
	e.saved = true
	return nil
}

func writeAtomic(path, text string, mode os.FileMode) error {
	file, err := os.CreateTemp(filepath.Dir(path), "."+filepath.Base(path)+"-*")
	if err != nil {
		return err
	}
	defer os.Remove(file.Name())
	defer file.Close()
	if err := file.Chmod(mode); err != nil {
		return err
	}
	if _, err := file.WriteString(text); err != nil {
		return err
	}
	if err := file.Close(); err != nil {
		return err
	}
	return os.Rename(file.Name(), path)
}
