---
name: failure-add
description: Add a failure or mistake to the project's failure log for future reference
argument-hint: "[description of mistake]"
allowed-tools: ["Read", "Write", "AskUserQuestion"]
---

# Add Failure to Log

Record a mistake to prevent repeating it in future sessions.

## Steps

1. **Parse the user's input** to understand the failure:
   - What was the context?
   - What was the mistake?
   - What is the correct approach?

2. **Determine failure type**:
   - **Pattern Mistake**: Recurring pattern violation (imports, naming, structure)
   - **Failed Approach**: An approach that doesn't work

3. **Determine category** (ask if unclear):
   - `imports` - Wrong import patterns
   - `security` - Missing security checks
   - `testing` - Wrong test approaches
   - `architecture` - Structural mistakes
   - `conventions` - Code style violations

4. **Check if failure log exists** at `.claude/failure-log.local.md`:
   - If not, create it with the template below
   - If yes, read existing content

5. **Add the new failure entry**:
   - Update `last_updated` timestamp in frontmatter
   - Add entry under appropriate section (Pattern Mistakes or Failed Approaches)
   - Place newest entries first

6. **Confirm** the failure was logged with a brief summary

## Template for New File

```markdown
---
enabled: true
last_updated: [CURRENT_ISO_TIMESTAMP]
---

# Failure Log

This log tracks mistakes to prevent repeating them across sessions.

## Pattern Mistakes

[NEW_ENTRY_HERE]

## Failed Approaches

_No failed approaches logged yet._
```

## Entry Format

### For Pattern Mistakes

```markdown
### [YYYY-MM-DD] Brief descriptive title
**Context:** What was being done when the mistake occurred
**Mistake:** The specific error or violation
**Correct:** The correct approach to use instead
**Category:** [category]
```

### For Failed Approaches

```markdown
### [YYYY-MM-DD] Brief descriptive title
**Context:** What was being attempted
**What failed:** Why the approach didn't work
**Better approach:** What works instead
**Category:** [category]
```

## Examples

**User says:** "Log that I used relative imports in Django"

**Entry created:**
```markdown
### [2026-01-01] Used relative imports in Django service
**Context:** Writing business logic in user service
**Mistake:** Used `from .models import User` relative import
**Correct:** Use `import users.models as _users_models` with alias pattern
**Category:** imports
```

**User says:** "Remember that mocking the database directly doesn't work"

**Entry created:**
```markdown
### [2026-01-01] Mocking database directly in tests
**Context:** Writing unit tests for user creation
**What failed:** Mocking `User.objects.create` breaks ORM behavior and fixtures
**Better approach:** Use factory_boy to create test data, mock external services only
**Category:** testing
```
