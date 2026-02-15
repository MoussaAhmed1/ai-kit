#!/bin/bash
set -euo pipefail

# Failure log injection script
# Reads .claude/failure-log.local.md and injects a condensed summary into context

FAILURE_LOG=".claude/failure-log.local.md"

# Quick exit if no failure log exists
if [[ ! -f "$FAILURE_LOG" ]]; then
  exit 0
fi

# Parse YAML frontmatter
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$FAILURE_LOG" 2>/dev/null || echo "")

# Check if enabled (default to true if not specified)
ENABLED=$(echo "$FRONTMATTER" | grep '^enabled:' | sed 's/enabled: *//' | tr -d ' ' || echo "true")
if [[ "$ENABLED" == "false" ]]; then
  exit 0
fi

# Extract markdown body (everything after the second ---)
BODY=$(awk '/^---$/{i++; next} i>=2' "$FAILURE_LOG" 2>/dev/null || echo "")

# Count failures (lines starting with ###)
FAILURE_COUNT=$(echo "$BODY" | grep -c '^### ' || echo "0")

if [[ "$FAILURE_COUNT" -eq 0 ]]; then
  exit 0
fi

# Extract failure summaries (condensed format)
# Get the mistake line from each failure entry
FAILURES_SUMMARY=$(echo "$BODY" | awk '
  /^### / {
    # Get the failure title (date and description)
    title = $0
    gsub(/^### /, "", title)
  }
  /^\*\*Mistake:\*\*/ {
    mistake = $0
    gsub(/^\*\*Mistake:\*\* */, "", mistake)
    if (title != "") {
      print "- " title ": " mistake
      title = ""
    }
  }
')

# If no structured failures found, try simpler extraction
if [[ -z "$FAILURES_SUMMARY" ]]; then
  # Just extract headers as reminders
  FAILURES_SUMMARY=$(echo "$BODY" | grep '^### ' | sed 's/^### /- /' | head -20)
fi

# Output system message with failure context
if [[ -n "$FAILURES_SUMMARY" ]]; then
  cat << EOF
{
  "systemMessage": "⚠️ FAILURE LOG ACTIVE ($FAILURE_COUNT known mistakes to avoid):\n$FAILURES_SUMMARY\n\nReview full log at .claude/failure-log.local.md if needed."
}
EOF
fi
