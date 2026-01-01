---
name: code-review
description: Comprehensive code review workflow covering security, quality, and standards
---

# Code Review Workflow

Multi-phase code review workflow ensuring security, quality, and adherence to Smicolon standards.

## Overview

This workflow provides a systematic approach to reviewing code across security, conventions, performance, and testing dimensions.

## Review Phases

### Phase 1: Convention Compliance

**Focus:** Verify adherence to Smicolon standards

**Checks:**
- [ ] Import patterns (absolute imports with aliases)
- [ ] Model/entity standard fields (UUID, timestamps, soft delete)
- [ ] Service layer separation (no business logic in views/controllers)
- [ ] Type hints/TypeScript types present
- [ ] Validation rules on all inputs
- [ ] Permissions/guards configured

**Actions:**
```
1. Review import statements
   - Django: `import app.models as _app_models`
   - NestJS: `import { Entity } from 'src/module/entities'`

2. Verify model/entity structure
   - UUID primary keys
   - created_at, updated_at timestamps
   - is_deleted or deletedAt for soft deletes

3. Check business logic location
   - Should be in service layer
   - Not in views/controllers

4. Verify type safety
   - Python: Type hints on function parameters
   - TypeScript: No `any` types
```

### Phase 2: Security Review

**Focus:** Identify security vulnerabilities

**Checks:**
- [ ] Authentication required on protected endpoints
- [ ] Authorization checks (permissions/guards)
- [ ] Input validation and sanitization
- [ ] SQL injection prevention (ORM usage)
- [ ] XSS prevention (proper escaping)
- [ ] CSRF protection configured
- [ ] Rate limiting on public endpoints
- [ ] Secrets not hardcoded
- [ ] Sensitive data properly encrypted

**Actions:**
```
1. @django-reviewer "Review for security vulnerabilities"

2. Check authentication:
   - All views have `permission_classes`
   - All controllers have `@UseGuards()`

3. Verify input validation:
   - Django: Serializers with validators
   - NestJS: DTOs with class-validator
   - Next.js: Zod schemas on forms

4. Check for common vulnerabilities:
   - Raw SQL queries
   - Eval/exec usage
   - Unvalidated redirects
   - File upload vulnerabilities
```

### Phase 3: Performance Review

**Focus:** Identify performance issues

**Checks:**
- [ ] Database query optimization
- [ ] N+1 query prevention (select_related, prefetch_related)
- [ ] Proper indexing
- [ ] Caching where appropriate
- [ ] Pagination on large datasets
- [ ] Lazy loading implemented
- [ ] Bundle size optimization (frontend)
- [ ] Image optimization

**Actions:**
```
1. Review database queries:
   - Use select_related() for foreign keys
   - Use prefetch_related() for many-to-many
   - Add indexes for frequently queried fields

2. Check API responses:
   - Pagination on list endpoints
   - Only return necessary fields
   - Caching for expensive operations

3. Frontend performance:
   - Code splitting
   - Image optimization (next/image, nuxt/image)
   - Lazy loading components
```

### Phase 4: Testing Coverage

**Focus:** Ensure adequate test coverage

**Checks:**
- [ ] Test coverage ≥ 90%
- [ ] Unit tests for all services/business logic
- [ ] Integration tests for API endpoints
- [ ] E2E tests for critical user flows
- [ ] Edge cases covered
- [ ] Error scenarios tested
- [ ] Permission/guard tests

**Actions:**
```
1. Run coverage report:
   - Django: `coverage run && coverage report`
   - NestJS: `npm run test:cov`
   - Next.js: `npm run test -- --coverage`

2. Verify test types exist:
   - Unit: Test individual functions
   - Integration: Test API endpoints
   - E2E: Test complete workflows

3. Check test quality:
   - Clear test names
   - Proper assertions
   - Isolated tests (no dependencies)
   - Mocked external dependencies
```

### Phase 5: Code Quality

**Focus:** General code quality and maintainability

**Checks:**
- [ ] Clear, descriptive naming
- [ ] Functions/methods < 50 lines
- [ ] Classes < 300 lines
- [ ] No code duplication
- [ ] Comments explain "why" not "what"
- [ ] Error handling present
- [ ] Logging appropriate
- [ ] No dead code

