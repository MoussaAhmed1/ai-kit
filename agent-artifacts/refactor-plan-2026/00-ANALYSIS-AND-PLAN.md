# Smicolon Marketplace Plugin Refactor Plan

**Date**: 2026-01-01
**Status**: Draft
**Author**: Claude (Opus 4.5)

---

## Table of Contents

1. [Current State Analysis](#current-state-analysis)
2. [Outdated/Redundant Data](#outdatedr-redundant-data)
3. [Claude Code Latest Features](#claude-code-latest-features)
4. [Feature Gaps](#feature-gaps)
5. [Improvement Plan](#improvement-plan)
6. [TDD Integration Strategy](#tdd-integration-strategy)
7. [Implementation Phases](#implementation-phases)
8. [Reference Resources](#reference-resources)

---

## Current State Analysis

### What Exists

| Component | Count | Status |
|-----------|-------|--------|
| Plugins | 5 | Working |
| Agents | 14 | Working |
| Commands | 6 | Working |
| Skills | 11 | Working |
| Hooks | 0 | **MISSING** (shell scripts removed) |
| Rules (.claude/rules/) | 0 | **MISSING** |
| Stop Hooks | 0 | **NOT IMPLEMENTED** |
| Path-Specific Rules | 0 | **NOT IMPLEMENTED** |

### Architecture Summary

```
claude-infra/
├── .claude-plugin/marketplace.json    # Single source of truth
├── plugins/
│   ├── smi-django/      # 5 agents, 3 commands, 6 skills
│   ├── smi-nestjs/      # 3 agents, 1 command, 2 skills
│   ├── smi-nextjs/      # 4 agents, 1 command, 3 skills
│   ├── smi-nuxtjs/      # 3 agents, 0 commands, 0 skills
│   └── smi-architect/   # 1 agent, 1 command, 0 skills
├── workflows/           # Multi-agent orchestration (2 files)
└── templates/           # Project templates
```

### Key Findings

1. **Hooks Removed**: README mentions hooks in `plugins/*/hooks/` but no shell scripts exist
2. **No Path-Specific Rules**: Not leveraging `.claude/rules/` native feature (v2.0.64+)
3. **No Stop Hooks**: Long-running task support (ralph-wiggum pattern) not implemented
4. **Skills Lack Enforcement Triggers**: Skills describe auto-activation but lack hooks to enforce
5. **No TDD Workflow**: Tests mentioned but no test-first automation
6. **smi-nuxtjs Incomplete**: No skills, no commands (only agents)

---

## Outdated/Redundant Data

### 1. README.md Claims vs Reality

| README Claims | Reality |
|---------------|---------|
| "Hooks automatically enforce company standards" | No hook files exist |
| "plugins/*/hooks/ - 3 hooks" | Directory doesn't exist |
| "Hook-based automatic convention injection" | Not implemented |

**Action**: Update README or implement missing hooks

### 2. CLAUDE.md Documentation Mismatches

```markdown
# CLAUDE.md says:
- `plugins/smi-django/hooks/user-prompt-submit-hook.sh` - Convention injection logic
- `plugins/*/hooks/post-write-hook.sh` - Validates generated code

# Reality:
- No hooks directory exists
- No shell scripts found
```

**Action**: Remove outdated references or implement hooks

### 3. marketplace.json Missing Fields

Current plugins lack new Claude Code v2.0.64+ features:

```json
// Current (missing new fields)
{
  "name": "smi-django",
  "agents": [...],
  "commands": [...],
  "skills": [...]
}

// Should include:
{
  "name": "smi-django",
  "agents": [...],
  "commands": [...],
  "skills": [...],
  "hooks": [...],           // NEW: Event hooks
  "rules": [...],           // NEW: Path-specific rules
  "permissionMode": "ask"   // NEW: Permission control
}
```

### 4. Inconsistent Skill Coverage

| Plugin | Skills | Gap |
|--------|--------|-----|
| smi-django | 6 | Comprehensive |
| smi-nextjs | 3 | Good |
| smi-nestjs | 2 | Minimal |
| smi-nuxtjs | 0 | **EMPTY** |
| smi-architect | 0 | N/A (no code generated) |

**Action**: Add skills to smi-nuxtjs (at minimum: accessibility, form, import)

### 5. Duplicate Content

- `frontend-visual.md` duplicated in smi-nextjs and smi-nuxtjs
- `frontend-tester.md` duplicated in smi-nextjs and smi-nuxtjs

**Action**: Consider shared skills/agents approach or symlinks

### 6. Outdated Agent Frontmatter

Current agents use minimal frontmatter:

```yaml
---
name: django-architect
description: Senior Django architect...
model: inherit
---
```

Should use v2.0.64+ features:

```yaml
---
name: django-architect
description: Senior Django architect...
model: inherit
skills:
  - import-convention-enforcer
  - model-entity-validator
  - security-first-validator
allowedTools:
  - Read
  - Glob
  - Grep
  - WebFetch
  - WebSearch
permissionMode: ask
---
```

---

## Claude Code Latest Features

Based on CHANGELOG and paddo.dev research:

### Hook Events (v2.0.38+)

| Event | Purpose | Our Use Case |
|-------|---------|--------------|
| `UserPromptSubmit` | Before prompt processing | Inject framework conventions |
| `PreToolUse` | Before tool execution | Validate tool inputs |
| `PostToolUse` | After tool execution | Validate outputs (imports, security) |
| `Stop` | Conversation ends | **Ralph-wiggum loops** |
| `SubagentStop` | Subagent completes | Continue TDD loops |
| `PermissionRequest` | Auto-approve/deny | Auto-approve safe tools |
| `SessionStart` | New session | Load project context |
| `PreCompact` | Before compaction | Preserve critical context |

### Path-Specific Rules (v2.0.64+)

```
.claude/rules/
├── backend.md       # paths: src/api/**/*.py
├── frontend.md      # paths: src/components/**/*.tsx
├── testing.md       # paths: **/*test*.py, **/*.spec.ts
└── migrations.md    # paths: **/migrations/**/*.py
```

### Agent Features (v2.0.64+)

- `skills`: Auto-loaded skills for agents
- `allowedTools`: Restrict to safe tools
- `disallowedTools`: Block dangerous tools
- `permissionMode`: ask/auto/deny
- `model`: Custom model selection (haiku for quick tasks)

### New Plugin Capabilities

- `/plugin validate` - Check plugin structure
- `/plugin discover` - Find new plugins
- Git branch/tag support via `#branch` syntax
- Auto-update toggles per marketplace

---

## Feature Gaps

### Critical Gaps (Must Have)

1. **Stop Hook Implementation** (ralph-wiggum pattern)
   - Enable TDD loops: "Run tests until all pass"
   - Enable refactor loops: "Migrate until done"
   - Enable coverage loops: "Add tests until 90%+"

2. **Path-Specific Rules**
   - Backend rules only for Python files
   - Frontend rules only for TSX files
   - Test rules only for test files
   - Migration rules only for migration files

3. **Hook Implementation**
   - UserPromptSubmit: Inject conventions
   - PostToolUse (Write/Edit): Validate outputs
   - PermissionRequest: Auto-approve safe tools

### Important Gaps (Should Have)

4. **TDD Workflow Command**
   - `/tdd-loop` command that:
     1. Generates tests first
     2. Runs tests (expects failure)
     3. Implements code
     4. Runs tests (expects pass)
     5. Loops until complete

5. **Skills for smi-nuxtjs**
   - Vue accessibility validator
   - VeeValidate form validator
   - Import convention enforcer

6. **Agent Skill Integration**
   - Link agents to auto-load relevant skills
   - Example: `@django-builder` auto-loads security-first-validator

### Nice to Have

7. **Beads-style Memory**
   - Session continuity for long tasks
   - Task state persistence

8. **Visual Verification Integration**
   - Screenshot comparisons
   - Playwright MCP deep integration

---

## Improvement Plan

### Phase 1: Foundation (Stop Hooks + Rules)

**Goal**: Enable long-running autonomous loops

#### 1.1 Implement Stop Hook

Create `/plugins/smi-django/hooks/hooks.json`:

```json
{
  "hooks": [
    {
      "event": "Stop",
      "type": "prompt",
      "prompt": "${CLAUDE_PLUGIN_ROOT}/hooks/stop-loop.md"
    }
  ]
}
```

Create `/plugins/smi-django/hooks/stop-loop.md`:

```markdown
---
name: TDD Loop Controller
description: Continues iteration until tests pass or max iterations reached
---

# TDD Loop Check

## Context
- Exit code: $CLAUDE_EXIT_CODE
- Iteration: $LOOP_ITERATION
- Max iterations: $MAX_ITERATIONS (default: 50)

## Decision Logic

If exit code is 0 (success) AND all tests pass:
  → Allow exit

If exit code is 2 (user interrupt):
  → Allow exit

If iteration >= MAX_ITERATIONS:
  → Allow exit with summary

Otherwise:
  → Re-inject prompt with updated context
  → Continue to next iteration
```

#### 1.2 Create Path-Specific Rules

Create `.claude/rules/` in each plugin:

```
plugins/smi-django/rules/
├── python-files.md          # paths: **/*.py
├── models.md                 # paths: **/models.py, **/models/*.py
├── views.md                  # paths: **/views.py, **/views/*.py
├── serializers.md            # paths: **/serializers.py
├── services.md               # paths: **/services.py
├── tests.md                  # paths: **/test*.py, **/tests/**/*.py
└── migrations.md             # paths: **/migrations/**/*.py
```

Example `models.md`:

```markdown
---
paths: **/models.py, **/models/*.py
---

# Django Model Rules

## Required Fields (ALL models)
- UUID primary key: `id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)`
- Created timestamp: `created_at = models.DateTimeField(auto_now_add=True)`
- Updated timestamp: `updated_at = models.DateTimeField(auto_now=True)`
- Soft delete: `is_deleted = models.BooleanField(default=False)`

## Import Pattern
```python
# REQUIRED: Absolute imports with aliases
import uuid
from django.db import models
```

## Forbidden
- Auto-incrementing integer primary keys
- Relative imports
- Direct model instantiation in views (use services)
```

### Phase 2: TDD Integration

**Goal**: Test-first development with verification loops

#### 2.1 Create TDD Loop Command

Create `/plugins/smi-django/commands/tdd-loop.md`:

```markdown
---
name: tdd-loop
description: Run TDD loop until all tests pass
args:
  - name: feature
    description: Feature to implement
    required: true
  - name: max-iterations
    description: Maximum iterations (default: 20)
    required: false
---

# TDD Loop: $FEATURE

## Phase 1: Test Generation
1. Analyze feature requirements
2. Generate test cases FIRST (using test-coverage-advisor)
3. Create test file with failing tests
4. Verify tests fail (red phase)

## Phase 2: Implementation Loop
Until all tests pass OR max iterations reached:
1. Run tests: `pytest -x -v`
2. If pass → Done
3. If fail → Analyze failure
4. Implement minimal fix
5. Repeat

## Phase 3: Refactor (Green → Refactor)
1. All tests passing
2. Apply performance-optimizer
3. Apply security-first-validator
4. Run tests again
5. Commit if still green

## Anti-Shortcut Measures
- Tests MUST exist before implementation
- Tests MUST fail initially (if they pass, tests are wrong)
- No implementation without test coverage
- Coverage must reach 90%+ before completion
```

#### 2.2 Test Validity Verification

Create `/plugins/smi-django/skills/test-validity-checker/SKILL.md`:

```markdown
---
name: test-validity-checker
description: Verify tests are meaningful and not shortcuts
---

# Test Validity Checker

## Anti-Shortcut Detection

### 1. Empty Test Detection
```python
# BAD: Empty or trivial test
def test_user():
    assert True  # Shortcut!

def test_create():
    user = User()  # No assertions!
```

### 2. Assertion Quality Check
```python
# BAD: Weak assertion
assert response.status_code  # Just checks existence

# GOOD: Meaningful assertion
assert response.status_code == 201
assert response.data['email'] == 'test@example.com'
```

### 3. Coverage vs Quality
- Count assertions per test (minimum: 2)
- Check for edge cases
- Verify negative tests exist
- Ensure mocking is minimal

### 4. Test Independence
- Each test must be isolated
- No shared mutable state
- Database cleaned between tests
```

### Phase 3: Hook Implementation

**Goal**: Automatic convention enforcement

#### 3.1 UserPromptSubmit Hook

Inject conventions before processing:

```json
{
  "hooks": [
    {
      "event": "UserPromptSubmit",
      "type": "prompt",
      "prompt": "${CLAUDE_PLUGIN_ROOT}/hooks/inject-conventions.md",
      "matcher": {
        "tool": "*"
      }
    }
  ]
}
```

#### 3.2 PostToolUse Validation

Validate after Write/Edit:

```json
{
  "hooks": [
    {
      "event": "PostToolUse",
      "type": "prompt",
      "prompt": "${CLAUDE_PLUGIN_ROOT}/hooks/validate-output.md",
      "matcher": {
        "tool": "Write|Edit"
      }
    }
  ]
}
```

### Phase 4: Agent Enhancement

**Goal**: Agents auto-load skills and have proper tool restrictions

#### 4.1 Update Agent Frontmatter

```yaml
---
name: django-builder
description: Expert Django developer for implementing features
model: inherit
skills:
  - import-convention-enforcer
  - model-entity-validator
  - security-first-validator
  - performance-optimizer
allowedTools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
permissionMode: ask
---
```

#### 4.2 Create Specialized Testing Agent

```yaml
---
name: django-tdd
description: TDD specialist running test-first loops
model: haiku  # Fast iterations
skills:
  - test-coverage-advisor
  - test-validity-checker
allowedTools:
  - Read
  - Write
  - Edit
  - Bash
permissionMode: auto  # Fast loop execution
---
```

### Phase 5: Complete smi-nuxtjs

**Goal**: Parity with smi-nextjs

Add skills:
- `accessibility-validator` (Vue-specific)
- `veevalidate-form-validator`
- `import-convention-enforcer`
- `composable-validator` (Nuxt-specific)

---

## TDD Integration Strategy

### Problem: AI Agents Taking Shortcuts

Common shortcuts:
1. Writing tests that always pass
2. Testing implementation details instead of behavior
3. Skipping edge cases
4. Low assertion counts
5. Modifying tests to pass instead of fixing code

### Solution: Multi-Layer Verification

```
┌─────────────────────────────────────────────────┐
│                  Layer 1: Stop Hook              │
│    Re-inject prompt if tests fail                │
└─────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────┐
│             Layer 2: Test Validity Skill         │
│    Check tests are meaningful before running     │
└─────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────┐
│          Layer 3: Coverage Verification          │
│    pytest --cov-fail-under=90                    │
└─────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────┐
│           Layer 4: Mutation Testing             │
│    mutmut run to verify tests catch bugs        │
└─────────────────────────────────────────────────┘
```

### TDD Loop Flow

```
┌──────────────────┐
│   /tdd-loop      │
│   "user auth"    │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐     NO     ┌──────────────────┐
│  Tests exist?    │───────────►│  Generate tests  │
└────────┬─────────┘            │  (expect fail)   │
         │ YES                  └────────┬─────────┘
         ▼                               │
┌──────────────────┐                     │
│   Run tests      │◄────────────────────┘
└────────┬─────────┘
         │
    ┌────┴────┐
    │ Result? │
    └────┬────┘
         │
    PASS ├──────────────────► Done (refactor phase)
         │
    FAIL ▼
┌──────────────────┐
│ Implement fix    │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Iteration < Max? │
└────────┬─────────┘
         │
    YES  ├──────────────────► Loop back to "Run tests"
         │
    NO   ▼
┌──────────────────┐
│ Report failure   │
│ Ask for help     │
└──────────────────┘
```

### Preventing Test Gaming

1. **Red-Green Verification**
   - Tests MUST fail before implementation
   - If new tests pass immediately, they're suspect

2. **Assertion Density**
   - Minimum 2 assertions per test
   - No `assert True` or `assert obj`

3. **Mutation Score**
   - Run mutation testing periodically
   - Score below 80% = weak tests

4. **Human Checkpoints**
   - After 10 iterations, pause for review
   - Show test quality metrics
   - Ask: "Continue or adjust approach?"

---

## Implementation Phases

### Phase 1: Foundation (Week 1)
- [ ] Implement Stop hook for TDD loops
- [ ] Create path-specific rules structure
- [ ] Add rules for Django models, views, tests
- [ ] Update agent frontmatter with skills

### Phase 2: TDD Loop (Week 2)
- [ ] Create /tdd-loop command
- [ ] Create test-validity-checker skill
- [ ] Implement mutation testing integration
- [ ] Add iteration limits and checkpoints

### Phase 3: Hooks (Week 3)
- [ ] UserPromptSubmit convention injection
- [ ] PostToolUse output validation
- [ ] PermissionRequest auto-approval rules
- [ ] SessionStart context loading

### Phase 4: Plugin Completion (Week 4)
- [ ] Complete smi-nuxtjs skills
- [ ] Add NestJS path-specific rules
- [ ] Add Next.js/Nuxt.js path-specific rules
- [ ] Update all READMEs

### Phase 5: Testing & Documentation (Week 5)
- [ ] Test all hooks work correctly
- [ ] Test TDD loop with real features
- [ ] Update documentation
- [ ] Create usage examples

---

## Reference Resources

### Official
- [Claude Code CHANGELOG](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md)
- [Claude Code Releases](https://github.com/anthropics/claude-code/releases)

### Paddo.dev Articles
- [Ralph Wiggum: Autonomous Loops](https://paddo.dev/blog/ralph-wiggum-autonomous-loops/)
- [Path-Specific Rules Native](https://paddo.dev/blog/claude-rules-path-specific-native/)
- [Skills + Hooks Solution](https://paddo.dev/blog/claude-skills-hooks-solution/)
- [Claude Tools Plugin Marketplace](https://paddo.dev/blog/claude-tools-plugin-marketplace/)
- [Visual Verification](https://paddo.dev/blog/visual-verification-making-agents-prove-work/)

### Key Quotes

> "You give it a prompt, it works until done (or until you stop it)."
> — Ralph Wiggum pattern

> "Better to fail predictably than succeed unpredictably."
> — Geoffrey Huntley

> "Skills load based on your working directory, eliminating manual activation friction."
> — Skills + Hooks Solution

> "Semantic triggering works for context selection. Explicit controls matter for workflow orchestration."
> — Paddo.dev

---

## Success Criteria

1. **Stop Hook Works**: TDD loop runs until tests pass
2. **Path Rules Active**: Different rules for models vs views vs tests
3. **No Shortcuts**: Test validity checker catches gaming
4. **90%+ Coverage**: Enforced via hooks
5. **Clean Docs**: README matches reality
6. **Complete Plugins**: All plugins have skills/rules

---

## Next Steps

1. Review this plan
2. Approve phases
3. Start with Phase 1 (Stop hook implementation)
4. Test with real Django project
5. Iterate based on feedback
