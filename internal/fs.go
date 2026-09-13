package internal

import (
	"fmt"
	"os"
	"regexp"
)

func ReplaceOnce(path string, re *regexp.Regexp, replace string) error {
	return replaceFile(path, re, func(s string) string { return re.ReplaceAllString(s, replace) })
}

func ReplaceOnceFunc(path string, re *regexp.Regexp, fn func(string) string) error {
	return replaceFile(path, re, func(s string) string { return re.ReplaceAllStringFunc(s, fn) })
}

func replaceFile(path string, re *regexp.Regexp, transform func(string) string) error {
	data, err := os.ReadFile(path)
	if err != nil {
		return err
	}
	orig := string(data)
	if !re.MatchString(orig) {
		return fmt.Errorf("pattern not found in %s", path)
	}
	out := transform(orig)
	if out == orig {
		return nil
	}
	return os.WriteFile(path, []byte(out), 0644)
}
