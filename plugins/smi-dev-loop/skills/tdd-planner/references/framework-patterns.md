# Framework Detection and Patterns

Reference for detecting frameworks and applying appropriate TDD patterns.

---

## Framework Detection

### Detection Order

Check in this order (first match wins):

1. **Django** - `manage.py` exists OR `django` in requirements.txt/pyproject.toml
2. **NestJS** - `@nestjs/core` in package.json dependencies
3. **Next.js** - `next` in package.json dependencies
4. **Nuxt.js** - `nuxt` in package.json dependencies
5. **Generic Python** - `pytest` in requirements OR `pyproject.toml` exists
6. **Generic Node** - `package.json` exists with test script
7. **Fallback** - Generic TDD pattern

### Detection Commands

```bash
# Django
[ -f "manage.py" ] && echo "django"

# Python with pytest
grep -q "pytest" requirements*.txt 2>/dev/null && echo "pytest"

# NestJS
grep -q "@nestjs/core" package.json 2>/dev/null && echo "nestjs"

# Next.js
grep -q '"next"' package.json 2>/dev/null && echo "nextjs"

# Nuxt.js
grep -q '"nuxt"' package.json 2>/dev/null && echo "nuxtjs"
```

---

## Django Patterns

### Commands

| Purpose | Command |
|---------|---------|
| Test | `pytest --tb=short` |
| Test Verbose | `pytest -v` |
| Test Single | `pytest tests/test_file.py::test_name` |
| Coverage | `pytest --cov=app_name --cov-report=term-missing` |
| Lint | `ruff check .` |
| Format | `ruff format .` |
| Migrations | `python manage.py makemigrations && python manage.py migrate` |

### TDD Phase Template

```markdown
### Phase N: Red - {{Component}} Tests

**Tasks:**
- Create tests/test_{{component}}.py
- Import necessary fixtures
- Write test cases using pytest

**Verification:**
```bash
pytest tests/test_{{component}}.py -v
```

**Conventions:**
- Use `import {{app}}.models as _{{app}}_models`
- Use factory_boy for test data
- Use pytest fixtures, not setUp/tearDown
```

### Common Test Patterns

```python
# Model tests
import pytest
import users.models as _users_models

@pytest.mark.django_db
def test_user_creation():
    user = _users_models.User.objects.create_user(
        email="test@example.com",
        password="testpass123"
    )
    assert user.email == "test@example.com"
    assert user.check_password("testpass123")

# API tests
from rest_framework.test import APIClient

@pytest.fixture
def api_client():
    return APIClient()

@pytest.mark.django_db
def test_login(api_client):
    response = api_client.post("/api/auth/login/", {
        "email": "test@example.com",
        "password": "testpass123"
    })
    assert response.status_code == 200
    assert "token" in response.data
```

---

## NestJS Patterns

### Commands

| Purpose | Command |
|---------|---------|
| Test | `npm test` |
| Test Watch | `npm run test:watch` |
| Test Coverage | `npm run test:cov` |
| Test E2E | `npm run test:e2e` |
| Lint | `npm run lint` |
| Format | `npm run format` |

### TDD Phase Template

```markdown
### Phase N: Red - {{Component}} Tests

**Tasks:**
- Create {{component}}.spec.ts
- Set up test module with mocks
- Write test cases

**Verification:**
```bash
npm test -- --testPathPattern={{component}}
```

**Conventions:**
- Use barrel imports: `import { Entity } from 'src/module/entities'`
- Mock dependencies with Jest
- Use describe/it blocks
```

### Common Test Patterns

```typescript
// Service tests
import { Test, TestingModule } from '@nestjs/testing';
import { UsersService } from './users.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { User } from './entities';

describe('UsersService', () => {
  let service: UsersService;
  let mockRepository: jest.Mocked<any>;

  beforeEach(async () => {
    mockRepository = {
      find: jest.fn(),
      findOne: jest.fn(),
      save: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        { provide: getRepositoryToken(User), useValue: mockRepository },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
  });

  it('should find all users', async () => {
    mockRepository.find.mockResolvedValue([{ id: '1', email: 'test@test.com' }]);
    const result = await service.findAll();
    expect(result).toHaveLength(1);
  });
});
```

---

## Next.js Patterns

### Commands

| Purpose | Command |
|---------|---------|
| Test | `npm test` |
| Test Watch | `npm test -- --watch` |
| Test Coverage | `npm test -- --coverage` |
| Lint | `npm run lint` |
| Type Check | `npx tsc --noEmit` |

### TDD Phase Template

