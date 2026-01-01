# Phase 3: TDD Integration Strategy

**Goal**: Test-first development with verification loops and anti-shortcut measures

---

## The Problem: AI Agents Taking Shortcuts

From practical experience, AI agents may:

1. **Write tests that always pass** - No assertions or trivial assertions
2. **Test implementation details** - Not behavior
3. **Skip edge cases** - Only happy path
4. **Modify tests to pass** - Instead of fixing code
5. **Delete failing tests** - To improve pass rate

This defeats the purpose of TDD.

---

## Solution: Multi-Layer Verification

```
┌─────────────────────────────────────────────────────┐
│              Layer 1: Stop Hook                      │
│   Intercepts exit, re-injects if tests still fail   │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│           Layer 2: Test Validity Skill              │
│   Checks tests are meaningful BEFORE running        │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│          Layer 3: Red-Green Verification            │
│   New tests MUST fail before implementation         │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│           Layer 4: Coverage Gate                    │
│   pytest --cov-fail-under=90                        │
└─────────────────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────┐
│          Layer 5: Mutation Testing                  │
│   mutmut verifies tests actually catch bugs         │
└─────────────────────────────────────────────────────┘
```

---

## Tasks

### 3.1 Create TDD Loop Command

**File**: `plugins/smi-django/commands/tdd-loop.md`

```markdown
---
name: tdd-loop
description: Run TDD loop until all tests pass with 90%+ coverage
args:
  - name: feature
    description: Feature to implement
    required: true
  - name: max-iterations
    description: Maximum loop iterations (default: 20)
    required: false
  - name: coverage-target
    description: Minimum coverage percentage (default: 90)
    required: false
---

# TDD Loop: $FEATURE

## Overview

This command implements Test-Driven Development with autonomous looping.

**Philosophy**: "Better to fail predictably than succeed unpredictably."

## Phase 1: Red (Write Failing Tests)

### 1.1 Analyze Requirements

Before writing any code:
1. Understand the feature requirements
2. Identify edge cases
3. List expected behaviors
4. Define success criteria

### 1.2 Generate Test Cases

Using the test-coverage-advisor skill, generate tests for:

**Unit Tests (80%)**:
- Model methods
- Service functions
- Utility functions
- Validators

**Integration Tests (15%)**:
- API endpoints
- Workflows
- Cross-service interactions

**Edge Cases (5%)**:
- Invalid inputs
- Boundary conditions
- Error scenarios
- Concurrent operations

### 1.3 Write Test File

```python
# tests/test_$FEATURE.py
import pytest
import app.models as _models
import app.services as _services

@pytest.mark.django_db
class Test$FEATURE:
    """Tests for $FEATURE."""

    # Happy path
    def test_$FEATURE_success(self):
        # Arrange
        # Act
        # Assert (minimum 2 assertions)
        pass

    # Error cases
    def test_$FEATURE_invalid_input(self):
        with pytest.raises(ValidationError):
            # ...
        pass

    # Edge cases
    def test_$FEATURE_boundary_condition(self):
        # ...
        pass
```

### 1.4 Verify Tests Fail

```bash
pytest tests/test_$FEATURE.py -v
# Expected: FAILURES (red phase)
```

**CRITICAL**: If tests pass before implementation, they are WRONG.
- Tests must fail first
- This proves they actually test something
- If they pass, regenerate with stricter assertions

## Phase 2: Green (Implement Minimal Code)

### 2.1 Start Implementation Loop

```
ITERATION = 1
while tests_failing AND ITERATION <= MAX_ITERATIONS:
    run pytest
    if all_pass:
        break
    analyze_failure()
    implement_minimal_fix()
    ITERATION += 1
```

### 2.2 Minimal Implementation Rules

- Write ONLY enough code to pass current failing test
- Don't anticipate future requirements
- Don't optimize prematurely
- Keep it simple

### 2.3 Check Coverage

```bash
pytest --cov=app --cov-report=term-missing --cov-fail-under=$COVERAGE_TARGET
```

If coverage < target:
- Identify uncovered lines
- Generate additional tests
- Continue loop

## Phase 3: Refactor (Improve While Green)

### 3.1 Apply Skills

With all tests passing:
1. `performance-optimizer` - Fix N+1 queries
2. `security-first-validator` - Add missing security
3. `import-convention-enforcer` - Fix imports

### 3.2 Run Tests After Each Change

```bash
pytest -x  # Stop at first failure
```

If refactor breaks tests:
- Revert change
- Try different approach
- Or keep original (working > pretty)

## Anti-Shortcut Measures

### Measure 1: Assertion Density Check

```python
# BAD - Will be flagged
def test_user():
    user = create_user()
    assert user  # Only 1 assertion, too weak

