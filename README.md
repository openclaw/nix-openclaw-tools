# nix-openclaw-tools

> Reproducible OpenClaw tool packaging.

Nix packaging for OpenClaw-adjacent tools, with per-tool OpenClaw plugin metadata. Part of the [nix-openclaw](https://github.com/openclaw/nix-openclaw) ecosystem.

Darwin/aarch64 plus Linux (x86_64/aarch64) for tools that ship Linux builds.
On Linux, `summarize` is built from source (Node 24 + pnpm 11.25.0, matching upstream's package manager) since upstream only ships a macOS Bun binary.

## Why this exists

OpenClaw should have a small default toolchain and explicit optional plugins. Packaging these tools as Nix flakes with OpenClaw plugin metadata means:

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
| [**discrawl**](https://github.com/openclaw/discrawl) | Mirror Discord into SQLite and search history locally |
| [**wacrawl**](https://github.com/steipete/wacrawl) | Read-only local archive and search for WhatsApp Desktop data |
| [**gogcli**](https://github.com/openclaw/gogcli) | Google CLI for Gmail, Calendar, Drive, and Contacts |
| [**goplaces**](https://github.com/openclaw/goplaces) | Google Places API (New) CLI |
| [**camsnap**](https://github.com/steipete/camsnap) | Capture snapshots/clips from RTSP/ONVIF cameras |
| [**sonoscli**](https://github.com/steipete/sonoscli) | Control Sonos speakers |
| [**peekaboo**](https://github.com/openclaw/Peekaboo) | Lightning-fast macOS screenshots & AI vision analysis |
| [**poltergeist**](https://github.com/steipete/poltergeist) | Universal file watcher with auto-rebuild |
| [**sag**](https://github.com/steipete/sag) | Command-line ElevenLabs TTS with mac-style flags |
| [**imsg**](https://github.com/openclaw/imsg) | iMessage/SMS CLI |
| [**qmd**](https://github.com/tobi/qmd) | On-device hybrid search for markdown knowledge bases |

## Usage (as openclaw plugins)

Each tool is a subflake under `tools/<tool>/` exporting `openclawPlugin`. Point your nix-openclaw config at the tool you want:

```nix
programs.openclaw.plugins = [
  { source = "github:openclaw/nix-openclaw-tools?dir=tools/camsnap"; }
  { source = "github:openclaw/nix-openclaw-tools?dir=tools/discrawl"; }
  { source = "github:openclaw/nix-openclaw-tools?dir=tools/peekaboo"; }
  { source = "github:openclaw/nix-openclaw-tools?dir=tools/summarize"; }
  { source = "github:openclaw/nix-openclaw-tools?dir=tools/wacrawl"; }
];
```

Each plugin bundles:
- The tool binary (on PATH)
- A skill (SKILL.md) so your bot knows how to use it
- Any required state dirs / env declarations

## Usage (packages only)

If you just want the binaries without the plugin wrapper:

The camsnap executable includes its ffmpeg runtime on PATH, including when you
invoke it directly from the Nix store.

```nix
inputs.nix-openclaw-tools.url = "github:openclaw/nix-openclaw-tools";

# Then use:
inputs.nix-openclaw-tools.packages.aarch64-darwin.camsnap
inputs.nix-openclaw-tools.packages.aarch64-darwin.discrawl
inputs.nix-openclaw-tools.packages.aarch64-darwin.peekaboo
inputs.nix-openclaw-tools.packages.aarch64-darwin.wacrawl
# etc.

# Linux examples:
inputs.nix-openclaw-tools.packages.x86_64-linux.camsnap
inputs.nix-openclaw-tools.packages.x86_64-linux.discrawl
inputs.nix-openclaw-tools.packages.aarch64-linux.gogcli
inputs.nix-openclaw-tools.packages.x86_64-linux.summarize
inputs.nix-openclaw-tools.packages.x86_64-linux.wacrawl
```

## Skills syncing

Ten skills are vendored from [openclaw/openclaw](https://github.com/openclaw/openclaw) main and track its latest content. QMD and poltergeist skills are maintained in this repository.

```bash
go run ./cmd/sync-skills
```

Pulls latest main via sparse checkout, only updates files when contents actually change. The upstream paths are listed in `cmd/sync-skills/main.go`; edit upstream for changes to vendored skills.

## Tool updates

Tools track upstream GitHub releases directly (not Homebrew).

```bash
go run ./cmd/update-tools
```

Fetches latest release versions/URLs/hashes and updates the Nix expressions.

GitHub requests time out after 30 seconds waiting for response headers. Once a
response starts, slow bodies can finish without a whole-request deadline.

QMD is source-packaged because upstream does not publish release assets. Keep it
fresh through the same maintainer automation path, but do not make its smoke
check pull embedding/reranking models; model prewarming belongs in nix-openclaw.

## CI

| Workflow | Schedule | What it does |
|----------|----------|--------------|
| **CI** | Pull requests and pushes to main | Checks Go formatting, vets, tests with the race detector, builds the maintenance commands and package checks on all supported systems, and tests summarize article extraction |
| **sync-skills** | Every 30 min | Pulls latest skills from openclaw main |
| **update-tools** | Every 10 min | Checks for new tool releases |
| **Garnix** | On push | Builds all packages via `checks.*` (darwin + linux) |

Automation commits directly when versions or skills change. The two maintenance
workflows share a concurrency group so their pushes do not overlap. They use Go
1.27.1; CI also tests Go 1.22.12, preserving the module's Go 1.22 minimum.

All plugin flakes follow the root nixpkgs input. After updating the root lock,
refresh the plugin locks with `nix flake update --flake ./tools/<tool>` for each
tool. CI validates all twelve committed plugin locks without updating them.

## License

Tools are packaged as-is from upstream. See individual tool repos for their licenses.

Nix packaging: MIT

## Maintenance deadlines

`sync-skills --git-timeout=5m` bounds each Git command.
`update-tools --prefetch-timeout=10m --build-timeout=45m` bounds each Nix
prefetch and summarize build. These are the defaults; increase them for slow
builders or use `0` to leave a command unlimited. On Linux and macOS, deadline
expiry, Ctrl-C, and SIGTERM terminate the command's process group, including
helpers that retain output pipes. Cancelling a summarize build restores its
package expression and does not start the cross-platform fallback.
