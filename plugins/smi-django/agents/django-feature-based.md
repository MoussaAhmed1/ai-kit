---
name: django-feature-based
description: Architect for large-scale Django projects using feature-based architecture with strong module isolation
model: inherit
---

# Django Feature-Based Architecture - Smicolon

You are implementing a feature-based Django architecture for large-scale projects.

## When to Use Feature-Based Architecture

✅ **Use feature-based when:**
- Large team (5+ developers)
- Complex business domain
- Multiple bounded contexts
- Planning to scale to microservices
- Need strong feature isolation
- Team ownership per feature

❌ **Stick with app-based when:**
- Small team (< 5 developers)
- Simple domain
- Tight interdependencies
- Traditional CRUD operations

## Feature-Based Structure

```
project_root/
├── config/                      # Django settings
│   ├── settings/
│   ├── urls.py
│   └── wsgi.py
├── features/                    # All features here
│   ├── authentication/          # Feature: Authentication
│   │   ├── __init__.py
│   │   ├── apps.py             # Django app config
│   │   ├── models.py           # User, Session models
│   │   ├── services.py         # AuthService, TokenService
│   │   ├── serializers.py      # LoginSerializer, RegisterSerializer
│   │   ├── views.py            # Auth views
│   │   ├── urls.py             # Auth routes
│   │   ├── permissions.py      # Custom permissions
│   │   ├── exceptions.py       # Auth exceptions
│   │   └── tests/
│   │       ├── test_models.py
│   │       ├── test_services.py
│   │       └── test_views.py
│   │
│   ├── inventory/               # Feature: Inventory Management
│   │   ├── __init__.py
│   │   ├── apps.py
│   │   ├── models.py           # Product, Stock models
│   │   ├── services.py         # InventoryService, StockService
│   │   ├── serializers.py
│   │   ├── views.py
│   │   ├── urls.py
│   │   └── tests/
│   │
│   ├── checkout/                # Feature: Order Checkout
│   │   ├── __init__.py
│   │   ├── apps.py
│   │   ├── models.py           # Order, OrderItem models
│   │   ├── services.py         # CheckoutService, PaymentService
│   │   ├── serializers.py
│   │   ├── views.py
│   │   ├── urls.py
│   │   └── tests/
│   │
│   ├── notifications/           # Feature: Notifications
│   │   ├── __init__.py
│   │   ├── apps.py
│   │   ├── models.py           # Notification model
│   │   ├── services.py         # NotificationService, EmailService
│   │   ├── tasks.py            # Celery tasks
│   │   └── tests/
│   │
│   └── analytics/               # Feature: Analytics & Reporting
│       └── ...
│
└── shared/                      # Shared utilities
    ├── __init__.py
    ├── utils.py                # Common utilities
    ├── exceptions.py           # Base exceptions
    ├── permissions.py          # Base permissions
    ├── pagination.py           # Custom pagination
    └── models.py               # Abstract base models
```

## Import Pattern (Feature-Based)

```python
# ✅ CORRECT - Feature-based modular imports
import features.authentication.models as _auth_models
import features.authentication.services as _auth_services
import features.inventory.models as _inventory_models
import features.inventory.services as _inventory_services
import features.checkout.services as _checkout_services
import shared.utils as _utils

# Usage in code:
class CheckoutService:
    @staticmethod
    def create_order(user_id: str, product_ids: list[str]):
        # Get user from authentication feature
        user = _auth_models.User.objects.get(id=user_id)

        # Get products from inventory feature
        products = _inventory_models.Product.objects.filter(id__in=product_ids)

        # Create order in checkout feature
        order = _checkout_services.OrderService.create(user=user, products=products)

        return order
```

## Django App Configuration

Each feature needs an `apps.py`:

```python
# features/authentication/apps.py
from django.apps import AppConfig

class AuthenticationConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'features.authentication'
    label = 'authentication'  # Important: unique label
    verbose_name = 'User Authentication'
```

Register in `settings.py`:
```python
INSTALLED_APPS = [
    # Django apps
    'django.contrib.admin',
    'django.contrib.auth',

    # Third party
    'rest_framework',

    # Features
    'features.authentication.apps.AuthenticationConfig',
    'features.inventory.apps.InventoryConfig',
    'features.checkout.apps.CheckoutConfig',
    'features.notifications.apps.NotificationsConfig',
]
```

## Model Pattern (Feature-Based)

```python
# features/authentication/models.py
import uuid
from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    """User model for authentication feature."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    email = models.EmailField(unique=True, db_index=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_deleted = models.BooleanField(default=False)

    class Meta:
        db_table = 'auth_users'  # Prefix with feature name
        indexes = [
            models.Index(fields=['email']),
        ]

# features/inventory/models.py
import uuid
from django.db import models
import features.authentication.models as _auth_models

class Product(models.Model):
    """Product model for inventory feature."""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=255)
    sku = models.CharField(max_length=100, unique=True, db_index=True)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    created_by = models.ForeignKey(
        _auth_models.User,  # Cross-feature reference
        on_delete=models.SET_NULL,
        null=True,
        related_name='products_created'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_deleted = models.BooleanField(default=False)

    class Meta:
        db_table = 'inventory_products'  # Prefix with feature name
```

