---
name: wacrawl
description: Read-only local archive and search for WhatsApp Desktop chats, messages, and media metadata.
homepage: https://github.com/steipete/wacrawl
metadata:
  {
    "openclaw":
      {
        "emoji": "💬",
        "requires": { "bins": ["wacrawl"] },
        "install":
          [
            {
              "id": "brew",
              "kind": "brew",
              "formula": "steipete/tap/wacrawl",
              "bins": ["wacrawl"],
              "label": "Install wacrawl (brew)",
            },
          ],
      },
  }
---

# wacrawl

Use `wacrawl` to snapshot local WhatsApp Desktop data into a separate SQLite archive and search it offline.

## When to Use

Use this skill when the user wants to:

- inspect local WhatsApp Desktop history without opening the app
- archive chats into a local SQLite database for repeat queries
- search WhatsApp messages locally with filters
- list chats, recent messages, or archive status from a read-only import

## Requirements

- local WhatsApp Desktop data on the same machine
- enough local disk for `~/.wacrawl/wacrawl.db`
- understand that this is read-only inspection, not message sending

## Setup

- Default source: `~/Library/Group Containers/group.net.whatsapp.WhatsApp.shared`
- Default archive DB: `~/.wacrawl/wacrawl.db`
- First sanity check:
  - `wacrawl doctor`
- First import:
  - `wacrawl import`

## Common Commands

- Doctor: `wacrawl doctor`
- Import fresh snapshot: `wacrawl import`
- Archive status: `wacrawl status`
- List chats: `wacrawl chats --limit 20`
- Recent messages: `wacrawl messages --limit 20`
- One chat: `wacrawl messages --chat 1234567890@s.whatsapp.net --limit 50`
- Search: `wacrawl search "release notes"`
- Filtered search: `wacrawl --json search "invoice" --from-them --after 2026-01-01`

## Notes

- `wacrawl` is read-only and does not send messages.
- It copies WhatsApp SQLite files into a temp snapshot before import.
- Use `--source` to override the WhatsApp Desktop container path.
- Use `--db` to archive somewhere other than `~/.wacrawl/wacrawl.db`.
