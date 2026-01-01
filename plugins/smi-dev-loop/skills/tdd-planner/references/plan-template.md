# Dev Loop Plan Template

Use this template when generating dev-loop plans. Replace placeholders with actual values.

---

## Template

```markdown
# Dev Loop Plan: {{GOAL}}

Generated: {{TIMESTAMP}}
Framework: {{FRAMEWORK}}

---

## Context

- **Framework:** {{FRAMEWORK}}
- **Test Runner:** {{TEST_COMMAND}}
- **Lint Command:** {{LINT_COMMAND}}
- **Coverage:** {{COVERAGE_COMMAND}}

## Success Criteria

All of the following must be true:

- [ ] {{CRITERION_1}}
- [ ] {{CRITERION_2}}
- [ ] {{CRITERION_3}}
- [ ] All tests pass (`{{TEST_COMMAND}}`)
- [ ] Linter clean (`{{LINT_COMMAND}}`)

---

## Phases

{{#PHASES}}

### Phase {{PHASE_NUMBER}}: {{PHASE_TYPE}} - {{COMPONENT}}

**Goal:** {{PHASE_GOAL}}

**Tasks:**
{{#TASKS}}
- [ ] {{TASK}}
{{/TASKS}}

**Verification:**
```bash
{{VERIFICATION_COMMAND}}
```
Expected: {{EXPECTED_RESULT}}

**Self-correction:**
- {{SELF_CORRECTION_RULE}}

{{/PHASES}}

---

## Final Verification

Run all checks before declaring complete:

```bash
{{FINAL_VERIFICATION}}
```

All commands must succeed with exit code 0.

---

## Completion

When ALL of the above pass, and you have verified each criterion, output:

```
<promise>DONE</promise>
```

**Important:** Only output the promise when genuinely complete. Premature completion wastes iterations.

---

## Stuck Handling

If you encounter the same error for 3+ iterations:

1. **Stop and analyze**
   - What exactly is the error message?
   - Which file and line?
   - What did you try?

2. **Try alternatives**
   - Different implementation approach
   - Simpler version first
   - Check existing similar code

3. **Verify basics**
   - Are you editing the right file?
   - Did the file save correctly?
   - Is the test targeting your code?

4. **Simplify**
   - Comment out complex parts
   - Get minimal case working
   - Add complexity incrementally

---

## Notes

{{ADDITIONAL_NOTES}}
```

---

## Example: Django User Authentication

```markdown
# Dev Loop Plan: User Authentication with JWT

Generated: 2026-01-01T00:00:00Z
Framework: Django

---

## Context

- **Framework:** Django 5.0 with DRF
- **Test Runner:** pytest --tb=short
- **Lint Command:** ruff check .
- **Coverage:** pytest --cov=users --cov-report=term-missing

## Success Criteria

All of the following must be true:

- [ ] User model with email as username
- [ ] Login endpoint returns JWT token
- [ ] Logout endpoint invalidates token
- [ ] Protected endpoint requires valid token
- [ ] All tests pass (`pytest --tb=short`)
- [ ] Linter clean (`ruff check .`)

---

## Phases

### Phase 1: Red - User Model Tests

**Goal:** Write failing tests for custom User model

**Tasks:**
- [ ] Create tests/test_models.py
- [ ] Test user creation with email
- [ ] Test password hashing
- [ ] Test email uniqueness

**Verification:**
```bash
pytest tests/test_models.py -v
```
Expected: Tests should FAIL (model not implemented)

**Self-correction:**
- If tests pass, model already exists or tests are wrong

### Phase 2: Green - User Model Implementation

**Goal:** Implement User model to pass tests

**Tasks:**
- [ ] Create custom User model
- [ ] Set email as USERNAME_FIELD
- [ ] Create UserManager
- [ ] Run migrations

**Verification:**
```bash
pytest tests/test_models.py -v
```
Expected: Tests should PASS

**Self-correction:**
- If tests fail, read error and fix implementation

### Phase 3: Refactor - User Model Cleanup

**Goal:** Clean code, add documentation

**Tasks:**
- [ ] Add type hints
- [ ] Add docstrings
- [ ] Follow Smicolon import conventions

**Verification:**
```bash
pytest tests/test_models.py && ruff check users/
```
Expected: Tests pass AND lint clean

### Phase 4: Red - Auth Endpoint Tests

**Goal:** Write failing tests for login/logout

**Tasks:**
- [ ] Create tests/test_auth.py
- [ ] Test login returns token
- [ ] Test logout invalidates token
- [ ] Test invalid credentials

**Verification:**
```bash
pytest tests/test_auth.py -v
```
Expected: Tests should FAIL

### Phase 5: Green - Auth Endpoints

**Goal:** Implement auth endpoints

**Tasks:**
- [ ] Create login view
- [ ] Create logout view
- [ ] Configure JWT settings
- [ ] Add URLs

**Verification:**
```bash
pytest tests/test_auth.py -v
```
Expected: Tests should PASS

### Phase 6: Refactor - Auth Cleanup

**Goal:** Final cleanup and documentation

**Tasks:**
- [ ] Add API documentation
- [ ] Clean up imports
- [ ] Add error handling

**Verification:**
```bash
pytest && ruff check .
```

---

## Final Verification

```bash
pytest --tb=short && ruff check . && echo "ALL CHECKS PASSED"
```

---

## Completion

<promise>DONE</promise>
```

---

## Variable Reference

| Variable | Description | Example |
|----------|-------------|---------|
| `{{GOAL}}` | High-level objective | "User Authentication with JWT" |
| `{{FRAMEWORK}}` | Detected framework | "Django 5.0" |
| `{{TEST_COMMAND}}` | Test runner command | "pytest --tb=short" |
| `{{LINT_COMMAND}}` | Linter command | "ruff check ." |
| `{{COVERAGE_COMMAND}}` | Coverage command | "pytest --cov" |
| `{{PHASE_NUMBER}}` | Phase sequence number | "1", "2", "3" |
| `{{PHASE_TYPE}}` | Red, Green, or Refactor | "Red" |
| `{{COMPONENT}}` | What's being built | "User Model" |
| `{{PHASE_GOAL}}` | Specific phase objective | "Write failing tests" |
| `{{VERIFICATION_COMMAND}}` | Command to verify phase | "pytest tests/test_models.py" |
| `{{EXPECTED_RESULT}}` | What success looks like | "Tests should PASS" |
