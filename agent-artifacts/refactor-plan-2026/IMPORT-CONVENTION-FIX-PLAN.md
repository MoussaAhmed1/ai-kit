# Django Import Convention Fix Plan

**Date**: 2026-01-01
**Issue**: Namespace conflicts with current import alias pattern

---

## Problem

Current pattern creates **namespace conflicts** when importing from multiple apps:

```python
# WRONG - Current pattern causes conflicts
import users.models as _models
import products.models as _models  # ❌ CONFLICT! Overwrites previous import
import orders.models as _models    # ❌ CONFLICT! Overwrites again

# Usage becomes ambiguous
user = _models.User.objects.get(id=user_id)  # Which _models?
```

---

## Solution

Use **app-prefixed aliases** to ensure unique namespaces:

```python
# CORRECT - Unique namespace per app
import users.models as _users_models
import products.models as _products_models
import orders.models as _orders_models

# Usage is clear and unambiguous
user = _users_models.User.objects.get(id=user_id)
product = _products_models.Product.objects.get(id=product_id)
order = _orders_models.Order.objects.get(id=order_id)
```

### Pattern Rule

```
import {app}.{module} as _{app}_{module}
```

| Import | Alias |
|--------|-------|
| `import users.models` | `as _users_models` |
| `import users.services` | `as _users_services` |
| `import users.serializers` | `as _users_serializers` |
| `import products.models` | `as _products_models` |
| `import core.utils` | `as _core_utils` |
| `import shared.utils` | `as _shared_utils` |

---

## Files to Update

### High Priority (Core Convention Definitions)

| File | Line(s) | Current | Fix To |
|------|---------|---------|--------|
| `plugins/smi-django/skills/import-convention-enforcer/SKILL.md` | 24-27, 85-86, 100, 117-118, 164-165, 210 | `as _models`, `as _services` | `as _users_models`, `as _users_services` |
| `plugins/smi-django/skills/import-convention-enforcer/patterns/django-imports.md` | 16-20, 26, 84-85, 101-104, 147-149, etc. | `as _models` | `as _users_models` |
| `plugins/smi-django/agents/django-builder.md` | 32-35, 50, 98, 124, 140-142, 214 | `as _models`, `as _services` | `as _users_models`, `as _users_services` |
| `plugins/smi-django/agents/django-architect.md` | 38-40, 74-75, 165-166, 169, 176 | `as _models`, `as _services` | `as _users_models`, `as _users_services` |
| `plugins/smi-django/agents/django-tester.md` | 41, 61, 121 | `as _models`, `as _services` | `as _users_models`, `as _users_services` |
| `plugins/smi-django/agents/django-reviewer.md` | 147 | `as _models` | `as _users_models` |
| `plugins/smi-django/agents/django-feature-based.md` | 104 | `as _utils` | `as _shared_utils` |

### Medium Priority (Commands & Rules)

| File | Line(s) | Current | Fix To |
|------|---------|---------|--------|
| `plugins/smi-django/commands/model-create.md` | 47-48 | `as _models`, `as _utils` | `as _users_models`, `as _core_utils` |
| `plugins/smi-django/commands/api-endpoint.md` | 17-19, 73, 114, 159-161, 210, 223 | `as _models`, `as _serializers` | `as _users_models`, `as _users_serializers` |
| `plugins/smi-django/commands/test-generate.md` | 15-17, 34, 90-91, 160, 249 | `as _models`, `as _services` | `as _users_models`, `as _users_services` |
| `plugins/smi-django/rules/serializers.md` | 12, 40 | `as _models` | `as _users_models` |
| `plugins/smi-django/rules/services.md` | 16, 52 | `as _models` | `as _users_models` |
| `plugins/smi-django/rules/tests.md` | 16-17, 48, 108 | `as _models`, `as _services` | `as _users_models`, `as _users_services` |

### Lower Priority (Skills, Documentation)

| File | Line(s) | Current | Fix To |
|------|---------|---------|--------|
| `plugins/smi-django/skills/test-coverage-advisor/SKILL.md` | 69, 114-115, 156, 303, 337 | `as _models`, `as _services` | `as _users_models`, `as _users_services` |
| `plugins/smi-django/skills/security-first-validator/SKILL.md` | 174-175 | `as _models`, `as _serializers` | `as _users_models`, `as _users_serializers` |
| `plugins/smi-django/README.md` | 53-54 | `as _models`, `as _services` | `as _users_models`, `as _users_services` |

### Root Level Documentation

| File | Line(s) | Current | Fix To |
|------|---------|---------|--------|
| `README.md` | 360-361 | `as _models`, `as _services` | `as _users_models`, `as _users_services` |
| `SKILLS.md` | 38, 531 | `as _models` | `as _users_models` |
| `.claude/CLAUDE.md` | 214-215 | `as _models`, `as _services` | `as _users_models`, `as _users_services` |
| `workflows/code-review.md` | 31, 311 | `as _models` | `as _users_models` |

