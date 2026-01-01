# Ralph Wiggum Comparison & Fix Plan

**Date**: 2026-01-01
**Goal**: Align our hooks and TDD loop with official Ralph Wiggum implementation

---

## Executive Summary

Our current implementation has **critical structural issues** that prevent the hooks and TDD loops from actually working. The official Ralph Wiggum plugin uses a fundamentally different architecture that we need to adopt.

### Critical Issues Found

| Issue | Our Implementation | Official Implementation | Impact |
|-------|-------------------|------------------------|--------|
| hooks.json format | Array of objects with `event` key | Nested object with event names as keys | **BREAKING** - Hooks won't load |
| Stop hook type | `type: "prompt"` (markdown) | `type: "command"` (bash script) | **BREAKING** - Can't return JSON decisions |
| Loop state file | None | `.claude/ralph-loop.local.md` | **BREAKING** - No loop state tracking |
| Setup script | None | `scripts/setup-ralph-loop.sh` | **BREAKING** - Can't initialize loops |
| Transcript reading | None | Reads JSONL transcript for output | **BREAKING** - Can't detect completion |

---

## Part 1: Official Ralph Wiggum Structure Analysis

### Directory Structure

```
ralph-wiggum/
├── .claude-plugin/
│   └── plugin.json              # Minimal: name, description, author
├── commands/
│   ├── cancel-ralph.md          # Cancel loop (bash + instructions)
│   ├── help.md                  # Documentation
│   └── ralph-loop.md            # Start loop (runs setup script)
├── hooks/
│   ├── hooks.json               # ONLY "Stop" hook → bash script
│   └── stop-hook.sh             # Core loop logic (bash)
├── scripts/
│   └── setup-ralph-loop.sh      # Creates state file
└── README.md
```

### Key Design Patterns

#### 1. hooks.json Format (Official)

```json
{
  "description": "Ralph Wiggum plugin stop hook for self-referential loops",
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/stop-hook.sh"
          }
        ]
      }
    ]
  }
}
```

**Key Points:**
- Root has `description` and `hooks`
- `hooks` is an OBJECT with event names as keys
- Each event has an ARRAY of hook groups
- Each group has `hooks` array with actual hook definitions
- Uses `type: "command"` for bash scripts

#### 2. Stop Hook Bash Script Pattern

The `stop-hook.sh`:
1. Reads hook input from stdin (JSON with `transcript_path`)
2. Checks for state file (`.claude/ralph-loop.local.md`)
3. If no state file → exit 0 (allow normal exit)
4. Parses YAML frontmatter for iteration, max_iterations, completion_promise
5. Reads transcript file to get Claude's last output
6. Checks for `<promise>COMPLETION_TEXT</promise>` tag
7. If promise found or max iterations → delete state file, exit 0
8. Otherwise → output JSON with `decision: "block"` and prompt as `reason`

**JSON Output to Block Exit:**
```json
{
  "decision": "block",
  "reason": "The original prompt text",
  "systemMessage": "🔄 Ralph iteration N | To stop: output <promise>X</promise>"
}
```

#### 3. State File Format

`.claude/ralph-loop.local.md`:
```markdown
---
active: true
iteration: 1
max_iterations: 20
completion_promise: "DONE"
started_at: "2026-01-01T00:00:00Z"
---

The actual prompt text goes here.
This is what gets re-fed on each iteration.
```

#### 4. Command Pattern (with bash execution)

```yaml
---
description: "Start Ralph Wiggum loop in current session"
argument-hint: "PROMPT [--max-iterations N] [--completion-promise TEXT]"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh)"]
hide-from-slash-command-tool: "true"
---
```

Uses bash execution block:
```markdown
```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh" $ARGUMENTS
```
```

---

## Part 2: Our Current Implementation Problems

### Problem 1: Wrong hooks.json Format

**Ours (WRONG):**
```json
{
  "hooks": [
    {
      "event": "Stop",
      "type": "prompt",
      "prompt": "${CLAUDE_PLUGIN_ROOT}/hooks/tdd-loop-controller.md"
    }
  ]
}
```

**Should Be:**
```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/stop-hook.sh"
          }
        ]
      }
    ]
  }
}
```

### Problem 2: Using Prompts Instead of Commands for Stop

