# Changelog

All notable changes to worktree will be documented in this file.

## [Unreleased]

## [0.2.0] - 2026-02-15

### Added

- `.worktreeinclude` config file — gitignore-style patterns for files to copy
- Auto-generates `.worktreeinclude` with sensible defaults on first `wt create`
- `[rewrite]` section — auto-suffixes DB_NAME, DATABASE_URL, COMPOSE_PROJECT_NAME per branch
- `{{BRANCH}}` template support for custom env var rewriting
- `[docker]` section — generates `docker-compose.worktree.yml` with port offsets
- Deterministic port offset via branch name hash (1-100 range)
- Custom compose file path via `file=` directive (supports monorepo nested paths)
- Auto-creates Postgres databases (Docker containers or local)
- `docker compose down` on `wt remove` before removing worktree
- Port mapping summary in create output

### Changed

- `wt create` now uses `.worktreeinclude` patterns instead of hardcoded `.env*` copying
- `wt remove` stops Docker containers and notes that databases are preserved
- `wt help` documents `.worktreeinclude` sections

### Removed

- Hardcoded `copy_env_files()` function (replaced by `.worktreeinclude` pattern matching)

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
