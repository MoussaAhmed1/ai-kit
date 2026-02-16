# worktree

Git worktree manager for parallel development with automatic environment isolation.

## Features

- **Sibling naming**: `project--branch-name/` convention
- **`.worktreeinclude`**: Configurable file copying (replaces hardcoded `.env*`)
- **Env rewriting**: Auto-suffixes DB names, URLs, and compose project names per branch
- **Docker isolation**: Port-offset overrides so worktrees don't conflict
- **Database auto-creation**: Creates Postgres databases for rewritten DB names
- **Package manager detection**: bun → pnpm → yarn → npm
- **Monorepo aware**: Detects workspaces, turbo, nx, lerna
- **Editor integration**: Open in Cursor, Antigravity, or VS Code

## Installation

```bash
/plugin install worktree
```

## Quick Start

```bash
/wt create feature/auth
# → Creates worktree at ~/code/project--feature-auth/
# → Copies files per .worktreeinclude
# → Rewrites DB_NAME, DATABASE_URL with branch suffix
# → Generates docker-compose.worktree.yml with offset ports
# → Creates database in running Postgres
# → Installs dependencies
```

## `.worktreeinclude`

Auto-generated on first `wt create` if missing. Commit this file so your team shares the same config.

```ini
# .worktreeinclude — Files to copy to new worktrees
.env*

# Monorepo (uncomment as needed)
# apps/*/.env*
# packages/*/.env*
# services/*/.env*

[rewrite]
auto
# NEXT_PUBLIC_API_URL=http://localhost:{{PORT:8000}}

[docker]
auto
# file=apps/backend/docker-compose.local.yml
# port_offset=10
```

### File Patterns (top section)

Gitignore-style glob patterns for untracked files to copy from main worktree:

```
.env*
apps/*/.env*
config/local.yml
```

### `[rewrite]` — Env Var Isolation

**`auto` mode** detects and suffixes known keys with a branch slug:

| Key | Example | Result |
|-----|---------|--------|
| `DB_NAME` | `myapp` | `myapp_feature_auth` |
| `POSTGRES_DB` | `myapp` | `myapp_feature_auth` |
| `DATABASE_URL` | `postgres://...host/myapp` | `postgres://...host/myapp_feature_auth` |
| `COMPOSE_PROJECT_NAME` | `myapp` | `myapp_feature_auth` |

**Template mode** uses `{{BRANCH}}` and `{{PORT:N}}` for custom vars:

```bash
MY_CUSTOM_DB=app_{{BRANCH}}
REDIS_PREFIX={{BRANCH}}_
NEXT_PUBLIC_API_URL=http://localhost:{{PORT:8000}}
VITE_WS_URL=ws://localhost:{{PORT:3001}}
```

`{{PORT:N}}` adds the docker port offset to base port N (e.g., `{{PORT:8000}}` with offset 11 → `8011`). This keeps frontend env vars in sync with backend docker port offsets.

Both modes work together — template takes precedence over auto.

Branch slug: `feature/auth-v2` → `feature_auth_v2` (lowercase, special chars → `_`, max 30 chars).

### `[docker]` — Docker Compose Isolation

Generates a `docker-compose.worktree.yml` override with port offsets:

- **`auto`**: Auto-detects compose file (`local.yml` → `docker-compose.local.yml` → `docker-compose.yml` → etc.)
- **`file=path`**: Specify compose file path (supports nested monorepo paths)
- **`port_offset=N`**: Override the auto-calculated offset

```ini
[docker]
auto
file=apps/backend/docker-compose.local.yml
```

**How it works:**

1. Parses ports from your compose file
2. Calculates a deterministic offset from branch name (1-100 via `cksum`)
3. Generates `docker-compose.worktree.yml` next to the original
4. Sets `COMPOSE_FILE=original.yml:docker-compose.worktree.yml` in `.env`
5. Sets `COMPOSE_PROJECT_NAME` for container/volume/network isolation

After setup, `docker compose up -d` in the worktree automatically picks up both files.

**Auto-creates databases** in running Postgres containers (Docker or local). Idempotent — safe to run multiple times.

## Usage

### Create Worktree

```bash
/wt create feature/authentication
/wt c feat-payments  # short form
```

Creates worktree at `~/code/project--feature-authentication/` with:
- Files copied per `.worktreeinclude`
- Env vars rewritten with branch suffix
- Docker port offsets applied
- Database created
- Dependencies installed

### List Worktrees

```bash
/wt list
/wt ls  # short form
```

### Remove Worktree

```bash
/wt remove feature/authentication
/wt rm feat-payments -d  # also delete branch
```

Stops Docker containers before removing. Databases are preserved (drop manually if no longer needed).

### Open in Editor

```bash
/wt open feat-payments           # auto-detect
/wt o feat-payments              # short form
/wt o feat-payments --cursor     # or -c
/wt o feat-payments --agy        # or -a
/wt o feat-payments --code       # or -v
```

### Set Default Editor

Add to your shell profile (`~/.zshrc` or `~/.bashrc`):

```bash
export WT_EDITOR=agy  # cursor, agy, or code
```

Priority: flag > `WT_EDITOR` > auto-detect (Cursor → Antigravity → VS Code)

## Naming Convention

```
~/code/retail-plus/              # main repo
~/code/retail-plus--feat-auth/   # worktree (sibling with --)
~/code/retail-plus--fix-bug-123/ # another worktree
```

## Auto-Setup Details

### Package Manager Detection

Checks in order:
1. `bun.lockb` or `bun.lock` → `bun install`
2. `pnpm-lock.yaml` → `pnpm install`
3. `yarn.lock` → `yarn install`
4. `package-lock.json` or `package.json` → `npm install`

### Monorepo Detection

Detects via:
- `pnpm-workspace.yaml`
- `turbo.json`
- `nx.json`
- `lerna.json`
- `"workspaces"` in `package.json`

### Compose File Detection Order

When `[docker] auto` is set and no `file=` specified:

1. `local.yml`
2. `docker-compose.local.yml`
3. `docker-compose.yml`
4. `docker-compose.yaml`
5. `compose.yml`
6. `compose.yaml`

Also searches `apps/*/` and `services/*/` subdirectories.

## Skill Triggers

The worktree-manager skill auto-activates when you mention:
- "worktree" or "git worktree"
- "parallel development"
- "feature branch setup"
- "work on multiple branches"
- "separate workspace for branch"
- "docker port conflict" or "database isolation"
- "worktreeinclude" or "env isolation"

## License

MIT
