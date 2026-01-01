# BaseModel Convention Fix Plan

**Date**: 2026-01-01
**Issue**: Repetitive timestamp/UUID fields instead of BaseModel inheritance

---

## Problem

Current pattern **repeats the same 4 fields** in every model example:

```python
# WRONG - Repetitive (shown in ~15 files)
class User(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_deleted = models.BooleanField(default=False)

    # ... actual fields
    email = models.EmailField(unique=True)

class Product(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)  # ❌ Duplicate!
    created_at = models.DateTimeField(auto_now_add=True)  # ❌ Duplicate!
    updated_at = models.DateTimeField(auto_now=True)  # ❌ Duplicate!
    is_deleted = models.BooleanField(default=False)  # ❌ Duplicate!

    name = models.CharField(max_length=255)
```

---

## Solution

Use a **BaseModel** abstract class that all models inherit from:

```python
# core/models.py (or shared/models.py)
import uuid
from django.db import models

class BaseModel(models.Model):
    """Abstract base model with UUID, timestamps, and soft delete."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_deleted = models.BooleanField(default=False)

    class Meta:
        abstract = True  # CRITICAL: This makes it abstract
        ordering = ['-created_at']

    def soft_delete(self):
        """Soft delete the record."""
        self.is_deleted = True
        self.save(update_fields=['is_deleted', 'updated_at'])
```

Then all models simply inherit:

```python
# users/models.py
import core.models as _core_models

class User(_core_models.BaseModel):
    """User model - inherits id, timestamps, soft delete from BaseModel."""

    email = models.EmailField(unique=True, db_index=True)
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)

    class Meta:
        db_table = 'users'
```

---

## Files to Update

### High Priority (Core Convention Definitions)

| File | Issue | Fix |
|------|-------|-----|
| `plugins/smi-django/agents/django-builder.md` | Lines 83-86 repeat fields | Show BaseModel inheritance |
| `plugins/smi-django/agents/django-architect.md` | Model examples repeat fields | Show BaseModel inheritance |
| `plugins/smi-django/agents/django-reviewer.md` | Lines 156-160 repeat fields | Show BaseModel check |
| `plugins/smi-django/agents/django-feature-based.md` | Lines 165-196 repeat fields | Show BaseModel in shared/ |
| `plugins/smi-django/skills/model-entity-validator/SKILL.md` | Multiple examples repeat | Add BaseModel detection |
| `plugins/smi-django/commands/model-create.md` | Lines 28-32, 101-103 repeat | Generate with BaseModel |
| `plugins/smi-django/rules/models.md` | Lines 26-30 repeat | Document BaseModel pattern |

### Files Count: ~7 files with ~15+ occurrences

---

## New Convention

### 1. BaseModel Location

**Traditional App-Based:**
```
project/
├── core/
│   ├── __init__.py
│   └── models.py        # BaseModel lives here
├── users/
│   └── models.py        # import core.models as _core_models
└── products/
    └── models.py        # import core.models as _core_models
```

**Feature-Based:**
```
project/
├── shared/
│   ├── __init__.py
│   └── models.py        # BaseModel lives here
├── features/
│   ├── users/
│   │   └── models.py    # import shared.models as _shared_models
│   └── products/
│       └── models.py    # import shared.models as _shared_models
```

### 2. BaseModel Definition

```python
# core/models.py or shared/models.py
import uuid
from django.db import models

class BaseModel(models.Model):
    """
    Abstract base model providing:
    - UUID primary key
    - Automatic timestamps (created_at, updated_at)
    - Soft delete support (is_deleted)

    All models MUST inherit from this class.
    """

    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_deleted = models.BooleanField(default=False)

    class Meta:
        abstract = True
        ordering = ['-created_at']

    def soft_delete(self) -> None:
        """Soft delete the record."""
        self.is_deleted = True
        self.save(update_fields=['is_deleted', 'updated_at'])

    def restore(self) -> None:
        """Restore a soft-deleted record."""
        self.is_deleted = False
        self.save(update_fields=['is_deleted', 'updated_at'])
```

### 3. Model Inheritance Pattern

```python
# users/models.py
from django.contrib.auth.models import AbstractUser
import core.models as _core_models

class User(AbstractUser, _core_models.BaseModel):
    """
    User model with email authentication.

    Inherits from BaseModel:
    - id (UUID)
    - created_at, updated_at
    - is_deleted, soft_delete(), restore()
    """

    email = models.EmailField(unique=True, db_index=True)

    # Override AbstractUser's id if needed
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []

    class Meta:
        db_table = 'users'
        indexes = [
            models.Index(fields=['email']),
            models.Index(fields=['created_at']),
        ]
```

