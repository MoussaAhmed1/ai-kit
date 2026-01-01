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
import users.models as _users_models
from django.db import transaction

class UserService:
    """
    Business logic for User operations.
    All methods are static or class methods.
    """

    @staticmethod
    @transaction.atomic
    def create_user(data: dict) -> _users_models.User:
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
        user = _users_models.User.objects.create(**data)
        # Side effects (emails, notifications)
        return user
```

## Requirements

- All database operations use `@transaction.atomic`
- Methods have type hints
- Docstrings explain purpose, args, returns, raises
- Static methods preferred (no instance state)
- Import pattern: `import app.models as _models`

## Forbidden Patterns

- Service methods calling views
- Circular service dependencies
- HTTP-specific code (request, response)
- Direct print statements (use logging)
- Catching broad exceptions without re-raising

## Method Patterns

### Query Methods

```python
@staticmethod
def get_by_id(user_id: uuid.UUID) -> _users_models.User:
    """Get user by ID or raise DoesNotExist."""
    return _users_models.User.objects.get(id=user_id, is_deleted=False)

@staticmethod
def get_active_users() -> QuerySet[_users_models.User]:
    """Get all active users."""
    return _users_models.User.objects.filter(is_active=True, is_deleted=False)
```

### Mutation Methods

```python
@staticmethod
@transaction.atomic
def update_user(user_id: uuid.UUID, data: dict) -> _users_models.User:
    """Update user fields."""
    user = _users_models.User.objects.select_for_update().get(id=user_id)
    for key, value in data.items():
        setattr(user, key, value)
    user.save()
    return user

@staticmethod
@transaction.atomic
def soft_delete_user(user_id: uuid.UUID) -> None:
    """Soft delete a user."""
    _users_models.User.objects.filter(id=user_id).update(is_deleted=True)
```

## Error Handling

```python
import logging
from django.core.exceptions import ValidationError

logger = logging.getLogger(__name__)

class UserService:
    @staticmethod
    @transaction.atomic
    def create_user(data: dict) -> _users_models.User:
        try:
            user = _users_models.User.objects.create(**data)
            logger.info(f"Created user: {user.id}")
            return user
        except IntegrityError as e:
            logger.error(f"Failed to create user: {e}")
            raise ValidationError("User with this email already exists")
```

## Testing Services

Services should be the primary unit test target:

```python
@pytest.mark.django_db
class TestUserService:
    def test_create_user_success(self):
        data = {'email': 'test@example.com', 'password': 'secure123'}
        user = UserService.create_user(data)
        assert user.id is not None
        assert user.email == 'test@example.com'
```