Stop hooks MUST use bash scripts that can:
- Read stdin for hook input
- Check state files
- Read transcripts
- Return JSON with `decision` field

Markdown prompts CANNOT do this.

### Problem 3: No State File Management

We have no mechanism to:
- Create `.claude/tdd-loop.local.md` when starting
- Track iteration count
- Store the original prompt
- Store completion criteria

### Problem 4: No Transcript Reading

The stop hook must read Claude's output from the transcript file to detect completion promises. We have no code for this.

### Problem 5: TDD Command Doesn't Actually Loop

Our `tdd-loop.md` is just documentation about TDD. It doesn't:
- Run a setup script
- Create a state file
- Integrate with stop hooks

---

## User Requirements

**Simplicity First:**
- **Default 50 iterations** - No need to specify unless you want fewer
- **Simple command format**: `/tdd-loop "Your prompt here"` - that's it!
- **Sensible defaults**: Promise = "DONE", Max iterations = 50
- Optional flags only when you need to override defaults

---

## Part 3: Implementation Plan

### Phase A: Fix Core Hook Infrastructure (All Plugins)

#### A.1 Create Stop Hook Bash Scripts

For each plugin that needs loops (Django, NestJS, Next.js, Nuxt.js):

**File**: `plugins/smi-django/hooks/stop-hook.sh`

```bash
#!/bin/bash
# TDD Loop Stop Hook
# Based on Ralph Wiggum pattern

set -euo pipefail

HOOK_INPUT=$(cat)
STATE_FILE=".claude/tdd-loop.local.md"

# No active loop - allow exit
if [[ ! -f "$STATE_FILE" ]]; then
  exit 0
fi

# Parse state file...
# Read transcript...
# Check for completion...
# Return decision JSON...
```

#### A.2 Fix hooks.json Format

**File**: `plugins/smi-django/hooks/hooks.json`

```json
{
  "description": "Smicolon Django plugin hooks",
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/stop-hook.sh"
          }
        ]
      }
    ]
  }
}
```

**Note**: Remove other hook events for now (UserPromptSubmit, PreToolUse, etc.) - focus on getting Stop working first. Those can be added later using the prompt type for non-blocking hooks.

#### A.3 Create Setup Scripts

**File**: `plugins/smi-django/scripts/setup-tdd-loop.sh`

```bash
#!/bin/bash
# TDD Loop Setup Script
# Simple usage: /tdd-loop "Your prompt here"

set -euo pipefail

# DEFAULTS - User just provides the prompt, everything else is optional
MAX_ITERATIONS=50          # Default: 50 iterations
COMPLETION_PROMISE="DONE"  # Default: output <promise>DONE</promise> to complete
PROMPT=""

# Parse arguments - prompt is first positional arg, rest are optional flags
while [[ $# -gt 0 ]]; do
  case $1 in
    --max-iterations)
      MAX_ITERATIONS="$2"
      shift 2
      ;;
    --promise)
      COMPLETION_PROMISE="$2"
      shift 2
      ;;
    *)
      # First non-flag argument is the prompt
      if [[ -z "$PROMPT" ]]; then
        PROMPT="$1"
      else
        PROMPT="$PROMPT $1"
      fi
      shift
      ;;
  esac
done

# Create state file
mkdir -p .claude
cat > .claude/tdd-loop.local.md <<EOF
---
active: true
iteration: 1
max_iterations: $MAX_ITERATIONS
completion_promise: "$COMPLETION_PROMISE"
started_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
---

$PROMPT
EOF

echo "✅ TDD Loop activated!"
echo "📝 Prompt: $PROMPT"
echo "🔄 Max iterations: $MAX_ITERATIONS"
echo "🎯 Complete with: <promise>$COMPLETION_PROMISE</promise>"
```

### Phase B: Fix Commands

#### B.1 Update tdd-loop.md Command

**File**: `plugins/smi-django/commands/tdd-loop.md`

```yaml
---
description: "Start TDD loop until tests pass"
argument-hint: '"Your prompt here"'
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup-tdd-loop.sh)"]
---
```

