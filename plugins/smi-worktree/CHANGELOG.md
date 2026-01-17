# Changelog

All notable changes to smi-worktree will be documented in this file.

## [0.1.0] - 2026-01-17

### Added

- Initial release
- `/wt create` command with auto-setup (env copying, dep install)
- `/wt list` command to show all worktrees
- `/wt remove` command with optional branch deletion
- `/wt open` command for Cursor/VS Code integration
- Short aliases: `c`, `ls`, `rm`, `o`
- Package manager detection (bun, pnpm, yarn, npm)
- Monorepo detection (workspaces, turbo, nx, lerna)
- Nested `.env*` file copying for monorepos
- worktree-manager skill for auto-triggering
