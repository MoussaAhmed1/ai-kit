# Django Development Standards Plugin

Smicolon company standards for Django projects.

## Installation

```bash
# Add Smicolon marketplace
/plugin marketplace add smicolon https://github.com/smicolon/claude-infra

# Install Django plugin
/plugin install smi-django
```

## What's Included

### 5 Specialized Agents

- `@django-architect` - System architecture design and planning
- `@django-builder` - Feature implementation with best practices
- `@django-feature-based` - Large-scale feature-based architecture
- `@django-tester` - Test writing (90%+ coverage target)
- `@django-reviewer` - Security and code review

### Automatic Convention Enforcement

The plugin includes hooks that automatically enforce:

**Import Pattern:**
```python
# CORRECT - Absolute modular imports with aliases
import users.models as _models
import users.services as _services

user = _models.User.objects.get(id=user_id)

# WRONG - Never use
from .models import User
from users.models import User
```

**Model Standards:**
- UUID primary keys
- Timestamps (created_at, updated_at)
- Soft deletes (is_deleted)
- Service layer for business logic
- Type hints required
- Permission classes on all views

## Usage

```bash
# Start with architecture
@django-architect "Design a payment processing system"

# Implement features
@django-builder "Implement payment processing"

# Write tests
@django-tester "Write tests for payment system"

# Review for security
@django-reviewer "Review payment code for security issues"
```

## Documentation

See the main [Smicolon Claude Infra repository](https://github.com/smicolon/claude-infra) for complete documentation.