**Actions:**
```
1. Review naming:
   - Functions: Verb-based (createUser, validateEmail)
   - Variables: Descriptive (userEmail, not e)
   - Classes: Noun-based (UserService, ProductController)

2. Check function complexity:
   - Extract long functions
   - Reduce nesting (early returns)
   - Single responsibility

3. Verify error handling:
   - Try-catch around external calls
   - Proper error messages
   - Logging for debugging
```

### Phase 6: Documentation

**Focus:** Code is properly documented

**Checks:**
- [ ] API endpoints documented (Swagger/OpenAPI)
- [ ] Complex functions have docstrings
- [ ] README updated if needed
- [ ] Migration guides for breaking changes
- [ ] Environment variables documented

**Actions:**
```
1. Check API documentation:
   - Django: drf-spectacular annotations
   - NestJS: @ApiOperation decorators
   - Generated docs accessible

2. Verify code documentation:
   - Python: Docstrings on classes/functions
   - TypeScript: JSDoc comments
   - Complex logic explained

3. Update project docs:
   - README for new features
   - Migration guides for changes
   - Environment setup if changed
```

## Usage Example

### Full Review

```bash
# 1. Convention compliance
"Review imports, model structure, and service layer separation"

# 2. Security review
@django-reviewer "Comprehensive security audit of authentication module"

# 3. Performance check
"Review database queries, identify N+1 issues, check indexes"

# 4. Test coverage
@django-tester "Verify test coverage for authentication module"

# 5. Code quality
"Review naming, function size, error handling"

# 6. Documentation
"Verify API documentation and docstrings"
```

### Quick Security Review

```bash
@django-reviewer "Security audit of API endpoints"
```

### Performance Review

```bash
"Review all database queries for N+1 issues and missing indexes"
```

## Review Checklist Template

```markdown
## Code Review: [Feature Name]

### Convention Compliance
- [ ] Absolute imports used
- [ ] Standard model fields present
- [ ] Business logic in service layer
- [ ] Type hints/types present

### Security
- [ ] Authentication configured
- [ ] Authorization checks present
- [ ] Input validation complete
- [ ] No security vulnerabilities

### Performance
- [ ] Queries optimized
- [ ] Indexes added
- [ ] Caching implemented where needed
- [ ] No N+1 queries

### Testing
- [ ] Coverage ≥ 90%
- [ ] Unit tests present
- [ ] Integration tests present
- [ ] Edge cases covered

### Code Quality
- [ ] Clear naming
- [ ] Functions < 50 lines
- [ ] Error handling present
- [ ] No code duplication

### Documentation
- [ ] API documented
- [ ] Complex logic explained
- [ ] README updated

## Issues Found
1. [List issues here]

## Recommendations
1. [List recommendations here]

## Approval
- [ ] Approved
- [ ] Needs changes (see issues)
```

## Common Issues and Fixes

### Import Pattern Violations

**Issue:**
```python
# Django
from .models import User  # Relative import

# NestJS
import { User } from './entities/user.entity'  # Relative import
```

**Fix:**
```python
# Django
import users.models as _users_models
user = _users_models.User.objects.get(id=user_id)

# NestJS
import { User } from 'src/users/entities'
```

### Missing Standard Fields

**Issue:**
```python
class Product(models.Model):
    name = models.CharField(max_length=255)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    # Missing id, timestamps, is_deleted
```

**Fix:**
```python
import uuid
from django.db import models

class Product(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_deleted = models.BooleanField(default=False)

    name = models.CharField(max_length=255)
    price = models.DecimalField(max_digits=10, decimal_places=2)
```

### N+1 Query Problem

**Issue:**
```python
products = Product.objects.all()
for product in products:
    print(product.created_by.email)  # N+1 queries
```

**Fix:**
```python
products = Product.objects.select_related('created_by').all()
for product in products:
    print(product.created_by.email)  # Single query with JOIN
```

### Missing Permissions

**Issue:**
```python
# Django
class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.all()
    serializer_class = ProductSerializer
    # Missing permission_classes!
```

**Fix:**
```python
from rest_framework import permissions

class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.all()
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticated]
```

## Success Criteria

- [ ] All convention violations fixed
- [ ] No security vulnerabilities
- [ ] Performance issues addressed
- [ ] Test coverage ≥ 90%
- [ ] Code quality standards met
- [ ] Documentation complete
- [ ] Ready for production deployment

## Notes

- Use `@django-reviewer` agent for automated security reviews
- Always review database migrations before applying
- Consider peer review in addition to automated checks
- Block merges if critical issues found
- Document any technical debt for future work
