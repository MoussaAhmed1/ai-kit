---
name: wt
description: Git worktree manager - create, list, remove, and open worktrees with automatic env copying and dependency installation
argument-hint: '<command> [branch] [options]'
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/wt.sh:*)"]
---

# Git Worktree Manager

Manage git worktrees with automatic setup for parallel development.

## Usage

```bash
/wt <command> [args]
```

## Commands

| Command | Alias | Description |
|---------|-------|-------------|
| `create <branch>` | `c` | Create worktree, copy .env files, install deps |
| `list` | `ls` | List all worktrees for current repo |
| `remove <branch>` | `rm` | Remove worktree (add `-d` to delete branch) |
| `open <branch> [--editor]` | `o` | Open worktree (--cursor\|-c, --agy\|-a, --code\|-v) |

## Instructions

Run the worktree manager script:

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/wt.sh" $ARGUMENTS
```

## Examples

```bash
# Create worktree for new feature
/wt create feature/authentication

# Short form
/wt c feat-payments

# List all worktrees
/wt ls

# Remove worktree
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

1. Copies all `.env*` files from root
2. Copies nested `.env*` from `apps/*/`, `packages/*/`, `services/*/`
3. Detects package manager (bun → pnpm → yarn → npm)
4. Runs install at root (monorepo-aware)
