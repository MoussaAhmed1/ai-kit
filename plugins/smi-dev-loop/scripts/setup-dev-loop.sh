#!/bin/bash
# Dev Loop Setup Script
# Simple usage: /dev-loop "Your prompt here"
# Based on Ralph Wiggum pattern

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

# Validate prompt was provided
if [[ -z "$PROMPT" ]]; then
  echo "Error: No prompt provided"
  echo "Usage: /dev-loop \"Your prompt here\""
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
