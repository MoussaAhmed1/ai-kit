---
paths:
  - "**/models.py"
  - "**/models/*.py"
---

# Django Model Standards

## BaseModel Pattern (MANDATORY)

All models MUST inherit from `BaseModel`. Never repeat UUID/timestamp fields.

### Step 1: Ensure BaseModel Exists

Check for BaseModel in your project (usually in `core/models.py` or `shared/models.py`):

```python
# core/models.py
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

### Step 2: Inherit from BaseModel

```python
# users/models.py
from django.db import models
import core.models as _core_models

class User(_core_models.BaseModel):
    """User model - inherits id, timestamps, soft delete from BaseModel."""

    email = models.EmailField(unique=True, db_index=True)
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)

    class Meta:
        db_table = 'users'
        verbose_name = 'User'
        verbose_name_plural = 'Users'
```

## Wrong vs Right

```python
# ❌ WRONG - Repeating fields that should come from BaseModel
class Product(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_deleted = models.BooleanField(default=False)
    name = models.CharField(max_length=255)

# ✅ CORRECT - Inherit from BaseModel
import core.models as _core_models

class Product(_core_models.BaseModel):
    """Product model."""
    name = models.CharField(max_length=255)
    price = models.DecimalField(max_digits=10, decimal_places=2)

    class Meta:
        db_table = 'products'
```

## Import Pattern

```python
# ✅ CORRECT - Absolute import with alias
import core.models as _core_models

class MyModel(_core_models.BaseModel):
    pass

# ❌ WRONG - Relative import
from .base import BaseModel
```

## Custom Managers

For soft delete support:

```python
class ActiveManager(models.Manager):
    def get_queryset(self):
        return super().get_queryset().filter(is_deleted=False)

class Product(_core_models.BaseModel):
    name = models.CharField(max_length=255)

    objects = ActiveManager()  # Default: excludes deleted
    all_objects = models.Manager()  # Include deleted
```

## Field Naming Conventions

- Use snake_case for all field names
- Boolean fields: `is_*` or `has_*` prefix
- DateTime fields: `*_at` suffix
- Foreign keys: descriptive name (not `{model}_id`)

```python
# ✅ CORRECT
is_active = models.BooleanField()
published_at = models.DateTimeField()
author = models.ForeignKey(User, on_delete=models.CASCADE)

# ❌ WRONG
active = models.BooleanField()  # No prefix
publishedAt = models.DateTimeField()  # camelCase
```

## Meta Options

Always define:

```python
class Meta:
    db_table = 'products'  # Explicit table name
    ordering = ['-created_at']  # Default ordering
    verbose_name = 'Product'
    verbose_name_plural = 'Products'
    indexes = [
        models.Index(fields=['name']),
    ]
```

## Forbidden Patterns

- `models.AutoField` - BaseModel uses UUID
- `id = models.UUIDField(...)` in non-base models - Inherit from BaseModel
- `created_at = ...` in non-base models - Inherit from BaseModel
- Hard deletes - Use `soft_delete()` method
- Business logic in models - Use service layer
