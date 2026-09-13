package main

import (
	"flag"
	"log"
	"os"
	"time"

	"github.com/openclaw/nix-openclaw-tools/internal"
)

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

	if err := updateSummarize(repoRoot); err != nil {
		log.Fatalf("update summarize failed: %v", err)
	}
	if err := updateQMD(repoRoot); err != nil {
		log.Fatalf("update qmd failed: %v", err)
	}
	for _, tool := range releaseTools(repoRoot) {
		if err := updateTool(tool); err != nil {
			log.Fatalf("update %s failed: %v", tool.Name, err)
		}
	}

}
