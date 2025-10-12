# Smicolon Django Project Template

This template includes all Smicolon conventions for Django development.

## Conventions Included

### 1. Absolute Imports Only
```python
# ✅ CORRECT
from users.models import User
from users.services import UserService

# ❌ WRONG
from .models import User
```

### 2. Standard Model Pattern
```python
import uuid
from django.db import models

class YourModel(models.Model):
    """Model description."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_deleted = models.BooleanField(default=False)

    class Meta:
        db_table = 'your_table'
        indexes = [
            models.Index(fields=['created_at']),
        ]
```

### 3. Service Layer
```python
class YourService:
    """Business logic goes here."""

    @staticmethod
    def your_method(param: str) -> Result:
        """
        Method description.

        Args:
            param: Description

        Returns:
            Description
        """
        pass
```

### 4. Module Structure
```
app/
├── __init__.py
├── models/
│   ├── __init__.py       # Export: from app.models.user import User
│   └── user.py
├── services/
│   ├── __init__.py       # Export: from app.services.user_service import UserService
│   └── user_service.py
├── serializers/
│   ├── __init__.py
│   └── user_serializer.py
└── views/
    ├── __init__.py
    └── user_views.py
```

## Quick Start

1. Install Smicolon conventions:
   ```bash
   bash scripts/install.sh
   ```

2. Start building:
   ```bash
   claude
   /django-architect "Design a user authentication system"
   ```

3. Implement:
   ```bash
   /django-build "Build the authentication system"
   ```

4. Test:
   ```bash
   /django-test "Write tests for authentication"
   ```

5. Review:
   ```bash
   /django-review "Review the authentication code"
   ```

## Commands Available

- `/django-architect` - Architecture and design
- `/django-build` - Feature implementation
- `/django-test` - Write comprehensive tests
- `/django-review` - Security and code review

## Enforced by Hooks

The post-write hook automatically checks for:
- ✅ Absolute imports
- ✅ UUID primary keys
- ✅ Timestamps on models
- ✅ Soft delete fields
- ✅ Permission classes on views

Violations will be flagged immediately.
