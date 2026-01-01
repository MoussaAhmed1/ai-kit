# Phase 4: Complete Hook Implementation

**Goal**: Automatic convention enforcement via event-based hooks

---

## Available Hook Events (Claude Code v2.0.38+)

| Event | Trigger | Use Case |
|-------|---------|----------|
| `UserPromptSubmit` | Before prompt processed | Inject conventions |
| `PreToolUse` | Before tool runs | Validate inputs |
| `PostToolUse` | After tool runs | Validate outputs |
| `Stop` | Conversation ends | TDD loops (Phase 1) |
| `SubagentStop` | Subagent completes | Continue workflows |
| `PermissionRequest` | Permission needed | Auto-approve safe tools |
| `SessionStart` | New session | Load project context |
| `PreCompact` | Before compaction | Preserve critical data |

---

## Tasks

### 4.1 Create Complete hooks.json

**File**: `plugins/smi-django/hooks/hooks.json`

```json
{
  "hooks": [
    {
      "event": "UserPromptSubmit",
      "type": "prompt",
      "prompt": "${CLAUDE_PLUGIN_ROOT}/hooks/inject-conventions.md",
      "timeout": 5000
    },
    {
      "event": "PreToolUse",
      "type": "prompt",
      "prompt": "${CLAUDE_PLUGIN_ROOT}/hooks/validate-tool-input.md",
      "matcher": {
        "tool": "Write|Edit"
      },
      "timeout": 10000
    },
    {
      "event": "PostToolUse",
      "type": "prompt",
      "prompt": "${CLAUDE_PLUGIN_ROOT}/hooks/validate-tool-output.md",
      "matcher": {
        "tool": "Write|Edit"
      },
      "timeout": 15000
    },
    {
      "event": "Stop",
      "type": "prompt",
      "prompt": "${CLAUDE_PLUGIN_ROOT}/hooks/tdd-loop-controller.md",
      "timeout": 30000
    },
    {
      "event": "PermissionRequest",
      "type": "prompt",
      "prompt": "${CLAUDE_PLUGIN_ROOT}/hooks/permission-handler.md",
      "timeout": 5000
    },
    {
      "event": "SessionStart",
      "type": "prompt",
      "prompt": "${CLAUDE_PLUGIN_ROOT}/hooks/session-init.md",
      "timeout": 10000
    }
  ]
}
```

### 4.2 UserPromptSubmit Hook

**File**: `plugins/smi-django/hooks/inject-conventions.md`

```markdown
---
name: Django Convention Injector
description: Injects Django conventions before processing user prompts
---

# Django Convention Injection

## Project Detection

First, detect if this is a Django project:

```bash
# Check for Django markers
if [ -f "manage.py" ] || [ -d "config/settings" ]; then
    DJANGO_PROJECT=true
fi
```

If not Django project, skip injection.

## Injected Context

When Django detected, prepend to prompt:

```
[DJANGO CONVENTIONS ACTIVE]

IMPORT PATTERN (MANDATORY):
- Use: import app.models as _models
- Never: from .models import X
- Never: from app.models import X

MODEL REQUIREMENTS:
- UUID primary key
- created_at, updated_at timestamps
- is_deleted soft delete field

VIEW REQUIREMENTS:
- permission_classes on ALL views
- throttle_classes for rate limiting
- Use serializer for validation

SERVICE LAYER:
- Business logic in services, not views
- @transaction.atomic for DB operations
- Type hints required

TESTING:
- 90%+ coverage target
- pytest, not unittest
- Factory pattern for test data

[END CONVENTIONS]
```

## Conditional Injection

Only inject when relevant:

| Prompt Contains | Inject |
|-----------------|--------|
| "model", "models.py" | Model requirements |
| "view", "viewset", "api" | View requirements |
| "service" | Service layer patterns |
| "test" | Testing requirements |
| "import" | Import pattern |

## Output

Return modified prompt with conventions prepended.
Preserve original user intent.
```

### 4.3 PreToolUse Hook

**File**: `plugins/smi-django/hooks/validate-tool-input.md`

```markdown
---
name: Pre-Write Validator
description: Validate Write/Edit inputs before execution
---

# Pre-Write Validation

## Trigger

When Write or Edit tool is about to run.

## Validation Checks

### Check 1: File Type Detection

```
file_path = tool_input.file_path

if file_path ends with ".py":
    python_file = true
    apply_python_validations()
elif file_path ends with ".ts" or ".tsx":
    typescript_file = true
    apply_typescript_validations()
