# Dev Loop Plan Template

Use this template when generating dev-loop plans. Every section is **required** unless marked optional.

---

## Quality Checklist

Before saving a plan, verify:

- [ ] Context lists **specific items** to work on (not just "the feature")
- [ ] Success criteria are **measurable** (numbers, specific behaviors)
- [ ] **Every task** has a file path
- [ ] **Code snippets** show implementation structure
- [ ] Verification has **expected output** (PASS/FAIL + why)
- [ ] Self-correction is **phase-specific**, not generic
- [ ] **Files to Modify** table exists
- [ ] **New Files to Create** table exists
- [ ] Stuck handling is **framework/task-specific**

---

## Template

```markdown
# Dev Loop Plan: {{GOAL}}

Generated: {{TIMESTAMP}}

---

## Context

- **Framework**: {{FRAMEWORK}}
- **Current State**: {{CURRENT_STATE}} (e.g., "Provider with ChangeNotifierProvider")
- **Test Command**: `{{TEST_COMMAND}}`
- **Lint Command**: `{{LINT_COMMAND}}`
- **Coverage Command**: `{{COVERAGE_COMMAND}}` (optional)
- **Items to Work On**:
{{#WORK_ITEMS}}
  - `{{ITEM_NAME}}` ({{ITEM_DESCRIPTION}})
{{/WORK_ITEMS}}

---

## Success Criteria

All of the following must be true:

{{#SUCCESS_CRITERIA}}
- [ ] {{CRITERION}}
{{/SUCCESS_CRITERIA}}
- [ ] All tests pass (`{{TEST_COMMAND}}`)
- [ ] Linter clean (`{{LINT_COMMAND}}`)

---

## Acceptance Criteria (Optional but Recommended)

User-facing behaviors to verify:

{{#ACCEPTANCE_CRITERIA}}
### {{AC_NUMBER}}. {{AC_TITLE}}
- **Given**: {{GIVEN}}
- **When**: {{WHEN}}
- **Then**: {{THEN}}
{{/ACCEPTANCE_CRITERIA}}

---

## Files to Modify

| File | Action |
|------|--------|
{{#FILES_TO_MODIFY}}
| `{{FILE_PATH}}` | {{ACTION}} |
{{/FILES_TO_MODIFY}}

---

## New Files to Create

| File | Purpose |
|------|---------|
{{#NEW_FILES}}
| `{{FILE_PATH}}` | {{PURPOSE}} |
{{/NEW_FILES}}

---

## Progress Tracking

**IMPORTANT:** After completing each task, update this file by checking the box:
- Change `- [ ]` to `- [x]` for completed tasks
- This tracks progress across iterations and prevents redoing work

---

## Phases

{{#PHASES}}

### Phase {{PHASE_NUMBER}}: {{PHASE_TYPE}} - {{COMPONENT}}

**Goal:** {{PHASE_GOAL}}

**Tasks:**
{{#TASKS}}
- [ ] {{TASK_DESCRIPTION}}
  {{#TASK_DETAILS}}
  - {{DETAIL}}
  {{/TASK_DETAILS}}
{{/TASKS}}

**Implementation Structure:** (include code snippet for Green phases)
```{{LANGUAGE}}
{{CODE_SNIPPET}}
```

**Verification:**
```bash
{{VERIFICATION_COMMAND}}
```
**Expected:** {{EXPECTED_RESULT}}

**Self-correction:**
- {{PHASE_SPECIFIC_CORRECTION}}

{{/PHASES}}

---

## Final Verification

```bash
{{FINAL_VERIFICATION}}
```

**Expected Results:**
{{#FINAL_EXPECTATIONS}}
- `{{COMMAND}}`: {{EXPECTATION}}
{{/FINAL_EXPECTATIONS}}

---

## Completion

When ALL criteria met: <promise>DONE</promise>

---

## Stuck Handling

### If same test keeps failing:
{{#STUCK_TEST_TIPS}}
1. {{TIP}}
{{/STUCK_TEST_TIPS}}

### If app/server won't start:
{{#STUCK_START_TIPS}}
1. {{TIP}}
{{/STUCK_START_TIPS}}

### Alternative approaches if blocked:
{{#ALTERNATIVE_APPROACHES}}
1. {{APPROACH}}
{{/ALTERNATIVE_APPROACHES}}

---

## Rollback Strategy (Optional)

If migration/feature fails completely:
1. {{ROLLBACK_STEP_1}}
2. {{ROLLBACK_STEP_2}}

---

## Dependencies & Prerequisites

{{#DEPENDENCIES}}
- {{DEPENDENCY}}: {{VERSION_OR_NOTES}}
{{/DEPENDENCIES}}

---

## Notes

{{ADDITIONAL_NOTES}}
```

---

## Example: Populated Template

See `references/good-example.md` for a complete, high-quality example.

---

## Variable Reference

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `{{GOAL}}` | High-level objective | "Migrate to Riverpod State Management" |
| `{{FRAMEWORK}}` | Detected framework | "Flutter", "Django 5.0", "Next.js 14" |
| `{{CURRENT_STATE}}` | What exists now | "Provider with ChangeNotifierProvider" |
| `{{TEST_COMMAND}}` | Test runner command | "flutter test", "pytest" |
| `{{LINT_COMMAND}}` | Linter command | "flutter analyze", "ruff check ." |
| `{{WORK_ITEMS}}` | Specific items to work on | List of components, providers, endpoints |
| `{{FILES_TO_MODIFY}}` | Existing files to change | Table with file paths and actions |
| `{{NEW_FILES}}` | Files to create | Table with file paths and purposes |

### Phase Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `{{PHASE_TYPE}}` | Red, Green, or Refactor | "Red", "Green", "Refactor" |
| `{{COMPONENT}}` | What's being built | "Core Providers", "Widget Migration" |
| `{{CODE_SNIPPET}}` | Implementation structure | Actual code showing pattern |
| `{{EXPECTED_RESULT}}` | What success looks like | "should FAIL (providers don't exist yet)" |
| `{{PHASE_SPECIFIC_CORRECTION}}` | Phase-specific stuck handling | "If tests pass, they're not testing the right thing" |

### Task Detail Pattern

Tasks should include file paths and specifics:

**Bad:**
```markdown
- [ ] Create login view
```

**Good:**
```markdown
- [ ] Create `lib/screens/login_screen.dart`:
  - ConsumerStatefulWidget
  - Form with email/password fields
  - Calls `ref.read(authProvider.notifier).login()`
  - Navigates to home on success
```

---

## Framework-Specific Patterns

### Flutter
- Use `ConsumerWidget` / `ConsumerStatefulWidget`
- Wrap app in `ProviderScope`
- Test with `ProviderScope` in tests

### Django
- Use absolute imports (`import users.models as _models`)
- UUID primary keys on all models
- Service layer for business logic

### Next.js
- Use `"use client"` directive for client components
- TanStack Query for data fetching
- Zod schemas for validation

### NestJS
- Barrel exports (`index.ts` in each folder)
- Absolute imports from `src/`
- DTOs with class-validator

---

## Anti-Patterns to Avoid

1. **Vague tasks**: "Implement the feature" (no file paths)
2. **Generic self-correction**: "If it fails, try again" (not specific)
3. **Missing code snippets**: No structure shown for implementation
4. **No file tables**: Unclear what files are affected
5. **Unmeasurable criteria**: "App works well" (how do you verify?)