**Simple Usage Examples:**
```bash
# Just provide your prompt - defaults handle the rest
/tdd-loop "Build user authentication with login and logout"

# Optional: override max iterations
/tdd-loop "Add payment processing" --max-iterations 30

# Optional: custom completion promise
/tdd-loop "Refactor database layer" --promise "REFACTOR_COMPLETE"
```

With bash execution block to run setup script.

#### B.2 Add cancel-tdd Command

**File**: `plugins/smi-django/commands/cancel-tdd.md`

Similar to Ralph's `cancel-ralph.md`.

### Phase C: Create Scripts Directory

For each plugin:
```
plugins/smi-django/scripts/
└── setup-tdd-loop.sh
```

### Phase D: Simplify Other Hooks

For non-blocking hooks (UserPromptSubmit, etc.), we can still use the prompt type, but with correct format:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "${CLAUDE_PLUGIN_ROOT}/hooks/inject-conventions.md"
          }
        ]
      }
    ]
  }
}
```

---

## Part 4: Detailed File Changes

### Files to CREATE

| File | Purpose |
|------|---------|
| `plugins/smi-django/hooks/stop-hook.sh` | TDD loop stop hook (bash) |
| `plugins/smi-django/scripts/setup-tdd-loop.sh` | TDD loop setup (bash) |
| `plugins/smi-django/commands/cancel-tdd.md` | Cancel TDD loop command |
| `plugins/smi-nestjs/hooks/stop-hook.sh` | TDD loop stop hook (bash) |
| `plugins/smi-nestjs/scripts/setup-tdd-loop.sh` | TDD loop setup (bash) |
| `plugins/smi-nextjs/hooks/stop-hook.sh` | Dev loop stop hook (bash) |
| `plugins/smi-nextjs/scripts/setup-dev-loop.sh` | Dev loop setup (bash) |
| `plugins/smi-nuxtjs/hooks/stop-hook.sh` | Dev loop stop hook (bash) |
| `plugins/smi-nuxtjs/scripts/setup-dev-loop.sh` | Dev loop setup (bash) |

### Files to MODIFY

| File | Changes |
|------|---------|
| `plugins/smi-django/hooks/hooks.json` | Fix format to nested object, use command type |
| `plugins/smi-nestjs/hooks/hooks.json` | Fix format to nested object |
| `plugins/smi-nextjs/hooks/hooks.json` | Fix format to nested object |
| `plugins/smi-nuxtjs/hooks/hooks.json` | Fix format to nested object |
| `plugins/smi-django/commands/tdd-loop.md` | Add bash execution, setup script |
| `.claude-plugin/marketplace.json` | Add scripts arrays to plugins |

### Files to DELETE or ARCHIVE

| File | Reason |
|------|--------|
| `plugins/smi-django/hooks/tdd-loop-controller.md` | Replace with bash script |
| `plugins/smi-django/hooks/subagent-continuation.md` | Not needed for MVP |
| `plugins/smi-django/hooks/loop-state.md` | Replace with state file |
| Similar files in other plugins | Same reasons |

---

## Part 5: Implementation Order

### Step 1: Django Plugin First (Proof of Concept)

1. Create `plugins/smi-django/scripts/` directory
2. Create `setup-tdd-loop.sh` script
3. Create `stop-hook.sh` script
4. Fix `hooks.json` format
5. Update `tdd-loop.md` command
6. Create `cancel-tdd.md` command
7. Test with real Django project

### Step 2: Replicate to Other Plugins

Once Django works:
- Copy pattern to smi-nestjs (Jest-based)
- Copy pattern to smi-nextjs (Vitest-based)
- Copy pattern to smi-nuxtjs (Vitest-based)

### Step 3: Optional Enhancements

After core works:
- Add UserPromptSubmit hooks (convention injection)
- Add PreToolUse/PostToolUse hooks (validation)
- Add SessionStart hooks (welcome message)

---

## Part 6: Testing Plan

### Test 1: Basic Loop Start (Simple Format)

```bash
/tdd-loop "Add user authentication"
```

Expected:
- State file created at `.claude/tdd-loop.local.md`
- Message shows loop activated with defaults (50 iterations, promise="DONE")
- Iteration counter starts at 1

### Test 2: Loop Continuation

After Claude tries to exit:
- Stop hook intercepts
- Same prompt re-fed
- Iteration counter increments

### Test 3: Completion Detection

When Claude outputs `<promise>DONE</promise>` (default):
- Stop hook detects promise
- State file deleted
- Normal exit allowed

### Test 4: Max Iterations (50 default)

After reaching 50 iterations (or custom max):
- Stop hook allows exit
- Summary shown
- State file deleted

### Test 5: Cancel Loop

```bash
/cancel-tdd
```

Expected:
- State file deleted
- Confirmation message

---

## Part 7: Success Criteria

1. **hooks.json validates** against Claude Code schema
2. **Stop hook executes** when Claude tries to exit
3. **State file created** on loop start
4. **Iterations increment** correctly
5. **Completion promises detected** from transcript
6. **Loop can be cancelled** manually
7. **TDD workflow works** end-to-end in Django project

---

## Appendix A: Official Ralph Wiggum stop-hook.sh Reference

```bash
#!/bin/bash
# Key sections from official implementation