```

### Check 2: Import Pattern Validation

For Python files:

```python
content = tool_input.content

# Check for forbidden imports
forbidden_patterns = [
    r'from \. import',           # Relative import
    r'from \.\. import',         # Parent relative import
    r'from \w+\.models import',  # Direct model import
]

for pattern in forbidden_patterns:
    if re.search(pattern, content):
        BLOCK with message:
        "Invalid import pattern detected. Use: import app.module as _module"
```

### Check 3: Model Field Validation

For model files (**/models.py, **/models/*.py):

```python
if 'class' in content and 'models.Model' in content:
    # Check for required fields
    required = [
        'UUIDField(primary_key=True',
        'created_at',
        'updated_at',
        'is_deleted',
    ]

    missing = [r for r in required if r not in content]
    if missing:
        WARN: f"Missing required model fields: {missing}"
```

### Check 4: View Security Validation

For view files (**/views.py, **/viewsets.py):

```python
if 'ViewSet' in content or 'APIView' in content:
    if 'permission_classes' not in content:
        BLOCK: "View missing permission_classes. Security requirement."
```

## Actions

### ALLOW
Validation passed. Proceed with tool.

### WARN
Issue detected but not critical. Show warning, proceed.

```
⚠️ WARNING: Model missing is_deleted field
Soft deletes are recommended for data recovery.
Proceeding anyway...
```

### BLOCK
Critical issue. Block tool execution.

```
❌ BLOCKED: Security violation
View missing permission_classes.
All API endpoints must have permission controls.

Fix: Add permission_classes = [IsAuthenticated]
```

## Output Format

```json
{
  "action": "allow|warn|block",
  "message": "Description if warn/block",
  "suggestion": "How to fix if blocked"
}
```
```

### 4.4 PostToolUse Hook

**File**: `plugins/smi-django/hooks/validate-tool-output.md`

```markdown
---
name: Post-Write Validator
description: Validate files after Write/Edit completes
---

# Post-Write Validation

## Trigger

After Write or Edit tool completes successfully.

## Validation Process

### Step 1: Read Written Content

```
file_path = tool_result.file_path
content = read_file(file_path)
```

### Step 2: Run Validations

#### Python Syntax Check

```bash
python -m py_compile $file_path
```

If fails:
```
❌ SYNTAX ERROR in {file_path}

{error_message}

Attempting auto-fix...
```

#### Import Organization

Check imports follow pattern:
1. Standard library
2. Third-party packages
3. Local application imports (as aliases)

#### Type Hint Coverage

For function definitions:

```python
def create_user(data: dict) -> User:  # ✅ Good
def create_user(data):                 # ⚠️ Missing hints
```

### Step 3: Auto-Fix Capability

When fixable issues detected:

```
═══════════════════════════════════════════
POST-WRITE VALIDATION
═══════════════════════════════════════════

File: users/services.py

Issues Found:
1. ⚠️ Import 'from .models import User' should be 'import users.models as _models'
2. ⚠️ Missing type hints on 'get_user' function

Auto-Fix Available:
These issues can be automatically fixed.

Options:
1. Apply auto-fix
2. Show suggested changes
3. Skip (leave as-is)
```

### Step 4: Test File Validation

For test files:

```python
# Check test validity
if file_path matches "**/test*.py":
    run_test_validity_checker(content)

    if has_empty_tests:
        WARN: "Empty tests detected"
    if has_trivial_assertions:
        WARN: "Trivial assertions (assert True)"
    if assertion_count < 2:
        WARN: "Low assertion count"
```

## Output

After validation:

```
✅ POST-WRITE VALIDATION PASSED

File: users/services.py
- Syntax: Valid
- Imports: Correct pattern
- Type hints: 100% coverage
- Security: No issues

Ready to proceed.
```

Or with issues:

```
⚠️ POST-WRITE VALIDATION: 2 WARNINGS

File: users/views.py
- Syntax: Valid
- Imports: ⚠️ 1 relative import found
- Security: ⚠️ ViewSet missing throttle_classes

Suggestions provided. Fix recommended before commit.
```
```

### 4.5 Permission Handler Hook

**File**: `plugins/smi-django/hooks/permission-handler.md`

```markdown
---
name: Permission Auto-Handler
description: Automatically approve or deny tool permissions
---

# Permission Handler

## Purpose

Reduce permission prompts for safe, repetitive operations.

## Auto-Approve Rules

### Safe Read Operations

```
if tool in ['Read', 'Glob', 'Grep']:
    if path within project_directory:
        AUTO_APPROVE