```markdown
### Phase N: Red - {{Component}} Tests

**Tasks:**
- Create __tests__/{{component}}.test.tsx
- Set up React Testing Library
- Write component/hook tests

**Verification:**
```bash
npm test -- --testPathPattern={{component}}
```

**Conventions:**
- Use @/ path aliases
- Test user interactions, not implementation
- Use React Testing Library
```

### Common Test Patterns

```tsx
// Component tests
import { render, screen, fireEvent } from '@testing-library/react';
import { LoginForm } from '@/components/LoginForm';

describe('LoginForm', () => {
  it('should submit form with email and password', async () => {
    const onSubmit = jest.fn();
    render(<LoginForm onSubmit={onSubmit} />);

    fireEvent.change(screen.getByLabelText(/email/i), {
      target: { value: 'test@example.com' },
    });
    fireEvent.change(screen.getByLabelText(/password/i), {
      target: { value: 'password123' },
    });
    fireEvent.click(screen.getByRole('button', { name: /submit/i }));

    expect(onSubmit).toHaveBeenCalledWith({
      email: 'test@example.com',
      password: 'password123',
    });
  });
});

// Hook tests
import { renderHook, act } from '@testing-library/react';
import { useAuth } from '@/hooks/useAuth';

describe('useAuth', () => {
  it('should login user', async () => {
    const { result } = renderHook(() => useAuth());

    await act(async () => {
      await result.current.login('test@example.com', 'password');
    });

    expect(result.current.isAuthenticated).toBe(true);
  });
});
```

---

## Nuxt.js Patterns

### Commands

| Purpose | Command |
|---------|---------|
| Test | `npm test` (vitest) |
| Test Watch | `npm test -- --watch` |
| Test Coverage | `npm test -- --coverage` |
| Lint | `npm run lint` |
| Type Check | `npx nuxi typecheck` |

### TDD Phase Template

```markdown
### Phase N: Red - {{Component}} Tests

**Tasks:**
- Create tests/{{component}}.test.ts
- Set up Vue Test Utils
- Write component/composable tests

**Verification:**
```bash
npm test -- {{component}}
```

**Conventions:**
- Use ~/ path aliases
- Use Vue 3 Composition API
- Test with @vue/test-utils
```

### Common Test Patterns

```typescript
// Component tests
import { mount } from '@vue/test-utils';
import { describe, it, expect } from 'vitest';
import LoginForm from '~/components/LoginForm.vue';

describe('LoginForm', () => {
  it('emits submit with credentials', async () => {
    const wrapper = mount(LoginForm);

    await wrapper.find('input[name="email"]').setValue('test@example.com');
    await wrapper.find('input[name="password"]').setValue('password123');
    await wrapper.find('form').trigger('submit');

    expect(wrapper.emitted('submit')).toBeTruthy();
    expect(wrapper.emitted('submit')[0]).toEqual([{
      email: 'test@example.com',
      password: 'password123',
    }]);
  });
});

// Composable tests
import { describe, it, expect } from 'vitest';
import { useAuth } from '~/composables/useAuth';

describe('useAuth', () => {
  it('should login user', async () => {
    const { login, isAuthenticated } = useAuth();

    await login('test@example.com', 'password');

    expect(isAuthenticated.value).toBe(true);
  });
});
```

---

## Generic Fallback

When no specific framework is detected:

### Commands

| Purpose | Command |
|---------|---------|
| Test (Python) | `pytest` |
| Test (Node) | `npm test` |
| Lint (Python) | `ruff check .` or `flake8` |
| Lint (Node) | `npm run lint` or `npx eslint .` |

### TDD Phase Template

```markdown
### Phase N: Red - {{Component}} Tests

**Tasks:**
- Create test file for component
- Write test cases

**Verification:**
Run test command for the detected test framework

**Self-correction:**
- If no test framework found, suggest installing one
```

---

## Framework-Specific Considerations

### Django + Smicolon Conventions

- Use absolute modular imports: `import app.models as _app_models`
- UUID primary keys on all models
- Timestamps: `created_at`, `updated_at`
- Soft deletes: `is_deleted` field
- Service layer for business logic

### NestJS + Smicolon Conventions

- Barrel exports in all directories
- Absolute imports: `import { X } from 'src/module/entities'`
- UUID primary keys
- TypeORM soft deletes with `@DeleteDateColumn()`

### Next.js + Smicolon Conventions

- Path aliases: `@/components`, `@/hooks`
- React Hook Form + Zod for forms
- TanStack Query for data fetching
- WCAG 2.1 AA accessibility

### Nuxt.js + Smicolon Conventions

- Path aliases: `~/components`, `~/composables`
- VeeValidate + Zod for forms
- Built-in composables: `useFetch`, `useAsyncData`
- WCAG 2.1 AA accessibility