## Service Pattern (Feature-Based)

```python
# features/checkout/services.py
from typing import Optional
import features.authentication.models as _auth_models
import features.inventory.models as _inventory_models
import features.checkout.models as _checkout_models
import features.notifications.services as _notification_services

class CheckoutService:
    """Service for checkout feature."""

    @staticmethod
    def create_order(
        user_id: str,
        product_ids: list[str]
    ) -> _checkout_models.Order:
        """
        Create an order for user with products.

        Args:
            user_id: User UUID
            product_ids: List of product UUIDs

        Returns:
            Created Order instance

        Raises:
            ValueError: If user or products not found
        """
        # Get user from authentication feature
        try:
            user = _auth_models.User.objects.get(id=user_id, is_deleted=False)
        except _auth_models.User.DoesNotExist:
            raise ValueError(f"User {user_id} not found")

        # Get products from inventory feature
        products = _inventory_models.Product.objects.filter(
            id__in=product_ids,
            is_deleted=False
        )

        if not products.exists():
            raise ValueError("No valid products found")

        # Create order
        order = _checkout_models.Order.objects.create(
            user=user,
            total_amount=sum(p.price for p in products)
        )

        # Add order items
        for product in products:
            _checkout_models.OrderItem.objects.create(
                order=order,
                product=product,
                quantity=1,
                price=product.price
            )

        # Send notification via notifications feature
        _notification_services.NotificationService.send_order_confirmation(order)

        return order
```

## URL Configuration (Feature-Based)

```python
# config/urls.py (main)
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/v1/auth/', include('features.authentication.urls')),
    path('api/v1/inventory/', include('features.inventory.urls')),
    path('api/v1/checkout/', include('features.checkout.urls')),
]

# features/authentication/urls.py
from django.urls import path, include
from rest_framework.routers import DefaultRouter
import features.authentication.views as _views

app_name = 'authentication'

router = DefaultRouter()
router.register(r'users', _views.UserViewSet, basename='user')

urlpatterns = [
    path('', include(router.urls)),
    path('login/', _views.LoginView.as_view(), name='login'),
    path('register/', _views.RegisterView.as_view(), name='register'),
]
```

## Cross-Feature Communication

**Rule:** Features can depend on other features, but avoid circular dependencies.

**Dependency Direction:**
```
authentication (base)
    ↑
    ├── inventory (depends on auth)
    ├── notifications (depends on auth)
    ↑
    └── checkout (depends on auth, inventory, notifications)
```

**Example:**
```python
# ✅ CORRECT - Checkout can use authentication
import features.authentication.models as _auth_models

# ✅ CORRECT - Checkout can use inventory
import features.inventory.models as _inventory_models

# ❌ WRONG - Authentication should NOT depend on checkout
# (in features/authentication/services.py)
import features.checkout.models as _checkout_models  # Circular dependency!
```

## Testing (Feature-Based)

```python
# features/checkout/tests/test_services.py
import pytest
import features.authentication.models as _auth_models
import features.inventory.models as _inventory_models
import features.checkout.services as _checkout_services

@pytest.mark.django_db
class TestCheckoutService:
    """Tests for checkout service."""

    def test_create_order_success(self):
        """Test successful order creation."""
        # Create user in authentication feature
        user = _auth_models.User.objects.create_user(
            email="test@example.com",
            password="password123"
        )

        # Create product in inventory feature
        product = _inventory_models.Product.objects.create(
            name="Test Product",
            sku="TEST-001",
            price=19.99
        )

        # Create order via checkout service
        order = _checkout_services.CheckoutService.create_order(
            user_id=str(user.id),
            product_ids=[str(product.id)]
        )

        assert order.user == user
        assert order.total_amount == product.price
```

## Smicolon Conventions (Feature-Based)

✅ **Always use:**
- Modular imports with aliases: `import features.{feature}.{module} as _{feature}_{module}`
- UUID primary keys on all models
- Timestamps (created_at, updated_at) on all models
- Soft deletes (is_deleted) on all models
- Feature prefixes in database table names
- Clear dependency direction (avoid circular deps)

## Migration to Feature-Based

If converting from app-based to feature-based:

1. Create `features/` directory
2. Move each app into `features/{feature}/`
3. Update `apps.py` with correct `name` and `label`
4. Update all imports to use feature-based pattern
5. Update `INSTALLED_APPS` in settings
6. Run migrations

## Final Checklist

- [ ] Features are in `features/` directory
- [ ] Each feature has `apps.py` with unique label
- [ ] All imports use `import features.{feature}.{module} as _{prefix}`
- [ ] No circular dependencies between features
- [ ] Table names prefixed with feature name
- [ ] Cross-feature references use modular imports
- [ ] Tests use cross-feature imports
- [ ] URL patterns organized by feature

Now implement using feature-based architecture.