```

### Safe Bash Commands

```
safe_commands = [
    'pytest',
    'python -m pytest',
    'python manage.py test',
    'python manage.py makemigrations --dry-run',
    'python manage.py check',
    'coverage run',
    'coverage report',
    'mypy',
    'ruff check',
    'black --check',
]

if command starts_with any(safe_commands):
    AUTO_APPROVE
```

### Write Within Project

```
if tool in ['Write', 'Edit']:
    if path within project_directory:
        if path not in ['.env', 'credentials', 'secrets']:
            AUTO_APPROVE
```

## Auto-Deny Rules

### Dangerous Commands

```
dangerous_patterns = [
    'rm -rf',
    'sudo',
    'chmod 777',
    ':(){:|:&};:',  # Fork bomb
    '> /dev/sda',
    'mkfs',
]

if command contains any(dangerous_patterns):
    AUTO_DENY with message:
    "Dangerous command blocked: {pattern}"
```

### Outside Project

```
if path not within project_directory:
    if path in ['/etc', '/usr', '/bin', '/root']:
        AUTO_DENY: "System path modification blocked"
```

## Ask User

When not auto-approve or auto-deny:

```
PROMPT_USER:
"Permission needed for: {tool} on {path}"
```

## Output Format

```json
{
  "decision": "approve|deny|ask",
  "reason": "Explanation",
  "tool": "Tool name",
  "path": "Affected path if applicable"
}
```
```

### 4.6 Session Start Hook

**File**: `plugins/smi-django/hooks/session-init.md`

```markdown
---
name: Session Initializer
description: Set up context at session start
---

# Session Initialization

## Trigger

When new Claude Code session starts.

## Actions

### 1. Detect Project Type

```bash
# Django
if [ -f "manage.py" ]; then
    PROJECT_TYPE="django"
fi

# NestJS
if [ -f "package.json" ] && grep -q "@nestjs/core" package.json; then
    PROJECT_TYPE="nestjs"
fi

# Next.js
if [ -f "package.json" ] && grep -q '"next"' package.json; then
    PROJECT_TYPE="nextjs"
fi
```

### 2. Load Project Context

```
Read and summarize:
- README.md (project overview)
- pyproject.toml or package.json (dependencies)
- Structure of src/ or app/ directory
```

### 3. Set Session Variables

```
SESSION_CONTEXT:
  project_type: django
  python_version: 3.13
  framework_version: Django 5.0
  testing_framework: pytest
  coverage_target: 90%
```

### 4. Show Welcome

```
═══════════════════════════════════════════
SMICOLON DJANGO PLUGIN ACTIVE
═══════════════════════════════════════════

Project: {project_name}
Type: Django {version}

Active Conventions:
- Import pattern: import app.module as _module
- Model fields: UUID, timestamps, soft delete
- Security: Permissions required on all views
- Testing: 90%+ coverage target

Active Skills:
- import-convention-enforcer
- model-entity-validator
- security-first-validator
- performance-optimizer
- test-coverage-advisor
- migration-safety-checker

Commands:
- /model-create - Create Django model
- /api-endpoint - Create REST endpoint
- /test-generate - Generate tests
- /tdd-loop - TDD development loop

Ready to assist!
═══════════════════════════════════════════
```

## Output

Session initialized with project context loaded.
```

---

## Implementation Order

1. Create hooks directory structure
2. Create hooks.json with all hook definitions
3. Implement each hook file
4. Test hooks individually
5. Test hooks together
6. Update marketplace.json

---

## Success Criteria

- [ ] All hook events implemented
- [ ] UserPromptSubmit injects conventions
- [ ] PreToolUse validates before write
- [ ] PostToolUse validates after write
- [ ] PermissionRequest auto-handles safe ops
- [ ] SessionStart shows welcome context
- [ ] Hooks work together without conflicts

---

## Files to Create

### Django Plugin
1. `plugins/smi-django/hooks/hooks.json`
2. `plugins/smi-django/hooks/inject-conventions.md`
3. `plugins/smi-django/hooks/validate-tool-input.md`
4. `plugins/smi-django/hooks/validate-tool-output.md`
5. `plugins/smi-django/hooks/permission-handler.md`
6. `plugins/smi-django/hooks/session-init.md`
7. `plugins/smi-django/hooks/tdd-loop-controller.md` (from Phase 1)

### Replicate for Other Plugins
Adapt conventions for NestJS, Next.js, Nuxt.js
