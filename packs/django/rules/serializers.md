---
paths:
  - "**/serializers.py"
  - "**/serializers/*.py"
---

# Django Serializer Standards

## Structure

```python
import users.models as _users_models
from rest_framework import serializers

class UserSerializer(serializers.ModelSerializer):
    """Read serializer for User."""

    class Meta:
        model = _users_models.User
        fields = ['id', 'email', 'first_name', 'last_name', 'created_at']
        read_only_fields = ['id', 'created_at']


class CreateUserSerializer(serializers.Serializer):
    """Write serializer for creating User."""

    email = serializers.EmailField()
    password = serializers.CharField(write_only=True, min_length=8)
    first_name = serializers.CharField(max_length=100)

    def validate_email(self, value):
        if _users_models.User.objects.filter(email=value).exists():
            raise serializers.ValidationError("Email already exists")
        return value.lower()
```

## Import Pattern

```python
import users.models as _users_models
from rest_framework import serializers
```

## Rules

- Separate read/write serializers when needed
- All validation in serializer, not view
- Use `validate_<field>` for field-level validation
- Use `validate` for cross-field validation
- Never expose sensitive fields (password, tokens)

## Naming Convention

- Read serializers: `{Model}Serializer`
- Create serializers: `Create{Model}Serializer`
- Update serializers: `Update{Model}Serializer`
- List serializers (minimal): `{Model}ListSerializer`

## Validation Examples

### Field-Level Validation

```python
class CreateUserSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)

    def validate_email(self, value):
        """Normalize and validate email."""
        value = value.lower().strip()
        if _users_models.User.objects.filter(email=value).exists():
            raise serializers.ValidationError("Email already exists")
        return value

    def validate_password(self, value):
        """Validate password strength."""
        if len(value) < 8:
            raise serializers.ValidationError("Password must be at least 8 characters")
        if not any(c.isdigit() for c in value):
            raise serializers.ValidationError("Password must contain a digit")
        return value
```

### Cross-Field Validation

```python
class PasswordChangeSerializer(serializers.Serializer):
    old_password = serializers.CharField(write_only=True)
    new_password = serializers.CharField(write_only=True)
    confirm_password = serializers.CharField(write_only=True)

    def validate(self, data):
        if data['new_password'] != data['confirm_password']:
            raise serializers.ValidationError({
                "confirm_password": "Passwords do not match"
            })
        if data['old_password'] == data['new_password']:
            raise serializers.ValidationError({
                "new_password": "New password must be different"
            })
        return data
```

## Nested Serializers

```python
class OrderItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = _models.OrderItem
        fields = ['id', 'product', 'quantity', 'price']

class OrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True, read_only=True)
    total = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)

    class Meta:
        model = _models.Order
        fields = ['id', 'user', 'items', 'total', 'created_at']
```

## Forbidden Patterns

- Business logic in serializers (use services)
- Direct database queries (use services)
- Exposing sensitive fields
- Using ModelSerializer for write operations with complex logic