# GOOD - Passes check
def test_user():
    user = create_user()
    assert user.id is not None
    assert user.email == 'test@example.com'
    assert user.created_at is not None
```

Minimum: 2 meaningful assertions per test

### Measure 2: Red Phase Verification

Before implementation:
```bash
pytest tests/test_$FEATURE.py --tb=no
# MUST show failures
```

If tests pass:
```
⚠️ WARNING: Tests passed before implementation!
This indicates tests are not testing actual behavior.
Regenerating stricter tests...
```

### Measure 3: Coverage Must Increase

Track coverage across iterations:
```
Iteration 1: 45% → Iteration 2: 52% → ... → Final: 92%
```

If coverage DECREASES:
```
⚠️ WARNING: Coverage dropped from 52% to 48%!
This may indicate tests were removed or code was duplicated.
Investigating...
```

### Measure 4: Mutation Testing (Periodic)

Every 5 iterations:
```bash
mutmut run --paths-to-mutate=app/
mutmut results
```

If mutation score < 80%:
```
⚠️ WARNING: Mutation score is 65%
35% of code changes would NOT be caught by tests.
Tests need strengthening...
```

### Measure 5: Human Checkpoints

Every 10 iterations:
```
═══════════════════════════════════════════
CHECKPOINT: Iteration 10 of 20
═══════════════════════════════════════════

Status:
- Tests: 8 passed, 2 failed
- Coverage: 78% (target: 90%)
- Failing: test_create_user_concurrent, test_delete_cascade

Options:
1. Continue (10 more iterations)
2. Adjust approach (describe new strategy)
3. Stop and review (manual intervention)

Choice?
```

## Exit Conditions

### Success Exit

```
✅ TDD LOOP COMPLETE

Summary:
- Feature: User Authentication
- Iterations: 7
- Tests: 15 passed, 0 failed
- Coverage: 94%

Files Created:
- users/models.py (User model)
- users/services.py (AuthService)
- users/tests/test_auth.py (15 tests)
```

### Max Iterations Exit

```
⚠️ MAX ITERATIONS REACHED

Summary:
- Feature: User Authentication
- Iterations: 20 (limit)
- Tests: 12 passed, 3 failed
- Coverage: 81%

Stuck On:
- test_concurrent_login (failed 8 times)
- test_token_refresh (failed 5 times)

Recommended:
- Review failing tests manually
- Consider architectural changes
- Ask for human guidance
```

## Configuration

### pytest.ini

```ini
[pytest]
DJANGO_SETTINGS_MODULE = config.settings.test
python_files = test_*.py *_test.py
addopts = -v --cov=. --cov-report=term-missing --cov-fail-under=90
markers =
    slow: marks tests as slow
    integration: marks integration tests
```

### .mutmut

```
[mutmut]
paths_to_mutate=app/
tests_dir=tests/
runner=pytest
```
```

### 3.2 Create Test Validity Checker Skill

**File**: `plugins/smi-django/skills/test-validity-checker/SKILL.md`

```markdown
---
name: test-validity-checker
description: Verify tests are meaningful and not shortcuts. Activates when writing tests, before running test suites, or when test coverage is mentioned.
---

# Test Validity Checker

Auto-validates that tests are meaningful and catch real bugs.

## When This Skill Activates

- Writing test files
- Before pytest execution
- When test coverage is checked
- When TDD loop is running

## Validity Checks

### Check 1: Empty Test Detection

```python
# INVALID - Empty body
def test_user():
    pass

# INVALID - Only setup, no assertions
def test_create():
    user = create_user()
    # No assertions!

# VALID
def test_user_creation():
    user = create_user()
    assert user.id is not None
    assert user.is_active
