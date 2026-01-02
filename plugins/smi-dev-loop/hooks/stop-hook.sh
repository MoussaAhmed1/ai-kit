#!/bin/bash
# Dev Loop Stop Hook
# Based on Ralph Wiggum pattern
# This script runs when Claude tries to exit and decides whether to block

set -euo pipefail

# Read hook input from stdin (JSON with transcript_path)
HOOK_INPUT=$(cat)

STATE_FILE=".claude/dev-loop.local.md"

# If no active loop state file, allow normal exit
if [[ ! -f "$STATE_FILE" ]]; then
  exit 0
fi

# Parse YAML frontmatter from state file
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE")
ITERATION=$(echo "$FRONTMATTER" | grep '^iteration:' | sed 's/iteration: *//')
MAX_ITERATIONS=$(echo "$FRONTMATTER" | grep '^max_iterations:' | sed 's/max_iterations: *//')
COMPLETION_PROMISE=$(echo "$FRONTMATTER" | grep '^completion_promise:' | sed 's/completion_promise: *//' | sed 's/^"\(.*\)"$/\1/')

# Check if we've hit max iterations
if [[ $MAX_ITERATIONS -gt 0 ]] && [[ $ITERATION -ge $MAX_ITERATIONS ]]; then
  echo "Dev Loop completed after $ITERATION iterations (max reached)" >&2
  rm "$STATE_FILE"
  exit 0
fi

# Get transcript path from hook input
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // empty')

if [[ -z "$TRANSCRIPT_PATH" ]] || [[ ! -f "$TRANSCRIPT_PATH" ]]; then
  # No transcript available, continue loop
  NEXT_ITERATION=$((ITERATION + 1))
  PROMPT_TEXT=$(awk '/^---$/{i++; next} i>=2' "$STATE_FILE")

  # Update iteration in state file
  sed "s/^iteration: .*/iteration: $NEXT_ITERATION/" "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"

  # Build continue message
  CONTINUE_MSG="Continue working on the task. Iteration $NEXT_ITERATION of $MAX_ITERATIONS.

When complete, output: <promise>$COMPLETION_PROMISE</promise>

---
$PROMPT_TEXT"

  jq -n \
    --arg prompt "$CONTINUE_MSG" \
    '{
      "decision": "block",
      "reason": $prompt
    }'
  exit 0
fi

# Read the last assistant message from transcript
# The transcript is JSONL format with role: "assistant" messages
# Content structure: {"message":{"content":[{"type":"text","text":"..."}]}}
LAST_OUTPUT=""
if [[ -f "$TRANSCRIPT_PATH" ]]; then
  # Extract text from all text blocks in the last assistant message
  LAST_OUTPUT=$(grep '"role":"assistant"' "$TRANSCRIPT_PATH" 2>/dev/null | tail -1 | jq -r '
    if .message.content then
      [.message.content[] | select(.type == "text") | .text] | join("\n")
    elif .content then
      if type == "array" then
        [.content[] | select(.type == "text") | .text] | join("\n")
      else
        .content
      end
    else
      empty
    end
  ' 2>/dev/null || echo "")
fi

# Check for completion promise in output
if [[ -n "$LAST_OUTPUT" ]]; then
  # Look for <promise>TEXT</promise> pattern
  PROMISE_TEXT=$(echo "$LAST_OUTPUT" | perl -0777 -ne 'print $1 if /<promise>(.*?)<\/promise>/s' 2>/dev/null || echo "")

  if [[ "$PROMISE_TEXT" = "$COMPLETION_PROMISE" ]]; then
    echo "Dev Loop completed! Promise '$COMPLETION_PROMISE' detected after $ITERATION iterations" >&2
    rm "$STATE_FILE"
    exit 0
  fi
fi

# Continue the loop - block exit and re-feed prompt
NEXT_ITERATION=$((ITERATION + 1))

# Get prompt text (everything after the second ---)
PROMPT_TEXT=$(awk '/^---$/{i++; next} i>=2' "$STATE_FILE")

# Update iteration counter in state file
sed "s/^iteration: .*/iteration: $NEXT_ITERATION/" "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"

# Build continue message
CONTINUE_MSG="Continue working on the task. Iteration $NEXT_ITERATION of $MAX_ITERATIONS.

When complete, output: <promise>$COMPLETION_PROMISE</promise>

---
$PROMPT_TEXT"

# Return JSON to block exit and continue with prompt
jq -n \
  --arg prompt "$CONTINUE_MSG" \
  '{
    "decision": "block",
    "reason": $prompt
  }'

exit 0
