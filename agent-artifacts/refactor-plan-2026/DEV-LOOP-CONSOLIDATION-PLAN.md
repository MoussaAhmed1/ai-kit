# Dev Loop Consolidation Plan

**Date**: 2026-01-01
**Goal**: Create standalone `smi-dev-loop` plugin and remove duplicated loop code from framework plugins

---

## Problem

We have **4 nearly identical copies** of loop functionality across plugins:

| Plugin | Duplicated Files |
|--------|------------------|
| smi-django | `hooks/stop-hook.sh`, `scripts/setup-tdd-loop.sh`, `commands/tdd-loop.md`, `commands/cancel-tdd.md`, `hooks/hooks.json` |
| smi-nestjs | `hooks/stop-hook.sh`, `scripts/setup-tdd-loop.sh`, `commands/tdd-loop.md`, `commands/cancel-tdd.md`, `hooks/hooks.json` |
| smi-nextjs | `hooks/stop-hook.sh`, `scripts/setup-dev-loop.sh`, `commands/dev-loop.md`, `commands/cancel-dev.md`, `hooks/hooks.json` |
| smi-nuxtjs | `hooks/stop-hook.sh`, `scripts/setup-dev-loop.sh`, `commands/dev-loop.md`, `commands/cancel-dev.md`, `hooks/hooks.json` |

**Total**: 20 files that are 95%+ identical

---

## Solution

Create a standalone `smi-dev-loop` plugin that provides the loop mechanism once.

### New Plugin Structure

```
plugins/smi-dev-loop/
├── .claude-plugin/
│   └── plugin.json
├── hooks/
│   ├── hooks.json
│   └── stop-hook.sh
├── scripts/
│   └── setup-dev-loop.sh
├── commands/
│   ├── dev-loop.md
│   └── cancel-dev.md
└── README.md
```

### Usage Pattern

```bash
# Install loop functionality + framework conventions
/plugin install smi-dev-loop smi-django

# Use the loop
/dev-loop "Build user authentication with tests"

# Cancel if needed
/cancel-dev
```

---

## Implementation Steps

### Step 1: Create smi-dev-loop Plugin

1. Create directory structure
2. Create `plugin.json`
3. Create `hooks/hooks.json` (Stop hook)
4. Create `hooks/stop-hook.sh` (single source of truth)
5. Create `scripts/setup-dev-loop.sh`
6. Create `commands/dev-loop.md`
7. Create `commands/cancel-dev.md`
8. Create `README.md`

### Step 2: Remove Loop Files from Framework Plugins

**smi-django:**
- Delete `hooks/stop-hook.sh`
- Delete `scripts/setup-tdd-loop.sh`
- Delete `scripts/` directory (if empty)
- Delete `commands/tdd-loop.md`
- Delete `commands/cancel-tdd.md`
- Update `hooks/hooks.json` to empty or remove

**smi-nestjs:**
- Delete `hooks/stop-hook.sh`
- Delete `scripts/setup-tdd-loop.sh`
- Delete `scripts/` directory
- Delete `commands/tdd-loop.md`
- Delete `commands/cancel-tdd.md`
- Update `hooks/hooks.json` to empty or remove

**smi-nextjs:**
- Delete `hooks/stop-hook.sh`
- Delete `scripts/setup-dev-loop.sh`
- Delete `scripts/` directory
- Delete `commands/dev-loop.md`
- Delete `commands/cancel-dev.md`
- Update `hooks/hooks.json` to empty or remove

**smi-nuxtjs:**
- Delete `hooks/stop-hook.sh`
- Delete `scripts/setup-dev-loop.sh`
- Delete `scripts/` directory
- Delete `commands/dev-loop.md`
- Delete `commands/cancel-dev.md`
- Update `hooks/hooks.json` to empty or remove

### Step 3: Update marketplace.json

Add new plugin entry:
```json
{
  "name": "smi-dev-loop",
  "description": "Autonomous development loops for iterative coding",
  "version": "1.0.0",
  "commands": ["dev-loop", "cancel-dev"],
  "hooks": ["Stop"]
}
```

### Step 4: Validate

- Run test suite
- Verify hooks.json format is correct
- Verify scripts are executable

---

## Files Summary

### Files to CREATE (8 files)

| File | Purpose |
|------|---------|
| `plugins/smi-dev-loop/.claude-plugin/plugin.json` | Plugin manifest |
| `plugins/smi-dev-loop/hooks/hooks.json` | Stop hook configuration |
| `plugins/smi-dev-loop/hooks/stop-hook.sh` | Loop continuation logic |
| `plugins/smi-dev-loop/scripts/setup-dev-loop.sh` | Loop initialization |
| `plugins/smi-dev-loop/commands/dev-loop.md` | Start loop command |
| `plugins/smi-dev-loop/commands/cancel-dev.md` | Cancel loop command |
| `plugins/smi-dev-loop/README.md` | Documentation |

### Files to DELETE (20 files)

| Plugin | Files to Delete |
|--------|-----------------|
| smi-django | `hooks/stop-hook.sh`, `hooks/hooks.json`, `scripts/setup-tdd-loop.sh`, `commands/tdd-loop.md`, `commands/cancel-tdd.md` |
| smi-nestjs | `hooks/stop-hook.sh`, `hooks/hooks.json`, `scripts/setup-tdd-loop.sh`, `commands/tdd-loop.md`, `commands/cancel-tdd.md` |
| smi-nextjs | `hooks/stop-hook.sh`, `hooks/hooks.json`, `scripts/setup-dev-loop.sh`, `commands/dev-loop.md`, `commands/cancel-dev.md` |
| smi-nuxtjs | `hooks/stop-hook.sh`, `hooks/hooks.json`, `scripts/setup-dev-loop.sh`, `commands/dev-loop.md`, `commands/cancel-dev.md` |

---

## Result

| Metric | Before | After |
|--------|--------|-------|
| Plugins | 5 | 6 |
| stop-hook.sh copies | 4 | 1 |
| setup scripts | 4 | 1 |
| Loop commands | 8 | 2 |
| Total loop-related files | 20 | 7 |
| Maintenance burden | High (4x) | Low (1x) |

---

## Benefits

1. **Single source of truth** - One stop-hook.sh to maintain
2. **DRY principle** - No code duplication
3. **Independent versioning** - Loop plugin can be updated separately
4. **Optional installation** - Users who don't want loops don't get them
5. **Cleaner framework plugins** - Django plugin focuses on Django, not loop mechanics

---

## Status: ✅ COMPLETED

**Completed**: 2026-01-01

### Actions Taken

1. ✅ Created `plugins/smi-dev-loop/` with complete structure
2. ✅ Created `stop-hook.sh` following Ralph Wiggum pattern (reads transcript, detects promise)
3. ✅ Created `setup-dev-loop.sh` with defaults (50 iterations, DONE promise)
4. ✅ Created `dev-loop.md` and `cancel-dev.md` commands
5. ✅ Created `hooks.json` with correct nested object format
6. ✅ Removed loop files from Django, NestJS, Next.js, Nuxt.js plugins
7. ✅ Removed orphaned hooks directories from framework plugins
8. ✅ Updated `marketplace.json` to version 2.1.0 with 6 plugins
9. ✅ Updated test script to handle utility plugins
10. ✅ All tests passing