```

**Action**: Flag empty tests, require assertions

### Check 2: Trivial Assertion Detection

```python
# INVALID - Always passes
def test_always_passes():
    assert True

def test_truthy():
    user = create_user()
    assert user  # Just checks existence

# INVALID - Testing constants
def test_constant():
    assert 1 + 1 == 2

# VALID - Tests actual behavior
def test_user_email_lowercase():
    user = create_user(email='TEST@Example.COM')
    assert user.email == 'test@example.com'
```

**Action**: Require value comparisons, not just truthiness

### Check 3: Assertion Count

```python
# WEAK - Only 1 assertion
def test_single_assertion():
    response = client.get('/api/users/')
    assert response.status_code == 200

# STRONG - Multiple assertions
def test_list_users():
    response = client.get('/api/users/')
    assert response.status_code == 200
    assert 'results' in response.data
    assert len(response.data['results']) > 0
    assert 'email' in response.data['results'][0]
```

**Minimum**: 2 meaningful assertions per test

### Check 4: Edge Case Coverage

For each function under test, require:

- ✅ Happy path (valid input → expected output)
- ✅ Invalid input (validation error)
- ✅ Boundary conditions (min, max, empty)
- ✅ Error handling (exceptions caught)

```python
# Complete test suite example
class TestUserService:
    # Happy path
    def test_create_user_success(self):
        ...

    # Invalid input
    def test_create_user_invalid_email(self):
        with pytest.raises(ValidationError):
            ...

    # Boundary
    def test_create_user_max_length_name(self):
        user = create_user(name='x' * 255)  # Max length
        ...

    # Error handling
    def test_create_user_database_error(self, mocker):
        mocker.patch('app.models.User.save', side_effect=DatabaseError)
        with pytest.raises(ServiceError):
            ...
```

### Check 5: Test Independence

```python
# INVALID - Shared state
shared_user = None

def test_create():
    global shared_user
    shared_user = create_user()  # Modifies global

def test_read():
    assert shared_user.email  # Depends on previous test

# VALID - Independent tests
def test_create(user_factory):
    user = user_factory()
    assert user.id

def test_read(user_factory):
    user = user_factory()
    assert user.email
```

**Action**: Each test must be runnable in isolation

### Check 6: No Mocking Internals

```python
# INVALID - Testing implementation
def test_service_calls_model(self, mocker):
    mock_create = mocker.patch('User.objects.create')
    service.create_user(data)
    mock_create.assert_called_once()  # Tests HOW, not WHAT

# VALID - Testing behavior
def test_service_creates_user(self):
    user = service.create_user(data)
    assert User.objects.filter(id=user.id).exists()  # Tests WHAT
```

## Validation Report

When checking tests, output:

```
═══════════════════════════════════════════
TEST VALIDITY REPORT
═══════════════════════════════════════════

File: tests/test_user_service.py

✅ test_create_user_success
   - Assertions: 4 ✓
   - Tests behavior: Yes ✓
   - Independent: Yes ✓

⚠️ test_create_user_validation
   - Assertions: 1 ⚠️ (minimum 2)
   - Suggestion: Add assertion for error message

❌ test_trivial
   - Issue: assert True (trivial)
   - Action: Remove or rewrite

Summary:
- Valid: 8/10
- Warnings: 1
- Invalid: 1

Recommendation: Fix 2 issues before continuing
```

## Auto-Fix Actions

When issues detected:

1. **Empty test** → Generate test body
2. **Trivial assertion** → Suggest meaningful assertion
3. **Low assertion count** → Add more assertions
4. **Missing edge cases** → Generate edge case tests
5. **Shared state** → Refactor to fixtures
```

### 3.3 Create Red Phase Verifier Skill

**File**: `plugins/smi-django/skills/red-phase-verifier/SKILL.md`

```markdown
---
name: red-phase-verifier
description: Ensure tests fail before implementation (red phase of TDD). Activates when writing tests during TDD loop.
---

# Red Phase Verifier

Ensures tests are written BEFORE implementation and fail initially.

## Purpose

In TDD:
1. **RED**: Write failing tests
2. **GREEN**: Implement to pass
3. **REFACTOR**: Improve while green

This skill enforces Step 1.

## When This Skill Activates

- During /tdd-loop command
- When test files created before implementation
- When "write tests first" mentioned

## Verification Process

### Step 1: Check Implementation Exists

```python
# If implementing UserService.create_user:
# Check if method exists and has logic

