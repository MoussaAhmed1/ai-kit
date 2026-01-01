# Phase 2: Path-Specific Rules Implementation

**Goal**: Leverage Claude Code v2.0.64+ native path-specific rules

---

## Background

From [paddo.dev/claude-rules-path-specific-native](https://paddo.dev/blog/claude-rules-path-specific-native/):

> Claude Code 2.0.64 introduced native path-specific rules through a `.claude/rules/` directory structure. Unlike global rules, path-specific rules only activate when working with matching files.

### Format

```markdown
---
paths: src/api/**/*.ts
---

# API Development Rules
- All endpoints must include input validation
```

---

## Tasks

### 2.1 Create Rules Directory Structure

```bash
# Django plugin
mkdir -p plugins/smi-django/rules

# NestJS plugin
mkdir -p plugins/smi-nestjs/rules

# Next.js plugin
mkdir -p plugins/smi-nextjs/rules

# Nuxt.js plugin
mkdir -p plugins/smi-nuxtjs/rules
```

### 2.2 Django Path-Specific Rules

#### 2.2.1 Models Rule

**File**: `plugins/smi-django/rules/models.md`

```markdown
---
paths:
  - "**/models.py"
  - "**/models/*.py"
---

# Django Model Standards

## Required Fields (MANDATORY)

Every Django model MUST have:

```python
import uuid
from django.db import models

class YourModel(models.Model):
    # PRIMARY KEY - UUID, not auto-increment
    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False
    )

    # TIMESTAMPS - For audit trail
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    # SOFT DELETE - Never hard delete
    is_deleted = models.BooleanField(default=False)

    class Meta:
        abstract = False  # Set to True only for base models
```

## Import Pattern

```python
# CORRECT
import uuid
from django.db import models
from django.contrib.auth import get_user_model

# WRONG - Never use relative imports
from .base import BaseModel
```

## Forbidden Patterns

- `models.AutoField` - Use UUID instead
- `models.IntegerField(primary_key=True)` - Use UUID
- Hard deletes in manager methods
- Business logic in models (use services)

## Meta Options

Required:
- `ordering` - Define default ordering
- `verbose_name` - Human-readable name
- `verbose_name_plural` - Plural form

```python
class Meta:
    ordering = ['-created_at']
    verbose_name = 'Product'
    verbose_name_plural = 'Products'
```
```

#### 2.2.2 Views Rule

**File**: `plugins/smi-django/rules/views.md`

```markdown
---
paths:
  - "**/views.py"
  - "**/views/*.py"
  - "**/viewsets.py"
---

# Django View Standards

## Required Security

EVERY view/viewset MUST have:

```python
from rest_framework.permissions import IsAuthenticated
from rest_framework.throttling import UserRateThrottle

class YourViewSet(viewsets.ModelViewSet):
    # REQUIRED - No exceptions
    permission_classes = [IsAuthenticated]
    throttle_classes = [UserRateThrottle]
```

## Import Pattern

```python
# CORRECT - Modular imports
import users.models as _users_models
import users.services as _users_services
import users.serializers as _users_serializers

# Usage
queryset = _users_models.User.objects.filter(is_deleted=False)
serializer_class = _users_serializers.UserSerializer
```

## View Structure

```python
class UserViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated]
    throttle_classes = [UserRateThrottle]

    # Use service layer - no raw ORM in views
    def create(self, request):
        data = _users_serializers.CreateUserSerializer(data=request.data)
        data.is_valid(raise_exception=True)
        user = _users_services.UserService.create(data.validated_data)
        return Response(_users_serializers.UserSerializer(user).data)
```

## Forbidden

- Views without permission_classes
- Direct `request.data` access without serializer
- ORM queries in view methods (use services)
- `@api_view` without `@permission_classes`
```

#### 2.2.3 Services Rule

**File**: `plugins/smi-django/rules/services.md`

```markdown
---
paths:
  - "**/services.py"
  - "**/services/*.py"
---

# Django Service Layer Standards

## Purpose

Services contain business logic. Views delegate to services.

## Structure

```python
import users.models as _models
from django.db import transaction

class UserService:
    """
    Business logic for User operations.
    All methods are static or class methods.
    """

    @staticmethod
    @transaction.atomic
    def create_user(data: dict) -> _models.User:
        """
        Create a new user with validation.

        Args:
            data: Validated user data from serializer

        Returns:
            Created User instance

        Raises:
            ValidationError: If email already exists
        """
        # Business logic here
        user = _models.User.objects.create(**data)
        # Side effects (emails, notifications)
        return user
```

## Requirements

- All database operations use `@transaction.atomic`
- Methods have type hints
- Docstrings explain purpose, args, returns, raises
- Static methods preferred (no instance state)
- Import pattern: `import app.models as _models`

## Forbidden

- Service methods calling views
- Circular service dependencies
- HTTP-specific code (request, response)
- Direct print statements (use logging)
```

#### 2.2.4 Serializers Rule

**File**: `plugins/smi-django/rules/serializers.md`

