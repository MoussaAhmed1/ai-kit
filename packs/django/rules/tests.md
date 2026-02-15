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
import users.models as _users_models
import users.services as _users_services
from rest_framework.test import APIClient
from rest_framework import status

@pytest.mark.django_db
class TestUserService:
    """Tests for UserService."""

    def test_create_user_success(self):
        """Test successful user creation."""
        data = {'email': 'test@example.com', 'password': 'secure123'}

        user = _users_services.UserService.create_user(data)

        assert user.id is not None
        assert user.email == 'test@example.com'
        assert user.created_at is not None

    def test_create_user_duplicate_email(self):
        """Test creation fails with duplicate email."""
        _users_models.User.objects.create(email='existing@example.com')

        with pytest.raises(ValidationError) as exc:
            _users_services.UserService.create_user({'email': 'existing@example.com'})

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

## Forbidden Patterns

- Tests without assertions
- `assert True` or `assert obj` (meaningless)
- Shared mutable state between tests
- Skipped tests without explanation

## Test Naming

```python
# Pattern: test_{method}_{scenario}_{expected_result}
def test_create_user_success(self):
def test_create_user_duplicate_email_raises_validation_error(self):
def test_get_user_not_found_raises_does_not_exist(self):
```

## API Test Pattern

```python
@pytest.mark.django_db
class TestUserAPI:
    """API tests for User endpoints."""

    @pytest.fixture
    def client(self):
        return APIClient()

    @pytest.fixture
    def authenticated_client(self, user):
        client = APIClient()
        client.force_authenticate(user=user)
        return client

    def test_list_users_unauthenticated_returns_401(self, client):
        response = client.get('/api/users/')
        assert response.status_code == status.HTTP_401_UNAUTHORIZED

    def test_list_users_authenticated_returns_200(self, authenticated_client):
        response = authenticated_client.get('/api/users/')
        assert response.status_code == status.HTTP_200_OK
        assert 'results' in response.data
```

## Factory Pattern

```python
import factory
from factory.django import DjangoModelFactory
import users.models as _users_models

class UserFactory(DjangoModelFactory):
    class Meta:
        model = _users_models.User

    email = factory.Sequence(lambda n: f'user{n}@example.com')
    first_name = factory.Faker('first_name')
    last_name = factory.Faker('last_name')
    is_active = True

# Usage in tests
def test_list_users(self, authenticated_client):
    UserFactory.create_batch(5)
    response = authenticated_client.get('/api/users/')
    assert len(response.data['results']) == 5
```

## Fixtures

```python
@pytest.fixture
def user():
    return UserFactory()

@pytest.fixture
def admin_user():
    return UserFactory(is_staff=True, is_superuser=True)

@pytest.fixture
def product(user):
    return ProductFactory(owner=user)
```