import inspect
from app.services import UserService

method = getattr(UserService, 'create_user', None)
if method:
    source = inspect.getsource(method)
    if 'pass' not in source and 'raise NotImplementedError' not in source:
        # Implementation exists!
        WARN: "Implementation found before tests"
```

### Step 2: Run Tests

```bash
pytest tests/test_new_feature.py -v --tb=short
```

### Step 3: Verify Failures

Expected output:
```
FAILED tests/test_new_feature.py::test_create - AssertionError
FAILED tests/test_new_feature.py::test_validate - AttributeError
```

### Step 4: Report

```
═══════════════════════════════════════════
RED PHASE VERIFICATION
═══════════════════════════════════════════

Tests written: 5
Tests failing: 5 ✅

Red phase confirmed!
Implementation may now proceed.
```

## Warning Cases

### Case 1: Tests Pass Before Implementation

```
⚠️ WARNING: Tests passed before implementation!

Failing tests: 0/5

This indicates:
1. Tests don't test new functionality
2. Tests have trivial assertions
3. Implementation already exists

Action: Regenerate stricter tests
```

### Case 2: Partial Failures

```
⚠️ PARTIAL RED PHASE

Tests failing: 3/5
Tests passing: 2/5

Passing tests may be:
1. Testing existing functionality (OK)
2. Trivial assertions (NOT OK)

Review passing tests:
- test_helper_exists: assert helper ← TRIVIAL
- test_constant: assert X == X ← TRIVIAL

Action: Strengthen or remove trivial tests
```

### Case 3: Wrong Failure Type

```
⚠️ UNEXPECTED FAILURE TYPE

test_create_user: SyntaxError in test file

Tests should fail due to:
- AssertionError (expected behavior not met)
- AttributeError (method doesn't exist yet)
- NotImplementedError (placeholder)

NOT due to:
- SyntaxError (test file broken)
- ImportError (missing dependency)
- TypeError (wrong arguments)

Action: Fix test file syntax
```

## Enforcement

When red phase not verified:

```
❌ CANNOT PROCEED TO GREEN PHASE

Red phase requirements not met:
- 2 tests passed before implementation
- 1 test has syntax error

Fix issues, then run verification again.
```
```

### 3.4 Update hooks.json for TDD

Add TDD-specific hooks:

```json
{
  "hooks": [
    {
      "event": "Stop",
      "type": "prompt",
      "prompt": "${CLAUDE_PLUGIN_ROOT}/hooks/tdd-loop-controller.md"
    },
    {
      "event": "PreToolUse",
      "type": "prompt",
      "prompt": "${CLAUDE_PLUGIN_ROOT}/hooks/tdd-write-guard.md",
      "matcher": {
        "tool": "Write|Edit",
        "path": "**/test*.py"
      }
    }
  ]
}
```

**TDD Write Guard** (`hooks/tdd-write-guard.md`):

```markdown
---
name: TDD Write Guard
description: Validate test files before writing
---

# Test File Write Guard

Before writing to test file, verify:

1. File follows naming convention (test_*.py)
2. Imports use absolute pattern
3. Tests have docstrings
4. Minimum assertions planned

If validation fails:
- Block write
- Show issues
- Suggest fixes
```

---

## Success Criteria

- [ ] /tdd-loop command created and functional
- [ ] Test validity checker catches shortcuts
- [ ] Red phase verification prevents early implementation
- [ ] Coverage gate enforces 90%+
- [ ] Human checkpoints pause at intervals
- [ ] Mutation testing integrated (optional)

---

## Files to Create

1. `plugins/smi-django/commands/tdd-loop.md`
2. `plugins/smi-django/skills/test-validity-checker/SKILL.md`
3. `plugins/smi-django/skills/red-phase-verifier/SKILL.md`
4. `plugins/smi-django/hooks/tdd-write-guard.md`
5. Update `plugins/smi-django/hooks/hooks.json`

Replicate for NestJS, Next.js as appropriate.
