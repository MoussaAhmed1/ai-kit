#!/bin/bash
# Dev Loop Setup Script
# Simple usage: /dev-loop "Your prompt here"
# With plan: /dev-loop --from-plan
# Based on Ralph Wiggum pattern

set -euo pipefail

# DEFAULTS - User just provides the prompt, everything else is optional
MAX_ITERATIONS=50          # Default: 50 iterations
COMPLETION_PROMISE="DONE"  # Default: output <promise>DONE</promise> to complete
PROMPT=""
FROM_PLAN=false            # Default: use provided prompt, not plan file
PLAN_FILE=".claude/dev-plan.local.md"

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
    --from-plan)
      FROM_PLAN=true
      shift
      ;;
    *)
      # Accumulate all non-flag arguments as the prompt
      if [[ -z "$PROMPT" ]]; then
        PROMPT="$1"
      else
        PROMPT="$PROMPT $1"
      fi
      shift
      ;;
  esac
done

# Handle --from-plan flag
if [[ "$FROM_PLAN" == "true" ]]; then
  if [[ ! -f "$PLAN_FILE" ]]; then
    echo "Error: Plan file not found at $PLAN_FILE"
    echo "Run /dev-plan first to generate a plan, or provide a prompt directly."
    exit 1
  fi
  # Read the plan file content as the prompt
  PROMPT=$(cat "$PLAN_FILE")
  echo "Using plan from: $PLAN_FILE"
fi

# Validate prompt was provided
if [[ -z "$PROMPT" ]]; then
  echo "Error: No prompt provided"
  echo "Usage: /dev-loop \"Your prompt here\""
  echo "       /dev-loop --from-plan"
  exit 1
fi

# Create .claude directory if it doesn't exist
mkdir -p .claude

# Create state file with YAML frontmatter
cat > .claude/dev-loop.local.md <<EOF
---
active: true
iteration: 1
max_iterations: $MAX_ITERATIONS
completion_promise: "$COMPLETION_PROMISE"
started_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
---

$PROMPT
EOF

echo "Dev Loop activated!"
echo "Prompt: $PROMPT"
echo "Max iterations: $MAX_ITERATIONS"
echo "Complete with: <promise>$COMPLETION_PROMISE</promise>"