```markdown
---
paths:
  - "**/serializers.py"
  - "**/serializers/*.py"
---

# Django Serializer Standards

## Structure

```python
import users.models as _models
from rest_framework import serializers

class UserSerializer(serializers.ModelSerializer):
    """Read serializer for User."""

    class Meta:
        model = _models.User
        fields = ['id', 'email', 'first_name', 'last_name', 'created_at']
        read_only_fields = ['id', 'created_at']


class CreateUserSerializer(serializers.Serializer):
    """Write serializer for creating User."""

    email = serializers.EmailField()
    password = serializers.CharField(write_only=True, min_length=8)
    first_name = serializers.CharField(max_length=100)

    def validate_email(self, value):
        if _models.User.objects.filter(email=value).exists():
            raise serializers.ValidationError("Email already exists")
        return value.lower()
```

## Rules

- Separate read/write serializers when needed
- All validation in serializer, not view
- Use `validate_<field>` for field-level
- Use `validate` for cross-field
- Never expose sensitive fields (password, tokens)

## Import Pattern

```python
import users.models as _models
from rest_framework import serializers
```
```

#### 2.2.5 Tests Rule

**File**: `plugins/smi-django/rules/tests.md`

```markdown
---
paths:
  - "**/test*.py"
  - "**/tests/**/*.py"
  - "**/*_test.py"
---

# Django Test Standards

## Coverage Target: 90%+

## Structure

```python
import pytest
import users.models as _models
import users.services as _services
from rest_framework.test import APIClient
from rest_framework import status

@pytest.mark.django_db
class TestUserService:
    """Tests for UserService."""

    def test_create_user_success(self):
        """Test successful user creation."""
        data = {'email': 'test@example.com', 'password': 'secure123'}

        user = _services.UserService.create_user(data)

        assert user.id is not None
        assert user.email == 'test@example.com'
        assert user.created_at is not None

    def test_create_user_duplicate_email(self):
        """Test creation fails with duplicate email."""
        _models.User.objects.create(email='existing@example.com')

        with pytest.raises(ValidationError) as exc:
            _services.UserService.create_user({'email': 'existing@example.com'})

        assert 'email' in str(exc.value)
```

## Requirements

- Use pytest, not unittest
- Import pattern: `import app.models as _app_models`
- Minimum 2 assertions per test
- Test happy path AND error paths
- Use factories for complex data (factory_boy)
- Mark DB tests with `@pytest.mark.django_db`

## Test Categories

1. Unit tests (80%): Models, services, utilities
2. Integration tests (15%): API endpoints
3. Edge cases (5%): Boundaries, errors

## Forbidden

- Tests without assertions
- `assert True` or `assert obj` (meaningless)
- Shared mutable state between tests
- Skipped tests without explanation
```

#### 2.2.6 Migrations Rule

**File**: `plugins/smi-django/rules/migrations.md`

```markdown
---
paths:
  - "**/migrations/**/*.py"
---

# Django Migration Standards

## Safety First

Migrations MUST be:
- Reversible
- Non-destructive
- Tested before deployment

## Dangerous Operations

### Column Removal (3-step process)

```python
# Step 1: Make nullable (Migration 1)
migrations.AlterField(
    model_name='user',
    name='legacy_field',
    field=models.CharField(max_length=100, null=True, blank=True),
)

# Step 2: Deploy code that stops writing to field
# Step 3: Remove field (Migration 2, separate deploy)
migrations.RemoveField(
    model_name='user',
    name='legacy_field',
)
```

### Type Changes

```python
# WRONG - Data loss risk
migrations.AlterField(
    model_name='product',
    name='price',
    field=models.IntegerField(),  # Was DecimalField!
)

# CORRECT - Add new field, migrate data, remove old
migrations.AddField(
    model_name='product',
    name='price_cents',
    field=models.IntegerField(null=True),
)
migrations.RunPython(migrate_price_to_cents, reverse_migrate),
migrations.RemoveField('product', 'price'),
migrations.RenameField('product', 'price_cents', 'price'),
```

## Requirements

- Always include `reverse_code` for RunPython
- Test migrations: forward AND backward
- Never use `--fake` in production
- Review auto-generated migrations before committing
```

### 2.3 Next.js Path-Specific Rules

#### 2.3.1 Components Rule

**File**: `plugins/smi-nextjs/rules/components.md`

```markdown
---
paths:
  - "**/components/**/*.tsx"
  - "**/components/**/*.jsx"
---

# Next.js Component Standards

## Accessibility (WCAG 2.1 AA)

```tsx
// WRONG - No keyboard access
<div onClick={handleClick}>Click me</div>

// CORRECT - Semantic HTML
<button type="button" onClick={handleClick}>
  Click me
</button>
```

## Form Pattern (React Hook Form + Zod)

```tsx
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'

const schema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
})

type FormData = z.infer<typeof schema>

