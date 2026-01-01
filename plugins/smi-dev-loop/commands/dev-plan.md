---
name: dev-plan
description: Generate a structured TDD plan for dev-loop execution
argument-hint: '"Your goal" [--framework django|nestjs|nextjs|nuxtjs] [--interactive]'
allowed-tools: ["Read", "Write", "Glob", "Grep", "Bash", "AskUserQuestion"]
---

# Create Development Plan

Generate a structured TDD plan following Ralph Wiggum best practices for use with `/dev-loop --from-plan`.

## Steps

### 1. Parse Arguments

Extract from user input:
- **Goal**: The main objective (required)
- **--framework**: Override auto-detection (optional)
- **--interactive**: Ask clarifying questions (optional)

### 2. Detect Framework

If `--framework` not specified, auto-detect by checking:

```bash
# Check for Django
[ -f "manage.py" ] && echo "django"

# Check for NestJS
grep -q "@nestjs/core" package.json 2>/dev/null && echo "nestjs"

# Check for Next.js
grep -q '"next"' package.json 2>/dev/null && echo "nextjs"

# Check for Nuxt.js
grep -q '"nuxt"' package.json 2>/dev/null && echo "nuxtjs"
```

Set appropriate test/lint commands based on framework.

### 3. Analyze Codebase Context

Read existing patterns:
- Look for existing test files to understand test style
- Check for linting configuration
- Identify existing models/components related to the goal
- Note any relevant README or documentation

### 4. Break Goal into TDD Phases

For each component needed:
1. **Red Phase**: Write failing tests first
2. **Green Phase**: Implement to pass tests
3. **Refactor Phase**: Clean up while keeping tests green

Each phase needs:
- Clear goal statement
- Specific tasks
- Verification command
- Expected result
- Self-correction rule

### 5. Define Success Criteria

Create measurable criteria:
- Specific features working
- All tests passing
- Linter clean
- Coverage threshold (if applicable)

### 6. Add Self-Correction Rules

Include stuck-handling:
- What to do if same error repeats
- How to simplify approach
- When to try alternatives

### 7. Generate Plan File

Create `.claude/dev-plan.local.md` with full plan:

```markdown
# Dev Loop Plan: [Goal]

## Context
- Framework: [detected/specified]
- Test Command: [command]
- Lint Command: [command]

## Success Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] All tests pass
- [ ] Linter clean

## Phases

### Phase 1: Red - [Component] Tests
**Goal:** Write failing tests
**Tasks:**
- [ ] Task 1
- [ ] Task 2
**Verification:** `[command]` should FAIL
**Self-correction:** If tests pass, strengthen them

[Additional phases...]

## Final Verification
```bash
[combined verification command]
```

## Completion
When all criteria met: <promise>DONE</promise>

## Stuck Handling
[Self-correction rules]
```

### 8. Confirm with User

After generating plan, ask:
- "Plan saved to `.claude/dev-plan.local.md`"
- "Would you like to start the dev-loop now with `/dev-loop --from-plan`?"

If user agrees, they can run the dev-loop command.

## Interactive Mode (--interactive)

When `--interactive` flag is present, ask clarifying questions:

1. "What are the key acceptance criteria for this feature?"
2. "Are there any existing components to integrate with?"
3. "What's the desired test coverage level?"
4. "Any specific patterns or libraries to use?"

Use answers to create more targeted plan.

## Example

**Input:**
```
/dev-plan "Build user authentication with JWT"
```

**Output:**
Creates `.claude/dev-plan.local.md` with:
- 6 phases (model tests, model impl, auth tests, auth impl, refactors)
- Django-specific commands (pytest, ruff)
- Smicolon convention reminders
- Self-correction rules

**Follow-up:**
```
/dev-loop --from-plan
```

## Tips

- Keep phases small and focused
- Each phase should be independently verifiable
- Include both "what to do" and "what NOT to do"
- Self-correction prevents infinite loops on the same error