### 4. Multitenancy Extension (Future-Ready)

```python
# core/models.py
import uuid
from django.db import models

class BaseModel(models.Model):
    """Abstract base without tenant."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_deleted = models.BooleanField(default=False)

    class Meta:
        abstract = True


class TenantBaseModel(BaseModel):
    """
    Abstract base with tenant support.
    Use for models that belong to a tenant.
    """
    tenant = models.ForeignKey(
        'tenants.Tenant',
        on_delete=models.CASCADE,
        related_name='%(class)s_set'
    )

    class Meta:
        abstract = True


# Usage:
class User(BaseModel):  # No tenant (users exist across tenants)
    pass

class Product(TenantBaseModel):  # Belongs to a tenant
    name = models.CharField(max_length=255)
```

---

## Skill Update: model-entity-validator

The skill should be updated to:

1. **Check if BaseModel exists** before adding fields
2. **Suggest inheritance** instead of field duplication
3. **Detect duplicate fields** that should come from BaseModel

```markdown
## Auto-Validation Process

### Step 1: Check for BaseModel

Before suggesting fields, check if project has BaseModel:

```python
# Look for in order:
# 1. core/models.py with BaseModel
# 2. shared/models.py with BaseModel
# 3. common/models.py with BaseModel
```

### Step 2: If BaseModel exists, suggest inheritance

If BaseModel found:
```python
# ❌ WRONG - Don't add these fields
class Product(models.Model):
    id = models.UUIDField(...)
    created_at = models.DateTimeField(...)

# ✅ CORRECT - Inherit from BaseModel
import core.models as _core_models

class Product(_core_models.BaseModel):
    name = models.CharField(max_length=255)
```

### Step 3: If BaseModel doesn't exist, create it first

If no BaseModel found:
```
⚠️ No BaseModel found in project.

Creating core/models.py with BaseModel...
[Shows BaseModel code]

Now inherit from BaseModel in your models.
```
```

---

## Execution Steps

### Phase 1: Update Core Documentation

1. **Update `rules/models.md`** - Make BaseModel the primary pattern
2. **Update `model-entity-validator/SKILL.md`** - Add BaseModel detection

### Phase 2: Update Agent Files

3. **Update `django-builder.md`** - Show BaseModel inheritance examples
4. **Update `django-architect.md`** - Recommend BaseModel in architecture
5. **Update `django-reviewer.md`** - Check for BaseModel compliance
6. **Update `django-feature-based.md`** - Show shared/models.py pattern

### Phase 3: Update Commands

7. **Update `model-create.md`** - Generate models inheriting from BaseModel

### Phase 4: Validate

8. Run tests to ensure consistency

---

## Summary

| Metric | Current | After |
|--------|---------|-------|
| Lines of code per model | 8-10 (with fields) | 2-3 (inheritance only) |
| Field duplication | 15+ occurrences | 0 |
| Consistency | Varies | Always BaseModel |
| Multitenancy ready | No | Yes (TenantBaseModel) |

**Benefits:**
- ✅ DRY - Define once, inherit everywhere
- ✅ Consistency - All models have same base fields
- ✅ Maintainability - Change once, applies everywhere
- ✅ Multitenancy ready - Easy to add TenantBaseModel
- ✅ Less cognitive load - "Just inherit from BaseModel"

---

## Status: ✅ COMPLETED

**Completed**: 2026-01-01

### Actions Taken

1. ✅ Updated `plugins/smi-django/rules/models.md` - Complete rewrite focusing on BaseModel inheritance
2. ✅ Updated `plugins/smi-django/skills/model-entity-validator/SKILL.md` - Now checks for BaseModel first
3. ✅ Updated `plugins/smi-django/agents/django-builder.md` - Shows BaseModel pattern, not repetitive fields
4. ✅ Updated `plugins/smi-django/agents/django-architect.md` - Recommends BaseModel inheritance
5. ✅ Updated `plugins/smi-django/agents/django-reviewer.md` - Checks for BaseModel compliance
6. ✅ Updated `plugins/smi-django/agents/django-feature-based.md` - Shows shared/models.py pattern
7. ✅ Updated `plugins/smi-django/commands/model-create.md` - Generates models with BaseModel inheritance

### New Pattern

```python
# Old (WRONG - repeating fields)
class Product(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_deleted = models.BooleanField(default=False)
    name = models.CharField(max_length=255)

# New (CORRECT - inherit from BaseModel)
import core.models as _core_models

class Product(_core_models.BaseModel):
    """Inherits id, timestamps, soft delete from BaseModel."""
    name = models.CharField(max_length=255)
```
