# Phase 1: Stop Hooks Implementation

**Goal**: Enable ralph-wiggum style autonomous loops for TDD

---

## Background

From [paddo.dev/ralph-wiggum-autonomous-loops](https://paddo.dev/blog/ralph-wiggum-autonomous-loops/):

> Ralph Wiggum implements persistent development loops using Stop hooks. When Claude attempts to exit, the mechanism intercepts the exit code 2, re-injects the original prompt, and continues iteration.

The core principle: **"Better to fail predictably than succeed unpredictably."**

---

## Tasks

### 1.1 Create Hook Directory Structure

```bash
# Create for each plugin
mkdir -p plugins/smi-django/hooks
mkdir -p plugins/smi-nestjs/hooks
mkdir -p plugins/smi-nextjs/hooks
mkdir -p plugins/smi-nuxtjs/hooks
```

### 1.2 Create hooks.json Configuration

**File**: `plugins/smi-django/hooks/hooks.json`

```json
{
  "hooks": [
    {
      "event": "Stop",
      "type": "prompt",
      "prompt": "${CLAUDE_PLUGIN_ROOT}/hooks/tdd-loop-controller.md",
      "timeout": 30000
    },
    {
      "event": "SubagentStop",
      "type": "prompt",
      "prompt": "${CLAUDE_PLUGIN_ROOT}/hooks/subagent-continuation.md",
      "timeout": 10000
    }
  ]
}
```

### 1.3 Create TDD Loop Controller

**File**: `plugins/smi-django/hooks/tdd-loop-controller.md`

```markdown
---
name: TDD Loop Controller
description: Continues TDD iterations until tests pass or max iterations reached
---

# TDD Loop Controller

## Current State Analysis

You are evaluating whether to continue or exit a TDD loop.

### Exit Conditions (ALLOW EXIT)

1. **All Tests Pass**
   - Test command exited with code 0
   - Coverage >= 90%
   - No failing tests

2. **Max Iterations Reached**
   - Default: 20 iterations
   - User-specified via --max-iterations
   - Report summary and ask for guidance

3. **User Interrupt**
   - Exit code 2 (SIGINT)
   - User explicitly requested stop

4. **Unrecoverable Error**
   - Syntax errors in test files
   - Missing dependencies
   - Environment issues

### Continue Conditions (RE-INJECT PROMPT)

1. **Tests Failing**
   - Analyze failure messages
   - Identify root cause
   - Generate fix strategy

2. **Coverage Below 90%**
   - Identify uncovered code
   - Generate additional tests
   - Continue loop

3. **Test Validity Issues**
   - Empty tests detected
   - Weak assertions
   - Generate proper tests

## Decision Output

Respond with ONE of:

**CONTINUE:**
```
LOOP_CONTINUE
Iteration: {current}/{max}
Next Action: {implement fix | add tests | refactor}
Target: {specific file or function}
Reason: {why continuing}
```

**EXIT:**
```
LOOP_EXIT
Status: {success | max_iterations | user_interrupt | error}
Summary:
- Tests: {passed}/{total}
- Coverage: {percentage}%
- Iterations: {count}
```

## Anti-Shortcut Rules

1. **Never modify tests to make them pass**
   - Fix implementation, not tests
   - Unless tests are genuinely wrong

2. **Never skip failing tests**
   - No @pytest.mark.skip without reason
   - No commented-out tests

3. **Never reduce coverage to pass**
   - Coverage must increase or stay same
   - Never delete tests to improve pass rate

4. **Pause at checkpoints**
   - Every 10 iterations: show status
   - Every 5 failures on same test: ask for help
```

### 1.4 Create Subagent Continuation Hook

**File**: `plugins/smi-django/hooks/subagent-continuation.md`

```markdown
---
name: Subagent Continuation
description: Handle subagent completion and decide next steps
---

# Subagent Completion Handler

## Context
A subagent has completed its task. Analyze the result and decide next action.

## Analysis Criteria

### Success (agent_id: test-runner)
- All tests passed
- Return: CONTINUE_PARENT with success

### Failure (agent_id: test-runner)
- Some tests failed
- Extract failure details
- Return: CONTINUE_PARENT with failure info for main loop

### Success (agent_id: coverage-analyzer)
- Coverage report generated
- Parse coverage percentage
- Return: CONTINUE_PARENT with coverage data

## Output Format

```
SUBAGENT_RESULT
agent_id: {id}
status: {success | failure}
data: {relevant extracted data}
next_action: {continue_loop | ask_user | complete}
```
```

### 1.5 Create Loop State Tracker

**File**: `plugins/smi-django/hooks/loop-state.md`

```markdown
---
name: Loop State Tracker
description: Track iteration state across Stop hook invocations
---

# Loop State Management

## State Variables

Track in conversation context:
- `LOOP_ITERATION`: Current iteration number
- `MAX_ITERATIONS`: Limit (default: 20)
- `ORIGINAL_PROMPT`: Initial user request
- `FAILING_TESTS`: List of currently failing tests
- `LAST_COVERAGE`: Coverage percentage from last run
- `CONSECUTIVE_FAILURES`: Same test failing repeatedly

## State Update Rules

After each iteration:
1. Increment LOOP_ITERATION
2. Update FAILING_TESTS from test output
3. Update LAST_COVERAGE from coverage report
4. Track CONSECUTIVE_FAILURES for same test

## Checkpoint Logic

```
if LOOP_ITERATION % 10 == 0:
    PAUSE for user review
    Show: iteration, coverage, failing tests
    Ask: continue, adjust, or stop?

if CONSECUTIVE_FAILURES >= 5:
    PAUSE for user help
    Show: stuck test, attempted fixes
    Ask: manual intervention needed?
```
```

### 1.6 Update marketplace.json

Add hooks to plugin configuration:

```json
{
  "name": "smi-django",
  "version": "1.2.0",
  "hooks": [
    "./hooks/hooks.json"
  ]
}
```

---

## Testing Plan

### Test 1: Basic TDD Loop

```bash
# Create failing test
echo "def test_example(): assert False" > test_example.py

# Run TDD loop
/tdd-loop "make test pass"

# Expected: Loop continues until test passes
```

### Test 2: Max Iterations

```bash
# Create impossible test
echo "def test_impossible(): assert 1 == 2" > test_impossible.py

# Run with low limit
/tdd-loop "make test pass" --max-iterations 3

# Expected: Exits after 3 iterations with summary
```

### Test 3: Coverage Enforcement

```bash
# Create service without tests
# Run TDD loop

# Expected: Generates tests, runs until 90%+ coverage
```

---

## Success Criteria

- [ ] Stop hook intercepts exit code 2
- [ ] Loop continues on test failure
- [ ] Loop exits on test success
- [ ] Loop exits at max iterations
- [ ] Checkpoints pause at intervals
- [ ] State tracked across iterations
- [ ] Anti-shortcut rules enforced

---

## Files to Create

1. `plugins/smi-django/hooks/hooks.json`
2. `plugins/smi-django/hooks/tdd-loop-controller.md`
3. `plugins/smi-django/hooks/subagent-continuation.md`
4. `plugins/smi-django/hooks/loop-state.md`

Replicate for other plugins as needed.