export function LoginForm() {
  const { register, handleSubmit, formState: { errors } } = useForm<FormData>({
    resolver: zodResolver(schema),
  })

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email')} aria-label="Email" />
      {errors.email && <span role="alert">{errors.email.message}</span>}
    </form>
  )
}
```

## Import Pattern

```tsx
// CORRECT - Path aliases
import { Button } from '@/components/ui/button'
import { useAuth } from '@/hooks/useAuth'

// WRONG - Deep relative paths
import { Button } from '../../../components/ui/button'
```

## Requirements

- TypeScript strict mode (no `any`)
- Semantic HTML elements
- ARIA attributes where needed
- Error boundaries for async components
- Loading states for data fetching
```

#### 2.3.2 API Routes Rule

**File**: `plugins/smi-nextjs/rules/api-routes.md`

```markdown
---
paths:
  - "**/app/api/**/*.ts"
  - "**/pages/api/**/*.ts"
---

# Next.js API Route Standards

## Structure (App Router)

```typescript
import { NextResponse } from 'next/server'
import { z } from 'zod'

const createUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1),
})

export async function POST(request: Request) {
  try {
    const body = await request.json()
    const data = createUserSchema.parse(body)

    // Business logic
    const user = await createUser(data)

    return NextResponse.json(user, { status: 201 })
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { errors: error.errors },
        { status: 400 }
      )
    }
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}
```

## Requirements

- Zod validation for all inputs
- Proper error handling
- Typed responses
- No secrets in responses
- Rate limiting consideration
```

### 2.4 NestJS Path-Specific Rules

#### 2.4.1 Controllers Rule

**File**: `plugins/smi-nestjs/rules/controllers.md`

```markdown
---
paths:
  - "**/*.controller.ts"
---

# NestJS Controller Standards

## Structure

```typescript
import { Controller, Get, Post, Body, UseGuards } from '@nestjs/common'
import { JwtAuthGuard } from 'src/auth/guards'
import { User } from 'src/users/entities'
import { UsersService } from 'src/users/services'
import { CreateUserDto, UserResponseDto } from 'src/users/dto'

@Controller('users')
@UseGuards(JwtAuthGuard)  // REQUIRED
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  async create(@Body() dto: CreateUserDto): Promise<UserResponseDto> {
    return this.usersService.create(dto)
  }
}
```

## Requirements

- Guards on all protected routes
- DTOs for all inputs
- Response DTOs for outputs
- Absolute imports from barrel exports
- Constructor injection for dependencies
```

#### 2.4.2 Entities Rule

**File**: `plugins/smi-nestjs/rules/entities.md`

```markdown
---
paths:
  - "**/*.entity.ts"
---

# NestJS Entity Standards

## Structure

```typescript
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  DeleteDateColumn,
} from 'typeorm'

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string

  @Column({ unique: true })
  email: string

  @CreateDateColumn()
  createdAt: Date

  @UpdateDateColumn()
  updatedAt: Date

  @DeleteDateColumn()
  deletedAt?: Date  // Soft delete
}
```

## Requirements

- UUID primary keys
- Timestamps (createdAt, updatedAt)
- Soft delete (deletedAt)
- Explicit table name in @Entity()
- Export from barrel (index.ts)
```

### 2.5 Update marketplace.json

Add rules to plugin configuration:

```json
{
  "name": "smi-django",
  "version": "1.2.0",
  "rules": [
    "./rules/models.md",
    "./rules/views.md",
    "./rules/services.md",
    "./rules/serializers.md",
    "./rules/tests.md",
    "./rules/migrations.md"
  ]
}
```

---

## Testing Plan

### Test 1: Rule Activation

```bash
# Open a model file
claude read users/models.py

# Verify models.md rules are active
/memory  # Should show models.md loaded
```

### Test 2: Rule Enforcement

```bash
# Write model without UUID
# Rules should warn/block

# Write view without permissions
# Rules should warn/block
```

---

## Success Criteria

- [ ] Rules directory created for each plugin
- [ ] Path patterns correctly match files
- [ ] Rules activate when editing matching files
- [ ] Rules don't activate for non-matching files
- [ ] marketplace.json updated with rules arrays

---

## Files to Create

### Django (6 rules)
1. `plugins/smi-django/rules/models.md`
2. `plugins/smi-django/rules/views.md`
3. `plugins/smi-django/rules/services.md`
4. `plugins/smi-django/rules/serializers.md`
5. `plugins/smi-django/rules/tests.md`
6. `plugins/smi-django/rules/migrations.md`

### Next.js (3 rules)
1. `plugins/smi-nextjs/rules/components.md`
2. `plugins/smi-nextjs/rules/api-routes.md`
3. `plugins/smi-nextjs/rules/hooks.md`

### NestJS (4 rules)
1. `plugins/smi-nestjs/rules/controllers.md`
2. `plugins/smi-nestjs/rules/entities.md`
3. `plugins/smi-nestjs/rules/services.md`
4. `plugins/smi-nestjs/rules/dto.md`

### Nuxt.js (3 rules)
1. `plugins/smi-nuxtjs/rules/components.md`
2. `plugins/smi-nuxtjs/rules/composables.md`
3. `plugins/smi-nuxtjs/rules/server-routes.md`