### Already Correct (No Changes Needed)

These files already use the correct pattern in some places:
- `plugins/smi-django/skills/import-convention-enforcer/SKILL.md:186-187` ✅
- `plugins/smi-django/agents/django-builder.md:34` ✅ (`as _product_models`)
- `plugins/smi-django/rules/views.md:28-30` ✅
- `agent-artifacts/refactor-plan-2026/02-PHASE-PATH-RULES.md:152-154` ✅

---

## Execution Order

### Phase 1: Core Convention Files (Must update first)
1. `plugins/smi-django/skills/import-convention-enforcer/SKILL.md`
2. `plugins/smi-django/skills/import-convention-enforcer/patterns/django-imports.md`

### Phase 2: Agent Definitions
3. `plugins/smi-django/agents/django-builder.md`
4. `plugins/smi-django/agents/django-architect.md`
5. `plugins/smi-django/agents/django-tester.md`
6. `plugins/smi-django/agents/django-reviewer.md`
7. `plugins/smi-django/agents/django-feature-based.md`

### Phase 3: Commands & Rules
8. `plugins/smi-django/commands/model-create.md`
9. `plugins/smi-django/commands/api-endpoint.md`
10. `plugins/smi-django/commands/test-generate.md`
11. `plugins/smi-django/rules/serializers.md`
12. `plugins/smi-django/rules/services.md`
13. `plugins/smi-django/rules/tests.md`

### Phase 4: Other Skills
14. `plugins/smi-django/skills/test-coverage-advisor/SKILL.md`
15. `plugins/smi-django/skills/security-first-validator/SKILL.md`

### Phase 5: Documentation
16. `plugins/smi-django/README.md`
17. `README.md` (root)
18. `SKILLS.md`
19. `.claude/CLAUDE.md`
20. `workflows/code-review.md`

---

## Search & Replace Patterns

For each file, apply these replacements (context-aware):

| Find | Replace |
|------|---------|
| `import users.models as _models` | `import users.models as _users_models` |
| `import users.services as _services` | `import users.services as _users_services` |
| `import users.serializers as _serializers` | `import users.serializers as _users_serializers` |
| `import users.views as _views` | `import users.views as _users_views` |
| `import users.utils as _utils` | `import users.utils as _users_utils` |
| `import core.utils as _utils` | `import core.utils as _core_utils` |
| `import core.permissions as _permissions` | `import core.permissions as _core_permissions` |
| `import shared.utils as _utils` | `import shared.utils as _shared_utils` |
| `import orders.models as _models` | `import orders.models as _orders_models` |
| `_models.User` | `_users_models.User` |
| `_models.Profile` | `_users_models.Profile` |
| `_services.UserService` | `_users_services.UserService` |
| `_serializers.UserSerializer` | `_users_serializers.UserSerializer` |
| `_utils.` (when from core) | `_core_utils.` |
| `_utils.` (when from shared) | `_shared_utils.` |

### Generic Pattern Descriptions

Also update pattern descriptions:
| Find | Replace |
|------|---------|
| `import app.module as _module` | `import app.module as _app_module` |
| `import app.models as _models` | `import app.models as _app_models` |

---

## Validation

After updates, verify:

1. **No conflicting aliases** - Search for duplicate `as _models`, `as _services` in same file
2. **Consistent usage** - Alias name matches import (e.g., `_users_models` used with `users.models`)
3. **All examples updated** - Both import statement AND usage updated together

---

## Summary

| Metric | Count |
|--------|-------|
| Files to update | ~20 |
| Import patterns to fix | ~100+ |
| Usage patterns to fix | ~50+ |

**Result**: Clear, unambiguous imports that work across multi-app Django projects.

---

## Status: ✅ COMPLETED

**Completed**: 2026-01-01

### Actions Taken

1. ✅ Updated `plugins/smi-django/skills/import-convention-enforcer/SKILL.md`
2. ✅ Updated `plugins/smi-django/skills/import-convention-enforcer/patterns/django-imports.md`
3. ✅ Updated all 5 Django agent files
4. ✅ Updated all 3 command files
5. ✅ Updated all 3 rule files (serializers, services, tests - views already correct)
6. ✅ Updated other skill files (test-coverage-advisor, security-first-validator)
7. ✅ Updated documentation (README.md, SKILLS.md, CLAUDE.md, workflows)
8. ✅ All tests passing

### New Pattern

```python
# Old (WRONG - causes namespace conflicts)
import users.models as _models
import products.models as _models  # ❌ CONFLICT!

# New (CORRECT - unique namespaces)
import users.models as _users_models
import products.models as _products_models  # ✅ Clear
```
