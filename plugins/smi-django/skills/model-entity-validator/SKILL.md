---
name: model-entity-validator
description: Automatically validate Django models have required fields (UUID primary key, timestamps, soft delete). Use when creating or modifying Django models, database schemas, or seeing model class definitions.
---

# Model/Entity Validator

Auto-enforces Smicolon's standard model pattern with required fields for ALL Django models.

## When This Skill Activates

I automatically run when:
- User creates new model files
- User modifies existing models
- User mentions "model", "database", "schema", "table"
- User writes class inheriting from `models.Model`
- User runs migrations
- User discusses data structure

## Required Model Fields (MANDATORY)

Every Django model MUST have these exact fields:

```python
import uuid
from django.db import models

class YourModel(models.Model):
    """Model description."""

    # 1. UUID Primary Key (REQUIRED)
    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False
    )

    # 2. Created Timestamp (REQUIRED)
    created_at = models.DateTimeField(auto_now_add=True)

    # 3. Updated Timestamp (REQUIRED)
    updated_at = models.DateTimeField(auto_now=True)

    # 4. Soft Delete Flag (REQUIRED)
    is_deleted = models.BooleanField(default=False)

    # ... your custom fields here

    class Meta:
        db_table = 'your_table_name'
        indexes = [
            models.Index(fields=['created_at']),
            models.Index(fields=['is_deleted']),
        ]
```

## Auto-Validation Process

### Step 1: Detect New/Modified Model

When I see a model class being written:

```python
class User(models.Model):
    email = models.EmailField(unique=True)
    # Missing required fields! ❌
```

### Step 2: Check for Required Fields

I verify presence of:
1. ✅ UUID primary key named `id`
2. ✅ `created_at` with `auto_now_add=True`
3. ✅ `updated_at` with `auto_now=True`
4. ✅ `is_deleted` with `default=False`

### Step 3: Auto-Add Missing Fields

**Before (Incomplete):**
```python
class User(models.Model):
    email = models.EmailField(unique=True)
    first_name = models.CharField(max_length=100)
```

**After (Complete):**
```python
import uuid
from django.db import models

class User(models.Model):
    """User model."""

    # Required fields (auto-added)
    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_deleted = models.BooleanField(default=False)

    # Custom fields
    email = models.EmailField(unique=True)
    first_name = models.CharField(max_length=100)

    class Meta:
        db_table = 'users'
        indexes = [
            models.Index(fields=['created_at']),
            models.Index(fields=['is_deleted']),
            models.Index(fields=['email']),  # Business index
        ]
```

### Step 4: Suggest Migration

After adding fields, I remind:

> **Model Fields Added**
>
> Added required Smicolon fields to `User` model:
> - UUID primary key (`id`)
> - Timestamps (`created_at`, `updated_at`)
> - Soft delete flag (`is_deleted`)
>
> **Next steps:**
> ```bash
> python manage.py makemigrations
> python manage.py migrate
> ```
>
> **Why these fields?**
> - UUID: Prevents ID enumeration attacks, works across distributed systems
> - Timestamps: Audit trail for all records
> - Soft delete: Preserve data instead of hard deletes

### Step 5: Validate Indexes

I check if appropriate indexes exist:

```python
class Meta:
    db_table = 'users'
    indexes = [
        models.Index(fields=['created_at']),    # For time-based queries
        models.Index(fields=['is_deleted']),    # For active records filter
        # Suggest indexes for commonly queried fields
    ]
```

## Pattern Templates

See supporting files for complete examples:
- `templates/django-base-model.py` - Complete model template
- `templates/field-snippets.json` - Individual field templates
- `checklists/django-model-checklist.md` - Required fields checklist
- `migration-guides/add-uuid-migration.md` - Safe migration patterns

## Complete Model Example

