---
name: worktree-manager
description: This skill should be used when the user mentions "worktree", "wt", "new branch workspace", "parallel development", "feature branch setup", "work on multiple branches", "separate workspace for branch", or wants to manage git worktrees for parallel feature development.
version: 1.0.0
---

# Git Worktree Manager Skill

Manages git worktrees for parallel development with automatic environment setup.

## Activation Triggers

This skill activates when the user:
- Asks about "worktree" or "git worktree"
- Mentions "wt" in context of git/branches
- Wants to "work on multiple branches simultaneously"
- Needs a "separate workspace for a feature"
- Asks about "parallel development" setup
- Wants to "set up a new branch workspace"

## Commands Reference

| Command | Alias | Description |
|---------|-------|-------------|
| `/wt create <branch>` | `/wt c` | Create worktree with auto-setup |
| `/wt list` | `/wt ls` | Show all worktrees |
| `/wt remove <branch>` | `/wt rm` | Remove worktree |
| `/wt open <branch> [--editor]` | `/wt o` | Open (--cursor\|-c, --agy\|-a, --code\|-v) |

## Naming Convention

Worktrees are created as siblings with `--` separator:

```
~/[PARENT_DIRECTORY]/[REPO_NAME]/              # main repo
~/[PARENT_DIRECTORY]/[REPO_NAME]--[BRANCH_NAME]/   # worktree for [BRANCH_NAME]
```

## Auto-Setup Features

When creating a worktree, the following happens automatically:

1. **Branch handling**: Creates new branch or checks out existing (local/remote)
2. **Env files**: Copies all `.env*` from root and nested directories
3. **Package manager**: Detects bun/pnpm/yarn/npm from lockfiles
4. **Dependencies**: Runs install at root (monorepo-aware)

## Behavioral Expectations

When user asks about worktrees or parallel development:

1. Suggest using `/wt create <branch>` for new worktrees
2. Explain the naming convention if they seem unfamiliar
3. Mention the auto-setup features (env copying, dep install)
4. Show the `cd` command output for easy navigation

## Example Interactions

**User**: "I need to work on the auth feature while keeping my current work"

**Response**: Use `/wt create feature/auth` to create a parallel workspace. This will:
- Create `project--feature-auth/` as sibling directory
- Copy your `.env` files
- Install dependencies

**User**: "Show me my worktrees"

**Response**: Use `/wt ls` to list all worktrees for the current repo.
