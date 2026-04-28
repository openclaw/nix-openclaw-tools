# nix-steipete-tools

> Core tools for openclaw. Batteries included. Always fresh.

Nix packaging for [Peter Steinberger's](https://github.com/steipete) tools, with per-tool openclaw plugins. Part of the [nix-openclaw](https://github.com/openclaw/nix-openclaw) ecosystem.

Darwin/aarch64 plus Linux (x86_64/aarch64) for tools that ship Linux builds.
On Linux, `summarize` is built from source (Node 22 + pnpm) since upstream only ships a macOS Bun binary.

## Why this exists

These tools are essential for a capable openclaw instance - screen capture, camera access, TTS, messaging. Packaging them as Nix flakes with openclaw plugin metadata means:

- **Reproducible**: Pinned versions, no Homebrew drift
- **Declarative**: Add a plugin, `home-manager switch`, done
- **Fresh**: CI keeps tools and skills at latest automatically
- **Integrated**: Skills teach your bot how to use each tool

## Pure Nix and Home Manager design

This repo is meant to be consumable directly from Nix flakes, Darwin, and Home
Manager configs. Packages should stay pinned and reproducible, and optional
Home Manager modules should expose normal `programs.<name>` options instead of
requiring downstream users to hand-write app bundle or launchd glue.

For macOS app bundles, prefer a Nix package plus Home Manager integration. Home
Manager can expose app bundles from `home.packages` through its Darwin app
targets, and modules can opt into `launchd.agents` when Home Manager should own
startup. Homebrew casks are still useful, but they belong in a nix-darwin
Homebrew configuration, not in these pure Nix package/module definitions.

## What's included

| Tool | What it does |
|------|--------------|
| [**summarize**](https://github.com/steipete/summarize) | Link → clean text → summary |
| [**discrawl**](https://github.com/steipete/discrawl) | Mirror Discord into SQLite and search history locally |
| [**wacrawl**](https://github.com/steipete/wacrawl) | Read-only local archive and search for WhatsApp Desktop data |
| [**gogcli**](https://github.com/steipete/gogcli) | Google CLI for Gmail, Calendar, Drive, and Contacts |
| [**goplaces**](https://github.com/steipete/goplaces) | Google Places API (New) CLI |
| [**camsnap**](https://github.com/steipete/camsnap) | Capture snapshots/clips from RTSP/ONVIF cameras |
| [**sonoscli**](https://github.com/steipete/sonoscli) | Control Sonos speakers |
| [**peekaboo**](https://github.com/steipete/peekaboo) | Lightning-fast macOS screenshots & AI vision analysis |
| [**poltergeist**](https://github.com/steipete/poltergeist) | Universal file watcher with auto-rebuild |
| [**sag**](https://github.com/steipete/sag) | Command-line ElevenLabs TTS with mac-style flags |
| [**imsg**](https://github.com/steipete/imsg) | iMessage/SMS CLI |
| [**CodexBar**](https://github.com/steipete/CodexBar) | macOS menu bar app for Codex, Claude, and other provider usage |
| [**RepoBar**](https://github.com/steipete/RepoBar) | macOS menu bar app for GitHub CI, PRs, and releases |
| [**Trimmy**](https://github.com/steipete/Trimmy) | macOS menu bar app for flattening multi-line shell snippets |

## Usage (as openclaw plugins)

Each tool is a subflake under `tools/<tool>/` exporting `openclawPlugin`. Point your nix-openclaw config at the tool you want:

```nix
programs.openclaw.plugins = [
  { source = "github:openclaw/nix-steipete-tools?dir=tools/camsnap"; }
  { source = "github:openclaw/nix-steipete-tools?dir=tools/discrawl"; }
  { source = "github:openclaw/nix-steipete-tools?dir=tools/peekaboo"; }
  { source = "github:openclaw/nix-steipete-tools?dir=tools/summarize"; }
  { source = "github:openclaw/nix-steipete-tools?dir=tools/wacrawl"; }
];
```

Each plugin bundles:
- The tool binary (on PATH)
- A skill (SKILL.md) so your bot knows how to use it
- Any required state dirs / env declarations

## Usage (packages only)

If you just want the binaries without the plugin wrapper:

```nix
inputs.nix-steipete-tools.url = "github:openclaw/nix-steipete-tools";

# Then use:
inputs.nix-steipete-tools.packages.aarch64-darwin.camsnap
inputs.nix-steipete-tools.packages.aarch64-darwin.discrawl
inputs.nix-steipete-tools.packages.aarch64-darwin.peekaboo
inputs.nix-steipete-tools.packages.aarch64-darwin.wacrawl
inputs.nix-steipete-tools.packages.aarch64-darwin.codexbar-app
inputs.nix-steipete-tools.packages.aarch64-darwin.repobar-app
inputs.nix-steipete-tools.packages.aarch64-darwin.trimmy-app
# etc.

# Linux examples:
inputs.nix-steipete-tools.packages.x86_64-linux.camsnap
inputs.nix-steipete-tools.packages.x86_64-linux.discrawl
inputs.nix-steipete-tools.packages.aarch64-linux.gogcli
inputs.nix-steipete-tools.packages.x86_64-linux.summarize
inputs.nix-steipete-tools.packages.x86_64-linux.wacrawl
```

### Home Manager modules

Some packages also ship Home Manager modules so they can be enabled directly
without hand-writing install and launchd wiring. For CodexBar, RepoBar, and
Trimmy:

```nix
{
  imports = [
    inputs.nix-steipete-tools.homeManagerModules.codexbar
    inputs.nix-steipete-tools.homeManagerModules.repobar
    inputs.nix-steipete-tools.homeManagerModules.trimmy
  ];

  programs.codexbar.enable = true;
  programs.repobar.enable = true;
  programs.trimmy.enable = true;
}
```

That adds the app packages to `home.packages`. Home Manager can then expose the
app bundles through its Darwin app targets. If you want Home Manager to own
startup too, enable each launchd agent explicitly:

```nix
{
  programs.codexbar = {
    enable = true;
    launchd.enable = true;
    launchd.keepAlive = false;
  };

  programs.repobar = {
    enable = true;
    launchd.enable = true;
    launchd.keepAlive = false;
  };

  programs.trimmy = {
    enable = true;
    launchd.enable = true;
    launchd.keepAlive = false;
  };
}
```

### macOS app bundles

If you only want the raw app package, use the package output directly:

```nix
inputs.nix-steipete-tools.packages.aarch64-darwin.codexbar-app
inputs.nix-steipete-tools.packages.aarch64-darwin.repobar-app
inputs.nix-steipete-tools.packages.aarch64-darwin.trimmy-app
```

## Skills syncing

Skills are vendored from [openclaw/openclaw](https://github.com/openclaw/openclaw) main branch. No pinning - we track latest.

```bash
go run ./cmd/sync-skills
```

Pulls latest main via sparse checkout, only updates files when contents actually change.

## Tool updates

Tools track upstream GitHub releases directly (not Homebrew).

```bash
go run ./cmd/update-tools
```

Fetches latest release versions/URLs/hashes and updates the Nix expressions.

## CI

| Workflow | Schedule | What it does |
|----------|----------|--------------|
| **sync-skills** | Every 30 min | Pulls latest skills from openclaw main |
| **update-tools** | Every 10 min | Checks for new tool releases |
| **Garnix** | On push | Builds all packages via `checks.*` (darwin + linux) |

Automated PRs keep everything fresh without manual intervention.

## Temporarily disabled

`bird` is not exported right now because the upstream GitHub release assets for
v0.8.0 are gone. The npm package still exists, but this flake does not currently
build npm dependencies for it.

## License

Tools are packaged as-is from upstream. See individual tool repos for their licenses.

Nix packaging: MIT
