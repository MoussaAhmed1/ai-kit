---
name: wt
description: Git worktree manager - create, list, remove, and open worktrees with env isolation, Docker port offsets, and database auto-creation
argument-hint: '<command> [branch] [options]'
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/wt.sh:*)"]
---

# Git Worktree Manager

Manage git worktrees with automatic isolation for parallel development.

## Usage

```bash
/wt <command> [args]
```

## Commands

| Command | Alias | Description |
|---------|-------|-------------|
| `create <branch>` | `c` | Create worktree with isolation (env, docker, db) |
| `list` | `ls` | List all worktrees for current repo |
| `remove <branch>` | `rm` | Remove worktree (stops Docker, add `-d` to delete branch) |
| `open <branch> [--editor]` | `o` | Open worktree (--cursor\|-c, --agy\|-a, --code\|-v) |

## Instructions

Run the worktree manager script:

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/wt.sh" $ARGUMENTS
```

## Examples

```bash
# Create worktree for new feature (with full isolation)
/wt create feature/authentication

# Short form
/wt c feat-payments

# List all worktrees
/wt ls

# Remove worktree (stops Docker containers first)
/wt rm feature/authentication

# Remove worktree AND delete branch
/wt rm feat-payments -d

# Open in editor (auto-detect)
/wt o feat-payments

# Open in specific editor
/wt o feat-payments --agy
/wt o feat-payments -c
```

## Naming Convention

```
~/code/retail-plus/              → main repo
~/code/retail-plus--feat-auth/   → worktree (sibling with --)
```

## Auto-Setup on Create

1. Loads `.worktreeinclude` (generates default if missing)
2. Copies files matching glob patterns
3. Rewrites env vars (DB_NAME, DATABASE_URL, etc.) with branch suffix
4. Patches compose file with env var isolation (ports + container names)
5. Auto-creates database in running Postgres
6. Detects package manager (bun → pnpm → yarn → npm)
7. Runs install at root (monorepo-aware)

## `.worktreeinclude` Format

```ini
# File patterns to copy
.env*
apps/*/.env*

[rewrite]
auto                    # suffix DB_NAME, DATABASE_URL, etc.
# MY_DB=app_{{BRANCH}} # template mode

[docker]
auto                    # auto-detect compose file
# file=apps/backend/docker-compose.local.yml
# port_offset=10
```
