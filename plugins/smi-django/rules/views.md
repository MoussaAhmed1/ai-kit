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
# CORRECT - Modular imports with aliases
import users.models as _users_models
import users.services as _users_services
import users.serializers as _users_serializers

# Usage
queryset = _users_users_models.User.objects.filter(is_deleted=False)
serializer_class = _users_users_serializers.UserSerializer
```

## View Structure

```python
class UserViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated]
    throttle_classes = [UserRateThrottle]

    # Use service layer - no raw ORM in views
    def create(self, request):
        serializer = _users_serializers.CreateUserSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = _users_users_services.UserService.create(serializer.validated_data)
        return Response(_users_users_serializers.UserSerializer(user).data, status=201)
```

## Forbidden Patterns

- Views without permission_classes
- Direct `request.data` access without serializer
- ORM queries in view methods (use services)
- `@api_view` without `@permission_classes`
- Hardcoded status codes (use `status.HTTP_*`)

## Response Patterns

```python
from rest_framework import status
from rest_framework.response import Response

# CORRECT
return Response(data, status=status.HTTP_201_CREATED)
return Response(status=status.HTTP_204_NO_CONTENT)

# WRONG
return Response(data, status=201)  # Use named constants
```

## Error Handling

```python
from rest_framework.exceptions import NotFound, PermissionDenied

class UserViewSet(viewsets.ModelViewSet):
    def retrieve(self, request, pk=None):
        try:
            user = _users_users_services.UserService.get_by_id(pk)
        except _users_users_models.User.DoesNotExist:
            raise NotFound("User not found")
        return Response(_users_users_serializers.UserSerializer(user).data)
```

## Pagination

Always use pagination for list views:

```python
from rest_framework.pagination import PageNumberPagination

class StandardPagination(PageNumberPagination):
    page_size = 20
    page_size_query_param = 'page_size'
    max_page_size = 100

class UserViewSet(viewsets.ModelViewSet):
    pagination_class = StandardPagination
```
