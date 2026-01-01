---
name: import-convention-enforcer
description: Automatically validate and fix Django import patterns to use absolute modular imports with aliases. Use when writing imports, creating new Python files, modifying existing files, or seeing import statements in code.
---

# Import Convention Enforcer

Auto-enforces Smicolon's absolute modular import pattern for Django projects.

## When This Skill Activates

I automatically run when:
- User writes or modifies Python files
- User creates new models, services, views, or serializers
- User mentions "import", "add", "create", or "refactor"
- User reviews or fixes code
- Any Python file is being written or edited

## Django Import Pattern (MANDATORY)

### ✅ CORRECT Pattern
```python
# Absolute modular imports with app-prefixed aliases
import users.models as _users_models
import users.services as _users_services
import users.serializers as _users_serializers
import core.utils as _core_utils

# Usage - clear which app each import is from
user = _users_models.User.objects.get(id=user_id)
result = _users_services.UserService.create_user(data)
serializer = _users_serializers.UserSerializer(user)
token = _core_utils.generate_token()
```

### Pattern Rule
```
import {app}.{module} as _{app}_{module}
```

### ❌ WRONG Patterns
```python
# Relative imports - NEVER USE
from .models import User
from ..services import UserService

# Direct class imports - NEVER USE
from users.models import User
from users.services import UserService

# Relative module imports - NEVER USE
import .models as models
from . import models
```

## Auto-Validation Process

### Step 1: Detect Import Violations

When I see Python code being written, I scan for:

**Violation Type 1: Relative imports**
```python
from .models import User          # ❌
from ..services import UserService  # ❌
```

**Violation Type 2: Direct class imports**
```python
from users.models import User     # ❌
```

**Violation Type 3: Missing alias**
```python
import users.models               # ❌ (no alias)
```

### Step 2: Auto-Fix Violations

I immediately suggest corrections:

**Before (Violation):**
```python
from .models import User, Profile
from users.services import UserService
```

**After (Corrected):**
```python
import users.models as _users_models
import users.services as _users_services

# Update usage
user = _users_models.User.objects.get(...)
profile = _users_models.Profile.objects.get(...)
result = _users_services.UserService.create_user(...)
```

### Step 3: Explain Why

I tell the developer:
> **Import Pattern Violation Fixed**
>
> Changed relative/direct imports to absolute modular imports with app-prefixed aliases:
> - `from .models import User` → `import users.models as _users_models`
> - Usage: `user = _users_models.User.objects.get(...)`
>
> **Why**: Absolute imports with aliases:
> - ✅ Clear module boundaries
> - ✅ Easier to refactor
> - ✅ No circular dependency issues
> - ✅ Consistent across entire codebase
> - ✅ Scales to large projects

### Step 4: Verify All Imports in File

I check the entire file to ensure ALL imports follow the pattern:

```python
# Check all imports at top of file
import uuid
import users.models as _users_models          # ✅
import users.services as _users_services      # ✅
import features.auth.models as _auth_models   # ✅
from rest_framework import serializers        # ✅ Third-party is fine
from django.db import models                  # ✅ Django imports are fine
```

## Pattern Reference Files

See supporting files for detailed patterns:
- `patterns/django-imports.md` - Complete Django import patterns
- `auto-fixes/convert-relative-imports.py` - Auto-conversion script
- `tests/test-import-patterns.md` - Test cases and examples

## Common Scenarios

### Scenario 1: Creating New Model File

**User writes:**
```python
# users/models.py
from django.db import models
from .base import BaseModel  # ❌ WRONG
```

**I auto-fix to:**
```python
# users/models.py
from django.db import models
import users.models.base as _users_base  # ✅ CORRECT

class User(_users_base.BaseModel):
    pass
```

### Scenario 2: Creating New Service

**User writes:**
```python
# users/services.py
from .models import User  # ❌ WRONG
from .serializers import UserSerializer  # ❌ WRONG
```

**I auto-fix to:**
```python
# users/services.py
import users.models as _users_models  # ✅ CORRECT
import users.serializers as _users_serializers  # ✅ CORRECT

class UserService:
    def create_user(self, data):
        user = _users_models.User.objects.create(**data)
        serializer = _users_serializers.UserSerializer(user)
        return serializer.data
```

### Scenario 3: Cross-App Imports

**User writes:**
```python
# orders/services.py
from users.models import User  # ❌ WRONG
from products.models import Product  # ❌ WRONG
```

**I auto-fix to:**
```python
# orders/services.py
import users.models as _user_models  # ✅ CORRECT
import products.models as _product_models  # ✅ CORRECT

class OrderService:
    def create_order(self, user_id, product_id):
        user = _user_models.User.objects.get(id=user_id)
        product = _product_models.Product.objects.get(id=product_id)
        # ...
```

## Barrel Exports (Optional Enhancement)

For cleaner imports, suggest barrel exports in `__init__.py`:

```python
# users/models/__init__.py
from users.models.user import User
from users.models.profile import Profile

__all__ = ['User', 'Profile']
```

Then allow:
```python
import users.models as _users_models

user = _users_models.User.objects.get(...)  # Clean!
```

## Integration with Hooks

This skill works alongside the `user-prompt-submit-hook.sh` which injects convention reminders. I enforce the actual pattern when code is written.

## Success Criteria

✅ All Python files use absolute modular imports with aliases
✅ Zero relative imports in codebase
✅ Zero direct class imports from same project
✅ Consistent `_alias` naming pattern
✅ Developers understand WHY (explained every time)

## Skill Behavior

**I am PROACTIVE:**
- I check imports WITHOUT being asked
- I fix violations IMMEDIATELY
- I explain WHY the pattern is required
- I update ALL related usage in the file

**I do NOT:**
- Require user to ask "check imports"
- Wait for code review
- Just warn - I FIX automatically

This ensures imports are always correct from the moment code is written.
