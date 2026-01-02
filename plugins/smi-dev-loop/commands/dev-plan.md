---
name: dev-plan
description: Generate a structured TDD plan for dev-loop execution
argument-hint: '"Your goal" [--framework NAME] [--test-cmd "cmd"] [--lint-cmd "cmd"] [--interactive]'
allowed-tools: ["Read", "Write", "Glob", "Grep", "Bash", "AskUserQuestion"]
---

# Create Development Plan

Generate a high-quality, structured TDD plan for use with `/dev-loop --from-plan`.

**Quality Standard:** See `references/good-example.md` for the expected output quality.

---

## Steps

### 1. Parse Arguments

Extract from user input:
- **Goal**: The main objective (required)
- **--framework**: Override auto-detection (optional, any framework name)
- **--test-cmd**: Custom test command (optional, overrides auto-detect)
- **--lint-cmd**: Custom lint command (optional, overrides auto-detect)
- **--interactive**: Ask clarifying questions (optional)

### 2. Detect Framework

**Priority order:**
1. Use `--test-cmd` and `--lint-cmd` if provided (custom stack)
2. Use `--framework` if specified
3. Auto-detect from project files

**Auto-detection (first match wins):**

```bash
# Mobile
[ -f "pubspec.yaml" ] && grep -q "flutter:" pubspec.yaml && echo "flutter"
[ -f "package.json" ] && grep -q "react-native" package.json && echo "react-native"

# Python
[ -f "manage.py" ] && echo "django"
[ -f "pyproject.toml" ] && grep -q "fastapi" pyproject.toml && echo "fastapi"
[ -f "pyproject.toml" ] && grep -q "flask" pyproject.toml && echo "flask"

# Node.js
grep -q "@nestjs/core" package.json 2>/dev/null && echo "nestjs"
grep -q '"next"' package.json 2>/dev/null && echo "nextjs"
grep -q '"nuxt"' package.json 2>/dev/null && echo "nuxtjs"
grep -q '"hono"' package.json 2>/dev/null && echo "hono"
grep -q '"express"' package.json 2>/dev/null && echo "express"
grep -q '"@tanstack/react-router"' package.json 2>/dev/null && echo "tanstack"

# Go
[ -f "go.mod" ] && echo "go"

# Rust
[ -f "Cargo.toml" ] && echo "rust"

# Ruby
[ -f "Gemfile" ] && grep -q "rails" Gemfile && echo "rails"

# PHP
[ -f "composer.json" ] && grep -q "laravel" composer.json && echo "laravel"

# Generic fallbacks
[ -f "pyproject.toml" ] || [ -f "requirements.txt" ] && echo "python"
[ -f "package.json" ] && echo "node"
```

**Package Manager Detection (for Node.js projects):**

```bash
# Detect package manager (first match wins)
[ -f "bun.lockb" ] && PM="bun"
[ -f "pnpm-lock.yaml" ] && PM="pnpm"
[ -f "yarn.lock" ] && PM="yarn"
[ -f "package-lock.json" ] && PM="npm"
# Default to bun if no lockfile
[ -z "$PM" ] && PM="bun"
```

**Framework Commands Table:**

Use `${PM}` for the detected package manager (defaults to `bun`).

| Framework | Test Command | Lint Command |
|-----------|--------------|--------------|
| **Mobile** | | |
| Flutter | `flutter test` | `flutter analyze` |
| React Native | `${PM} test` | `${PM} run lint` |
| **Python** | | |
| Django | `pytest --tb=short` | `ruff check .` |
| FastAPI | `pytest --tb=short` | `ruff check .` |
| Flask | `pytest --tb=short` | `ruff check .` |
| Python (generic) | `pytest` | `ruff check .` |
| **Node.js** | | |
| NestJS | `${PM} test` | `${PM} run lint` |
| Next.js | `${PM} test` | `${PM} run lint` |
| Nuxt.js | `${PM} test` | `${PM} run lint` |
| Hono | `bun test` | `bun run lint` |
| Express | `${PM} test` | `${PM} run lint` |
| TanStack | `bun test` | `bun run lint` |
| Node (generic) | `${PM} test` | `${PM} run lint` |
| **Systems** | | |
| Go | `go test ./...` | `golangci-lint run` |
| Rust | `cargo test` | `cargo clippy` |
| **Web Frameworks** | | |
| Rails | `bundle exec rspec` | `bundle exec rubocop` |
| Laravel | `php artisan test` | `./vendor/bin/pint` |

**Unknown Framework Handling:**

If framework is unknown or not detected:
1. Check for common test files (`*_test.go`, `*_spec.rb`, `*.test.ts`)
2. Check package.json/pyproject.toml for test scripts
3. If `--interactive`, ask user for test/lint commands
4. Default: prompt user to specify `--test-cmd` and `--lint-cmd`

### 3. Deep Codebase Analysis

**CRITICAL:** Analyze the codebase thoroughly before planning.

Read and understand:
- [ ] Existing test files (understand testing patterns)
- [ ] Related modules/components (understand current structure)
- [ ] Configuration files (package.json, pubspec.yaml, etc.)
- [ ] Similar implementations (reuse patterns)
- [ ] Documentation (CLAUDE.md, README.md)

Identify specifically:
- **Current State**: What exists now that relates to the goal?
- **Work Items**: List each specific item to create/modify
- **Files to Modify**: Which existing files need changes?
- **New Files**: Which files need to be created?
- **Dependencies**: What packages/imports are needed?

### 4. Generate File Tables

**REQUIRED:** Every plan must include these tables.

