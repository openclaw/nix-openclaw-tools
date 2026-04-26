---
name: discrawl
description: Mirror Discord guild history into local SQLite and query it offline with search, messages, mentions, reports, and DM wiretap import.
homepage: https://github.com/steipete/discrawl
metadata:
  {
    "openclaw":
      {
        "emoji": "🛰️",
        "requires": { "bins": ["discrawl"] },
        "install":
          [
            {
              "id": "brew",
              "kind": "brew",
              "formula": "steipete/tap/discrawl",
              "bins": ["discrawl"],
              "label": "Install discrawl (brew)",
            },
          ],
      },
  }
---

# discrawl

Use `discrawl` to mirror Discord guild data into local SQLite, then query it offline.

## When to Use

Use this skill when the user wants to:

- search Discord history locally without relying on Discord search
- archive a guild into SQLite for later queries
- inspect recent messages, mentions, channels, or members from a local archive
- import local Discord Desktop cache data for DM recovery/search
- publish or subscribe to a Git-backed Discord archive snapshot

## Requirements

- Discord bot token for guild sync, or an existing OpenClaw Discord config
- local Discord Desktop cache files only if using `wiretap`
- enough local disk for SQLite archive growth

## Setup

- Default config: `~/.discrawl/config.toml`
- Default database: `~/.discrawl/discrawl.db`
- Fastest setup when OpenClaw already has Discord configured:
  - `discrawl init --from-openclaw ~/.openclaw/openclaw.json`
- Env-only setup:
  - `export DISCORD_BOT_TOKEN="..."`
  - `discrawl init`

## Common Commands

- Doctor: `discrawl doctor`
- Initial history: `discrawl sync --full`
- Incremental refresh: `discrawl sync`
- Live tail: `discrawl tail`
- Search: `discrawl search "panic nil pointer"`
- Recent channel messages: `discrawl messages --channel general --hours 24`
- Mentions: `discrawl mentions --user <user-id>`
- DM cache import: `discrawl wiretap`
- Local DM search: `discrawl dms --search "launch checklist"`
- Read-only SQL: `discrawl sql "select count(*) from messages"`
- Git-backed reader mode: `discrawl subscribe <private-repo-url>`

## Notes

- Bot-token sync reads only guilds/channels the bot can access.
- `wiretap` uses local Discord Desktop cache files only; it does not use a user token.
- Prefer `discrawl doctor` before a first sync.
- Use `sync --full` once for backfill, then plain `sync` for routine refreshes.
