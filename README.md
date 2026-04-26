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
| [**bird**](https://github.com/steipete/bird) | Fast X CLI for tweeting, replying, and reading |
| [**peekaboo**](https://github.com/steipete/peekaboo) | Lightning-fast macOS screenshots & AI vision analysis |
| [**poltergeist**](https://github.com/steipete/poltergeist) | Universal file watcher with auto-rebuild |
| [**sag**](https://github.com/steipete/sag) | Command-line ElevenLabs TTS with mac-style flags |
| [**imsg**](https://github.com/steipete/imsg) | iMessage/SMS CLI |

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
# etc.

# Linux examples:
inputs.nix-steipete-tools.packages.x86_64-linux.camsnap
inputs.nix-steipete-tools.packages.x86_64-linux.discrawl
inputs.nix-steipete-tools.packages.aarch64-linux.gogcli
inputs.nix-steipete-tools.packages.x86_64-linux.summarize
inputs.nix-steipete-tools.packages.x86_64-linux.wacrawl
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

## License

Tools are packaged as-is from upstream. See individual tool repos for their licenses.

Nix packaging: MIT
