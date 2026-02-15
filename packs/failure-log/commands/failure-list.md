---
name: failure-list
description: View all logged failures and mistakes for this project
argument-hint: "[category]"
allowed-tools: ["Read"]
---

# List Failures

Display failures from the project's failure log.

## Steps

1. **Check if failure log exists** at `.claude/failure-log.local.md`:
   - If not, inform user: "No failure log found. Use `/failure-add` to start logging mistakes."

2. **Read the failure log** file

3. **Parse optional category filter** from arguments:
   - If category provided, filter entries by that category
   - Valid categories: `imports`, `security`, `testing`, `architecture`, `conventions`
   - If no category, show all entries

4. **Display failures** in a readable format:

## Output Format

```
📋 Failure Log Summary
━━━━━━━━━━━━━━━━━━━━━

Total entries: X
Last updated: YYYY-MM-DD

## Pattern Mistakes (X entries)

1. [2026-01-01] Brief title
   Category: imports
   Mistake: What went wrong
   Correct: What to do instead

2. [2026-01-01] Another title
   ...

## Failed Approaches (X entries)

1. [2026-01-01] Brief title
   Category: testing
   What failed: Why it didn't work
   Better: What works instead

━━━━━━━━━━━━━━━━━━━━━
```

## Filtered Output

When category is provided:

```
📋 Failure Log: imports
━━━━━━━━━━━━━━━━━━━━━

Showing X entries for category: imports

1. [2026-01-01] Wrong import pattern
   Mistake: Used relative imports
   Correct: Use alias pattern

...
```

## Empty Log

If log exists but has no entries:

```
📋 Failure Log
━━━━━━━━━━━━━━

No failures logged yet.

Use `/failure-add "description"` to log a mistake.
```

## Usage Examples

- `/failure-list` - Show all failures
- `/failure-list imports` - Show only import-related failures
- `/failure-list security` - Show only security-related failures
