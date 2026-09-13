package main

import (
	"context"
	"errors"
	"flag"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/openclaw/nix-openclaw-tools/internal"
)

type toolUpdate struct {
	name string
	run  func() error
}

func runUpdates(updates []toolUpdate) error {
	var failures []error
	for _, update := range updates {
		if err := update.run(); err != nil {
			failures = append(failures, fmt.Errorf("update %s failed: %w", update.name, err))
			if errors.Is(err, context.Canceled) {
				break
			}
		}
	}
	return errors.Join(failures...)
}

func main() {
	flag.DurationVar(&internal.PrefetchTimeout, "prefetch-timeout", 10*time.Minute, "deadline per Nix prefetch (0 disables)")
	flag.DurationVar(&internal.SummarizeTimeout, "build-timeout", 45*time.Minute, "deadline per summarize build (0 disables)")
	flag.Parse()
	if internal.PrefetchTimeout < 0 || internal.SummarizeTimeout < 0 {
		log.Fatal("timeouts must not be negative")
	}
	repoRoot, err := os.Getwd()
	if err != nil {
		log.Fatal(err)
	}

	updates := []toolUpdate{
		{"summarize", func() error { return updateSummarize(repoRoot) }},
		{"qmd", func() error { return updateQMD(repoRoot) }},
	}
	for _, tool := range releaseTools(repoRoot) {
		updates = append(updates, toolUpdate{tool.Name, func() error { return updateTool(tool) }})
	}
	if err := runUpdates(updates); err != nil {
		log.Fatal(err)
	}
}