set -euo pipefail

HOOK_INPUT=$(cat)

RALPH_STATE_FILE=".claude/ralph-loop.local.md"

if [[ ! -f "$RALPH_STATE_FILE" ]]; then
  exit 0  # Allow normal exit
fi

# Parse YAML frontmatter
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$RALPH_STATE_FILE")
ITERATION=$(echo "$FRONTMATTER" | grep '^iteration:' | sed 's/iteration: *//')
MAX_ITERATIONS=$(echo "$FRONTMATTER" | grep '^max_iterations:' | sed 's/max_iterations: *//')
COMPLETION_PROMISE=$(echo "$FRONTMATTER" | grep '^completion_promise:' | sed 's/completion_promise: *//' | sed 's/^"\(.*\)"$/\1/')

# Check max iterations
if [[ $MAX_ITERATIONS -gt 0 ]] && [[ $ITERATION -ge $MAX_ITERATIONS ]]; then
  rm "$RALPH_STATE_FILE"
  exit 0
fi

# Get transcript path
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path')

# Read last assistant message
LAST_OUTPUT=$(grep '"role":"assistant"' "$TRANSCRIPT_PATH" | tail -1 | jq -r '...')

# Check for completion promise
PROMISE_TEXT=$(echo "$LAST_OUTPUT" | perl -0777 -pe 's/.*?<promise>(.*?)<\/promise>.*/$1/s; ...')
if [[ "$PROMISE_TEXT" = "$COMPLETION_PROMISE" ]]; then
  rm "$RALPH_STATE_FILE"
  exit 0
fi

# Continue loop
NEXT_ITERATION=$((ITERATION + 1))
PROMPT_TEXT=$(awk '/^---$/{i++; next} i>=2' "$RALPH_STATE_FILE")

# Update state file
sed "s/^iteration: .*/iteration: $NEXT_ITERATION/" "$RALPH_STATE_FILE" > temp && mv temp "$RALPH_STATE_FILE"

# Block exit and re-feed prompt
jq -n \
  --arg prompt "$PROMPT_TEXT" \
  --arg msg "🔄 Iteration $NEXT_ITERATION" \
  '{
    "decision": "block",
    "reason": $prompt,
    "systemMessage": $msg
  }'

exit 0
```

---

## Appendix B: Estimated Effort

| Task | Effort | Priority |
|------|--------|----------|
| Fix hooks.json format (all plugins) | 1 hour | P0 |
| Create stop-hook.sh for Django | 2 hours | P0 |
| Create setup-tdd-loop.sh for Django | 1 hour | P0 |
| Update tdd-loop.md command | 30 min | P0 |
| Create cancel-tdd.md command | 30 min | P0 |
| Test with Django project | 2 hours | P0 |
| Replicate to other plugins | 2 hours | P1 |
| Add optional hooks (UserPromptSubmit, etc.) | 2 hours | P2 |

**Total**: ~11 hours for full implementation

---

## Conclusion

Our current implementation is **fundamentally broken** due to wrong hooks.json format and using prompt-based hooks where command-based hooks are required. The fix requires:

1. Rewriting hooks.json to use nested object format
2. Creating bash scripts for Stop hooks
3. Creating setup scripts for loop initialization
4. Updating commands to run setup scripts
5. Implementing state file management

The Ralph Wiggum plugin provides a proven, working reference implementation that we should closely follow.
