# smi-failure-log

Persistent failure memory system that tracks mistakes and prevents repeating them across sessions.

## Overview

This plugin creates a "learning from mistakes" system for each project. Failures are logged to a local file and automatically injected into context at the start of each session, ensuring the agent never repeats the same mistakes.

## Features

- **Persistent Memory**: Failures survive across sessions in `.claude/failure-log.local.md`
- **Auto-Injection**: Condensed failure summary injected on every prompt
- **Semi-Automatic Capture**: Hooks detect potential failures and prompt for logging
- **Manual Logging**: `/failure-add` command for explicit failure entry
- **Categorized Entries**: Organize by imports, security, testing, architecture, conventions
- **Project-Specific**: Each project maintains its own failure log

## Installation

```bash
/plugin install smi-failure-log
```

## Usage

### Adding Failures

**Manual (recommended for important mistakes):**
```
/failure-add Used relative imports instead of alias pattern in Django
```

**Semi-automatic:**
When the PostToolUse hook detects a potential mistake (error, correction), it will prompt whether to log it.

### Viewing Failures

```
/failure-list              # Show all failures
/failure-list imports      # Filter by category
/failure-list security     # Filter by category
```

### Categories

| Category | Description |
|----------|-------------|
| `imports` | Wrong import patterns |
| `security` | Missing security checks |
| `testing` | Wrong test approaches |
| `architecture` | Structural mistakes |
| `conventions` | Code style violations |

## How It Works

```
┌─────────────────────────────────────────────────┐
│                 FAILURE LOG FLOW                │
├─────────────────────────────────────────────────┤
│                                                 │
│  1. CAPTURE                                     │
│     - Manual: /failure-add "description"        │
│     - Auto: Hook detects errors → prompts       │
│                                                 │
│  2. STORE                                       │
│     - .claude/failure-log.local.md              │
│     - YAML frontmatter + Markdown entries       │
│                                                 │
│  3. INJECT                                      │
│     - UserPromptSubmit hook reads log           │
│     - Condensed summary added to context        │
│     - "AVOID THESE KNOWN MISTAKES: ..."         │
│                                                 │
└─────────────────────────────────────────────────┘
```

## File Format

The failure log is stored at `.claude/failure-log.local.md`:

```markdown
---
enabled: true
last_updated: 2026-01-01T10:30:00Z
---

# Failure Log

## Pattern Mistakes

### [2026-01-01] Wrong import pattern in Django
**Context:** Writing user service
**Mistake:** Used `from users.models import User`
**Correct:** Use `import users.models as _users_models`
**Category:** imports

## Failed Approaches

### [2026-01-01] Mocking database directly
**Context:** Writing unit tests
**What failed:** Mocking ORM breaks fixtures
**Better approach:** Use factory_boy
**Category:** testing
```

## Configuration

### Disabling Injection

To temporarily disable failure injection without deleting the log:

```markdown
---
enabled: false
last_updated: 2026-01-01T10:30:00Z
---
```

### Gitignore

Add to your `.gitignore`:

```
.claude/*.local.md
```

## Components

| Component | Purpose |
|-----------|---------|
| `hooks/hooks.json` | Hook configuration |
| `hooks/scripts/inject-failures.sh` | Reads log, outputs summary |
| `skills/failure-log-manager/` | Knowledge about log format |
| `commands/failure-add.md` | Manual failure entry |
| `commands/failure-list.md` | View logged failures |

## Best Practices

### What to Log

- Pattern violations that recur
- Non-obvious mistakes
- Project-specific conventions
- Security-related errors
- Architecture decisions that failed

### What NOT to Log

- One-time typos
- Linting errors (already caught)
- Generic programming mistakes
- Non-actionable failures

## Troubleshooting

### Failures Not Injecting

1. Check file exists: `.claude/failure-log.local.md`
2. Verify `enabled: true` in frontmatter
3. Restart Claude Code (hooks load at session start)

### Hook Not Detecting Failures

The PostToolUse hook only triggers on Write/Edit operations. For other failures, use `/failure-add` manually.

## License

MIT
