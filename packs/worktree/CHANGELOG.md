# Changelog

All notable changes to worktree will be documented in this file.

## [Unreleased]

## [0.5.0] - 2026-02-16

### Changed

- Docker isolation uses env var interpolation instead of override file
  - Patches compose file with `${WT_PORT_*:-default}` and `${WT_CONTAINER_PREFIX:-default}` syntax
  - Writes `WT_PORT_*`, `WT_CONTAINER_PREFIX`, `COMPOSE_PROJECT_NAME` to `.env` next to compose file
  - No more `docker-compose.worktree.yml` override — works with any `docker compose` invocation (including `-f` flags)
  - Patched compose file still works on main (defaults kick in when env vars are absent)
- `wt remove` uses COMPOSE_PROJECT_NAME (not COMPOSE_FILE) for `docker compose down`
- Port parser handles bind-address ports (e.g., `0.0.0.0:8000:8000`)

## [0.3.0] - 2026-02-16

### Added

- `wt init` command — pre-generates `.worktreeinclude` so you can edit before first `wt create`
- `{{PORT:N}}` template in `[rewrite]` section — resolves to base port + docker offset (e.g., `{{PORT:8000}}` with offset 11 → `8011`)
- Default template auto-detects compose file path for `file=` directive
- File copy report now lists each copied file path
- Container name isolation — services with explicit `container_name` get suffixed in worktree override

### Fixed

- Docker compose parser rewritten as indentation-aware state machine — no longer misidentifies `env_file:`, `volumes:`, `depends_on:` as service names
- `.worktreeinclude` auto-detects monorepo dirs with `.env*` files (apps/, packages/, services/) and uncomments matching patterns
- Docker `.env` with COMPOSE_FILE is written next to nested compose files (e.g., `apps/backend/.env`) instead of always at root
- `wt remove` finds COMPOSE_FILE in nested `.env` files for proper `docker compose down`

## [0.2.0] - 2026-02-15

### Added

- `.worktreeinclude` config file — gitignore-style patterns for files to copy
- Auto-generates `.worktreeinclude` with sensible defaults on first `wt create`
- `[rewrite]` section — auto-suffixes DB_NAME, DATABASE_URL, COMPOSE_PROJECT_NAME per branch
- `{{BRANCH}}` template support for custom env var rewriting
- `[docker]` section — docker compose isolation with port offsets
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
