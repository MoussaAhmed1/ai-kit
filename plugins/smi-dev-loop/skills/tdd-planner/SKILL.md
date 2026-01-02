---
name: tdd-planner
description: This skill should be used when the user asks to "plan a feature", "prepare for dev loop", "structure TDD approach", "break down this task", "create development plan", or when generating structured prompts for iterative development. Creates dev-loop-ready plans with TDD phases.
---

# TDD Planner

Generate structured development plans following Test-Driven Development principles for use with the dev-loop command.

## Activation Triggers

This skill activates when:
- Planning a feature for iterative development
- Preparing prompts for dev-loop execution
- Breaking down complex tasks into TDD phases
- Creating structured development workflows

## Core Principles (Ralph Wiggum Pattern)

1. **Iteration Over Perfection** - Expect multiple passes, not first-draft solutions
2. **Failures as Data** - Predictable failures inform improvements
3. **Clear Completion Criteria** - Measurable outcomes, not vague goals
4. **Self-Correction** - Embedded debugging loops for troubleshooting

## Plan Structure

Every dev-loop plan follows this structure:

```markdown
# Dev Loop Plan: [Goal]

## Context
- Framework: [detected]
- Test Runner: [command]
- Lint: [command]
- Plan File: `.claude/dev-plan.local.md`

## Progress Tracking

**IMPORTANT:** After completing each task, update this file (`.claude/dev-plan.local.md`) by checking the box:
- Change `- [ ]` to `- [x]` for completed tasks
- This tracks progress across iterations and prevents redoing work

## Success Criteria
- [ ] Measurable outcome 1
- [ ] Measurable outcome 2
- [ ] All tests pass
- [ ] Linter clean

## Phases

### Phase N: Red - [Component] Tests
**Goal:** Write failing tests
**Verification:** [test command] should FAIL
**Self-correction:** If tests pass, tests are too weak

### Phase N+1: Green - [Component] Implementation
**Goal:** Make tests pass
**Verification:** [test command] should PASS
**Self-correction:** If fails, read error, fix code

### Phase N+2: Refactor - [Component] Cleanup
**Goal:** Clean code, tests still pass
**Verification:** [test + lint command]

## Completion
When all criteria met: <promise>DONE</promise>

## Stuck Handling
If stuck 3+ iterations:
1. Re-read error carefully
2. Check correct file
3. Look at similar code
4. Simplify approach
```

## Framework Detection

Detect framework by checking for:

| Framework | Detection | Test Command | Lint Command |
|-----------|-----------|--------------|--------------|
| Django | `manage.py` or `django` in requirements | `pytest` | `ruff check .` |
| Next.js | `next` in package.json | `npm test` | `npm run lint` |
| NestJS | `@nestjs/core` in package.json | `npm test` | `npm run lint` |
| Nuxt.js | `nuxt` in package.json | `npm test` | `npm run lint` |
| Generic Python | `pytest` in requirements | `pytest` | `ruff check .` |
| Generic Node | `jest` in package.json | `npm test` | `npm run lint` |

## Phase Generation Rules

### For New Features
1. **Red**: Write tests for the feature interface
2. **Green**: Implement minimum code to pass
3. **Refactor**: Clean up, add types, documentation

### For Bug Fixes
1. **Red**: Write test that reproduces the bug (should fail)
2. **Green**: Fix the bug (test passes)
3. **Refactor**: Ensure no regression, clean up

### For Refactoring
1. **Red**: Ensure existing tests pass (baseline)
2. **Green**: Apply refactoring incrementally
3. **Refactor**: Verify tests still pass after each change

## Self-Correction Templates

Include these in every plan:

```markdown
## Self-Correction Rules

**If tests fail:**
1. Read the full error message
2. Identify which assertion failed
3. Check if implementation matches test expectation
4. Fix implementation, not test (unless test is wrong)

**If stuck in loop:**
1. Count iterations on same error
2. After 3 iterations, try different approach
3. Simplify: remove complexity, get basic case working
4. Check if you're editing the right file

**If linter fails:**
1. Run lint command to see specific errors
2. Fix one error at a time
3. Re-run to verify fix
```

## Verification Commands

Always include runnable verification:

```bash
# Test verification
pytest --tb=short
npm test

# Lint verification
ruff check .
npm run lint

# Combined verification
pytest && ruff check . && echo "ALL PASSED"
npm test && npm run lint && echo "ALL PASSED"
```

## Usage

### Generate Plan
```bash
/dev-plan "Build user authentication"
```

### Execute Plan
```bash
/dev-loop --from-plan
```

### Combined
```bash
/dev-loop "Build feature" --with-planning
```

## References

- `references/plan-template.md` - Full plan template with variables
- `references/framework-patterns.md` - Framework-specific patterns
