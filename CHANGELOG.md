# Changelog

## Unreleased

**Highlights:** Restore automatic tool updates and refresh the packaged releases.

- Restore sag updates after the upstream archive rename and package 0.4.3 using its native Apple Silicon release.
- Refresh nixpkgs to the September 13 snapshot across the root flake and all twelve plugin locks.
- Make camsnap find its packaged ffmpeg when launched directly or through an OpenClaw plugin, without relying on the caller's PATH.
- Refresh nixpkgs, share its pin across all twelve plugins, and use pinned Go toolchains with serialized maintenance workflows and minimum-version CI coverage.
- Keep package expressions intact when an update fails, reject missing or duplicate source fields, and publish successful tool updates even if another upstream fails.
- Restore summarize updates with pnpm 11 lockfiles using the maintained reproducible dependency fetcher and Node 24, and show Nix diagnostics when hash discovery fails.
- Update summarize to 0.21.14, discrawl to 0.15.0, wacrawl to 0.3.12, gogcli to 0.40.0, Peekaboo to 4.3.4, poltergeist to 2.1.7, and imsg to 0.15.4.
- Preserve imsg's resource bundles and bridge helper, and Peekaboo's bundled Swift compatibility library when installing macOS release assets.
- Restore automatic goplaces and imsg skill updates from OpenClaw's current upstream paths (thanks @SebTardif, #20).
- Refresh discrawl and wacrawl skills from their maintained upstream sources, report missing skills, and clean temporary clones after failed or interrupted syncs.
- Bound Git and Nix maintenance commands, clean up their subprocesses on timeout or interruption, and allow deadline overrides or unlimited execution (thanks @SebTardif, #21; incorporates #22).
- Bound GitHub response-header waits while allowing valid slow response bodies to finish (thanks @SebTardif, #17).
- Refresh nixpkgs and the CI installer while preserving upstream Nix; build package checks on all supported systems and test summarize article extraction.