```python
import uuid
from django.db import models
from django.contrib.auth.models import AbstractUser


class User(AbstractUser):
    """User account model."""

    # Override default ID with UUID
    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False
    )

    # Required timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    # Required soft delete
    is_deleted = models.BooleanField(default=False)

    # Custom fields
    email = models.EmailField(unique=True)
    phone = models.CharField(max_length=20, blank=True)
    bio = models.TextField(blank=True)
    avatar = models.ImageField(upload_to='avatars/', null=True, blank=True)

    # Relationships
    organization = models.ForeignKey(
        'Organization',
        on_delete=models.CASCADE,
        related_name='users'
    )

    class Meta:
        db_table = 'users'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['created_at']),
            models.Index(fields=['is_deleted']),
            models.Index(fields=['email']),
            models.Index(fields=['organization', 'is_deleted']),
        ]

    def __str__(self):
        return self.email

    def soft_delete(self):
        """Soft delete the user instead of hard delete."""
        self.is_deleted = True
        self.save(update_fields=['is_deleted', 'updated_at'])
```

## Custom Managers for Soft Delete

I also suggest adding custom managers:

```python
class ActiveManager(models.Manager):
    """Manager that excludes soft-deleted records."""

    def get_queryset(self):
        return super().get_queryset().filter(is_deleted=False)


class User(models.Model):
    # ... fields ...

    objects = models.Manager()  # Default manager (includes deleted)
    active = ActiveManager()    # Active records only

# Usage
User.active.all()  # Only non-deleted users
User.objects.all()  # All users including deleted
```

## Edge Cases

### Existing Models with Integer IDs

If migrating existing model with integer IDs to UUID:

**I warn:**
> ⚠️ **Existing Model Detected**
>
> This model already has an integer primary key. Converting to UUID requires:
> 1. Data migration to generate UUIDs for existing records
> 2. Update all foreign keys
> 3. Potential application downtime
>
> See `migration-guides/migrate-int-to-uuid.md` for safe migration steps.

### Abstract Base Models

For abstract base classes, I still add these fields:

```python
class BaseModel(models.Model):
    """Abstract base model with required fields."""

    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_deleted = models.BooleanField(default=False)

    class Meta:
        abstract = True  # This model won't create a table

# Usage
class User(BaseModel):
    email = models.EmailField()
    # Inherits all required fields!
```

### Through Models (Many-to-Many)

Even through models get required fields:

```python
class UserOrganization(models.Model):
    """Through model for user-organization relationship."""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_deleted = models.BooleanField(default=False)

    user = models.ForeignKey(User, on_delete=models.CASCADE)
    organization = models.ForeignKey(Organization, on_delete=models.CASCADE)
    role = models.CharField(max_length=50)

    class Meta:
        db_table = 'user_organizations'
        unique_together = [['user', 'organization']]
```

## Validation Checklist

When I review a model, I check:

- ✅ UUID primary key with `uuid.uuid4` default
- ✅ `created_at` field with `auto_now_add=True`
- ✅ `updated_at` field with `auto_now=True`
- ✅ `is_deleted` field with `default=False`
- ✅ Appropriate `db_table` name (plural, snake_case)
- ✅ Indexes on `created_at` and `is_deleted`
- ✅ Indexes on frequently queried fields
- ✅ Foreign keys have `on_delete` specified
- ✅ Docstring explaining the model
- ✅ `__str__` method for admin display

## Integration with Other Skills

Works together with:
- **import-convention-enforcer**: Ensures `import uuid` is added
- **migration-safety-checker**: Validates migrations are safe
- **security-first-validator**: Checks for sensitive field exposure

## Success Criteria

✅ ALL models have UUID primary keys
✅ ALL models have timestamps
✅ ALL models have soft delete
✅ Appropriate indexes exist
✅ Migrations generated successfully
✅ Developer understands WHY each field exists

## Skill Behavior

**I am PROACTIVE:**
- I check models WITHOUT being asked
- I add missing fields AUTOMATICALLY
- I explain WHY each field is required
- I suggest appropriate indexes
- I warn about migration complexity

**I do NOT:**
- Require user to ask "validate model"
- Wait for code review
- Just warn - I ADD fields automatically

This ensures all models follow Smicolon standards from the moment they're created.