#### Files to Modify

| File | Action |
|------|--------|
| `path/to/file.ext` | Description of changes |

#### New Files to Create

| File | Purpose |
|------|---------|
| `path/to/new/file.ext` | What this file does |

### 5. Create TDD Phases

For each component, create Red-Green-Refactor phases:

#### Phase Structure

```markdown
### Phase N: {{TYPE}} - {{COMPONENT}}

**Goal:** {{SPECIFIC_GOAL}}

**Tasks:**
- [ ] {{TASK}} in `{{FILE_PATH}}`:
  - {{DETAIL_1}}
  - {{DETAIL_2}}

**Implementation Structure:**
```{{language}}
// Show actual code structure expected
```

**Verification:**
```bash
{{COMMAND}}
```
**Expected:** {{OUTCOME}} (e.g., "should FAIL - tests don't exist yet")

**Self-correction:**
- {{PHASE_SPECIFIC_TIP}}
```

#### Phase Types

**Red Phase:**
- Write failing tests first
- Expected: Tests FAIL (implementation doesn't exist)
- Self-correction: "If tests pass, they're not testing the right thing"

**Green Phase:**
- Implement minimum code to pass tests
- Include code snippet showing structure
- Expected: Tests PASS
- Self-correction: "If tests fail, read error, fix implementation (not test)"

**Refactor Phase:**
- Clean up code, add types, documentation
- Expected: Tests still PASS, lint clean
- Self-correction: "If tests fail, refactoring broke something - revert"

### 6. Define Success Criteria

Measurable criteria with specifics:

```markdown
## Success Criteria

- [ ] {{SPECIFIC_BEHAVIOR}} (e.g., "Login returns JWT token")
- [ ] {{QUANTITATIVE}} (e.g., "81+ tests pass")
- [ ] {{NEGATIVE_CASE}} (e.g., "Invalid credentials return 401")
- [ ] All tests pass (`{{TEST_COMMAND}}`)
- [ ] Linter clean (`{{LINT_COMMAND}}`)
```

### 7. Add Acceptance Criteria (Optional)

For user-facing features, add Given/When/Then:

```markdown
## Acceptance Criteria

### 1. User can login with valid credentials
- **Given**: Valid email and password
- **When**: POST /api/auth/login
- **Then**: Returns 200 + JWT token

### 2. Invalid credentials rejected
- **Given**: Wrong password
- **When**: POST /api/auth/login
- **Then**: Returns 401 + error message
```

### 8. Add Stuck Handling

**REQUIRED:** Framework-specific stuck handling, not generic.

```markdown
## Stuck Handling

### If same test keeps failing:
1. Read the exact error message (not just "test failed")
2. Check if {{FRAMEWORK_SPECIFIC_THING}} is configured correctly
3. Verify {{COMMON_MISTAKE_FOR_THIS_FRAMEWORK}}
4. Check ProviderScope/dependency injection/imports

### If app/server won't start:
1. Check {{ENTRY_POINT_FILE}}
2. Verify {{INITIALIZATION_ORDER}}
3. Look for circular dependencies

### Alternative approaches if blocked:
1. {{SIMPLER_APPROACH}}
2. {{INCREMENTAL_APPROACH}}
3. {{FALLBACK_APPROACH}}
```

### 9. Quality Checklist

Before saving, verify the plan meets quality standards:

- [ ] Context lists **specific items** to work on
- [ ] Success criteria are **measurable**
- [ ] **Every task** has a file path
- [ ] **Code snippets** show implementation structure
- [ ] Verification has **expected output** with reasoning
- [ ] Self-correction is **phase-specific**
- [ ] **Files to Modify** table exists
- [ ] **New Files to Create** table exists
- [ ] Stuck handling is **framework-specific**

### 10. Save Plan

Save to `.claude/dev-plan.local.md`:

```markdown
# Dev Loop Plan: {{GOAL}}

Generated: {{TIMESTAMP}}

---

## Context
[Framework, test/lint commands, work items...]

## Success Criteria
[Measurable outcomes...]

## Acceptance Criteria (if applicable)
[Given/When/Then...]

## Files to Modify
[Table...]

## New Files to Create
[Table...]

## Progress Tracking
[Instructions...]

## Phases
[Red/Green/Refactor phases with code snippets...]

## Final Verification
[Combined verification command...]

## Completion
When ALL criteria met: <promise>DONE</promise>

## Stuck Handling
[Framework-specific tips...]
```

### 11. Confirm with User

After generating:
- Show plan summary
- Ask: "Plan saved to `.claude/dev-plan.local.md`. Start with `/dev-loop --from-plan`?"

---

## Interactive Mode (--interactive)

When `--interactive` flag is present:

1. "What's the current state of this feature?" (understand starting point)
2. "Which specific components need to be created?" (scope)
3. "Are there existing patterns I should follow?" (consistency)
4. "What's the most important acceptance criterion?" (priority)
5. "Any known edge cases or risks?" (robustness)

---

## Anti-Patterns to Avoid

| Don't | Do Instead |
|-------|------------|
| "Implement the feature" | "Create `lib/auth/login.dart` with ConsumerWidget" |
| "If it fails, fix it" | "If tests pass in Red phase, tests aren't specific enough" |
| Missing code snippets | Show actual structure with types and patterns |
| No file tables | Always list files to modify/create |
| "App works" | "Login returns JWT, logout invalidates token" |

---

## References

- `references/plan-template.md` - Full template with variables
- `references/good-example.md` - High-quality example plan
- `references/framework-patterns.md` - Framework-specific patterns
