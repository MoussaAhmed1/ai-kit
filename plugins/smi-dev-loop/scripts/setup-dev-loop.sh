#!/bin/bash

# Dev Loop Setup Script
# Based on Ralph Wiggum pattern from official plugin
# Creates state file for in-session dev loop

set -euo pipefail

# Parse arguments
PROMPT_PARTS=()
MAX_ITERATIONS=50        # Default: 50 iterations (different from Ralph's unlimited)
COMPLETION_PROMISE="DONE" # Default: "DONE" (different from Ralph's null)
FROM_PLAN=false
PLAN_FILE=".claude/dev-plan.local.md"

# Parse options and positional arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      cat << 'HELP_EOF'
Dev Loop - Iterative development loop with sensible defaults

USAGE:
  /dev-loop [PROMPT...] [OPTIONS]
  /dev-loop --from-plan [OPTIONS]

ARGUMENTS:
  PROMPT...    Initial prompt to start the loop (can be multiple words without quotes)

OPTIONS:
  --from-plan                    Use prompt from .claude/dev-plan.local.md
  --max-iterations <n>           Maximum iterations (default: 50)
  --promise '<text>'             Completion promise phrase (default: DONE)
  -h, --help                     Show this help message

DESCRIPTION:
  Starts a development loop in your CURRENT session. The stop hook prevents
  exit and feeds your output back as input until completion or iteration limit.

  To signal completion, output: <promise>DONE</promise>
  (or your custom --promise value)

  Use this for:
  - TDD development cycles (Red-Green-Refactor)
  - Bug fixing with iterative debugging
  - Feature implementation with self-correction

DEFAULTS (different from Ralph Wiggum):
  - Max iterations: 50 (Ralph: unlimited)
  - Completion promise: DONE (Ralph: none)

EXAMPLES:
  /dev-loop Build a todo API
  /dev-loop Fix the auth bug --max-iterations 20
  /dev-loop --from-plan
  /dev-loop Refactor cache layer --promise 'REFACTOR COMPLETE'

STOPPING:
  Output <promise>DONE</promise> or reach max iterations (50 by default).

WORKFLOW:
  1. /dev-plan "Your task"     # Generate structured TDD plan
  2. Review .claude/dev-plan.local.md
  3. /dev-loop --from-plan     # Execute with plan
HELP_EOF
      exit 0
      ;;
    --max-iterations)
      if [[ -z "${2:-}" ]]; then
        echo "❌ Error: --max-iterations requires a number argument" >&2
        echo "" >&2
        echo "   Valid examples:" >&2
        echo "     --max-iterations 10" >&2
        echo "     --max-iterations 50" >&2
        echo "     --max-iterations 0  (unlimited)" >&2
        echo "" >&2
        echo "   You provided: --max-iterations (with no number)" >&2
        exit 1
      fi
      if ! [[ "$2" =~ ^[0-9]+$ ]]; then
        echo "❌ Error: --max-iterations must be a positive integer or 0, got: $2" >&2
        echo "" >&2
        echo "   Valid examples:" >&2
        echo "     --max-iterations 10" >&2
        echo "     --max-iterations 50" >&2
        echo "     --max-iterations 0  (unlimited)" >&2
        echo "" >&2
        echo "   Invalid: decimals (10.5), negative numbers (-5), text" >&2
        exit 1
      fi
      MAX_ITERATIONS="$2"
      shift 2
      ;;
    --promise|--completion-promise)
      if [[ -z "${2:-}" ]]; then
        echo "❌ Error: --promise requires a text argument" >&2
        echo "" >&2
        echo "   Valid examples:" >&2
        echo "     --promise 'DONE'" >&2
        echo "     --promise 'TASK COMPLETE'" >&2
        echo "     --promise 'All tests passing'" >&2
        echo "" >&2
        echo "   You provided: --promise (with no text)" >&2
        echo "" >&2
        echo "   Note: Multi-word promises must be quoted!" >&2
        exit 1
      fi
      COMPLETION_PROMISE="$2"
      shift 2
      ;;
    --from-plan)
      FROM_PLAN=true
      shift
      ;;
    *)
      # Non-option argument - collect all as prompt parts
      PROMPT_PARTS+=("$1")
      shift
      ;;
  esac
done

# Handle --from-plan
if [[ "$FROM_PLAN" == "true" ]]; then
  if [[ ! -f "$PLAN_FILE" ]]; then
    echo "❌ Error: Plan file not found at $PLAN_FILE" >&2
    echo "" >&2
    echo "   Run /dev-plan first to generate a plan, or provide a prompt directly." >&2
    echo "" >&2
    echo "   Examples:" >&2
    echo "     /dev-plan Build a REST API for todos" >&2
    echo "     /dev-loop --from-plan" >&2
    exit 1
  fi
  PROMPT=$(cat "$PLAN_FILE")
  echo "📋 Using plan from: $PLAN_FILE"
else
  # Join all prompt parts with spaces
  PROMPT="${PROMPT_PARTS[*]}"
fi

# Validate prompt is non-empty
if [[ -z "$PROMPT" ]]; then
  echo "❌ Error: No prompt provided" >&2
  echo "" >&2
  echo "   Dev loop needs a task description to work on." >&2
  echo "" >&2
  echo "   Examples:" >&2
  echo "     /dev-loop Build a REST API for todos" >&2
  echo "     /dev-loop Fix the auth bug --max-iterations 20" >&2
  echo "     /dev-loop --from-plan" >&2
  echo "" >&2
  echo "   For all options: /dev-loop --help" >&2
  exit 1
fi

# Create state file for stop hook (markdown with YAML frontmatter)
mkdir -p .claude

# Quote completion promise for YAML
COMPLETION_PROMISE_YAML="\"$COMPLETION_PROMISE\""

cat > .claude/dev-loop.local.md <<EOF
---
active: true
iteration: 1
max_iterations: $MAX_ITERATIONS
completion_promise: $COMPLETION_PROMISE_YAML
started_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
---

$PROMPT
EOF

# Output setup message
cat <<EOF
🔄 Dev loop activated!

Iteration: 1
Max iterations: $(if [[ $MAX_ITERATIONS -gt 0 ]]; then echo $MAX_ITERATIONS; else echo "unlimited"; fi)
Completion promise: $COMPLETION_PROMISE

To complete: output <promise>$COMPLETION_PROMISE</promise>
(ONLY when task is COMPLETE - do not lie to exit!)

To monitor: head -10 .claude/dev-loop.local.md
To cancel: /cancel-dev

🔄
EOF

# Output the initial prompt
echo ""
echo "$PROMPT"
