# smi-worktree

Git worktree manager for parallel development with automatic environment setup.

## Features

- **Sibling naming**: `project--branch-name/` convention
- **Auto env copy**: Copies `.env*` from root and nested directories
- **Package manager detection**: bun → pnpm → yarn → npm
- **Monorepo aware**: Detects workspaces, turbo, nx, lerna
- **Editor integration**: Open in Cursor, Antigravity, or VS Code

## Installation

```bash
/plugin install smi-worktree
```

## Usage

### Create Worktree

```bash
/wt create feature/authentication
/wt c feat-payments  # short form
```

Creates worktree at `~/code/project--feature-authentication/` with:
- All `.env*` files copied
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

### Environment Files

Copies from:
- Root: `.env`, `.env.local`, `.env.development`, etc.
- Nested: `apps/*/.env*`, `packages/*/.env*`, `services/*/.env*`

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

## Skill Triggers

The worktree-manager skill auto-activates when you mention:
- "worktree" or "git worktree"
- "parallel development"
- "feature branch setup"
- "work on multiple branches"
- "separate workspace for branch"

## License

MIT
