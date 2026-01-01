# smi-dev-loop

Autonomous development loops for iterative coding with automatic continuation.

## Overview

This plugin provides a "dev loop" mechanism that keeps Claude working on a task until completion. Based on the Ralph Wiggum pattern, it uses a Stop hook to intercept Claude's exit and re-feed the original prompt.

## Installation

```bash
/plugin install smi-dev-loop
```

## Commands

### /dev-loop

Start a development loop:

```bash
# Simple usage - just provide your prompt
/dev-loop "Build a user authentication system with login and logout"

# With custom max iterations (default: 50)
/dev-loop "Refactor the database layer" --max-iterations 30

# With custom completion promise (default: DONE)
/dev-loop "Fix all TypeScript errors" --promise "ALL_FIXED"
```

### /cancel-dev

Cancel an active loop:

```bash
/cancel-dev
```

## How It Works

1. **Start**: `/dev-loop "Your prompt"` creates a state file at `.claude/dev-loop.local.md`
2. **Work**: Claude works on your task iteratively
3. **Continue**: When Claude tries to stop, the Stop hook checks if `<promise>DONE</promise>` was output
4. **Complete**: If the promise is found, the loop ends. Otherwise, the prompt is re-fed.
5. **Safety**: After 50 iterations (configurable), the loop stops automatically.

## State File

The loop state is stored in `.claude/dev-loop.local.md`:

```yaml
---
active: true
iteration: 1
max_iterations: 50
completion_promise: "DONE"
started_at: "2026-01-01T00:00:00Z"
---

Your prompt text here
```

## Completion

To end the loop, output the completion promise:

```
<promise>DONE</promise>
```

Or with a custom promise:

```
<promise>YOUR_CUSTOM_PROMISE</promise>
```

## Use Cases

- **TDD Development**: Write tests, implement, refactor until all tests pass
- **Bug Fixing**: Keep working until the bug is resolved
- **Refactoring**: Iteratively improve code structure
- **Feature Building**: Build complex features step by step
- **Code Review Fixes**: Address all review comments

## Combining with Framework Plugins

```bash
# Install loop + Django conventions
/plugin install smi-dev-loop smi-django

# Now use both
/dev-loop "Build a REST API for user management following Django conventions"
```

## Technical Details

- **Hook Type**: Stop hook with bash command
- **State File**: `.claude/dev-loop.local.md` (gitignored)
- **Default Iterations**: 50
- **Default Promise**: "DONE"
