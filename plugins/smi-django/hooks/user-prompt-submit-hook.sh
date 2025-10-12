#!/bin/bash
# Smicolon Convention Enforcement Hook
# This hook runs before Claude processes user prompts to inject Smicolon standards

# Get the user's prompt from stdin
USER_PROMPT=$(cat)

# Detect project type
INJECT_CONVENTIONS=""

if [ -f "manage.py" ] || [ -d "config/settings" ]; then
  # Django project detected
  INJECT_CONVENTIONS="

## 🔵 Smicolon Django Conventions (MANDATORY)

Before proceeding, remember these CRITICAL Smicolon standards:

1. **ABSOLUTE MODULAR IMPORTS WITH ALIASES** - Always use module imports with underscore aliases
   - ✅ CORRECT: import users.models as _models
   - ✅ CORRECT: import users.services as _services
   - ✅ Then use: user = _models.User.objects.get(id=user_id)
   - ❌ WRONG: from .models import User (relative import)
   - ❌ WRONG: from users.models import User (direct class import)

2. **Standard Model Pattern** - All models must have:
   - UUID primary key: id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
   - Timestamps: created_at, updated_at (auto_now_add, auto_now)
   - Soft delete: is_deleted = models.BooleanField(default=False)

3. **Module Exports** - All module folders need __init__.py with __all__ exports
   - Example: from users.models.user import User; __all__ = ['User']

4. **Type Hints Required** - All function signatures need type hints

5. **Service Layer** - Business logic goes in services, not views

6. **Security First** - All views need permission classes
"

elif [ -f "package.json" ] && grep -q "next" package.json 2>/dev/null; then
  # Next.js project detected
  INJECT_CONVENTIONS="

## 🔵 Smicolon Next.js Conventions (MANDATORY)

Before proceeding, remember these CRITICAL Smicolon standards:

1. **TypeScript Strict Mode** - All code must be properly typed
   - No 'any' types
   - Proper interface definitions

2. **Form Validation** - Use React Hook Form + Zod for all forms

3. **API Client** - Use TanStack Query for all API calls

4. **Styling** - Use Tailwind CSS only

5. **Error Handling** - Proper error states and loading states

6. **Accessibility** - WCAG 2.1 AA compliance required

7. **Testing Required** - All features must have tests
   - Unit tests: Components, hooks, utilities (80%+ coverage)
   - Integration tests: Forms, API calls, user flows
   - E2E tests: Critical user journeys
   - Accessibility tests: All components must pass axe
   - Use @frontend-tester agent for comprehensive testing
"

elif [ -f "package.json" ] && grep -q "nuxt" package.json 2>/dev/null; then
  # Nuxt.js project detected
  INJECT_CONVENTIONS="

## 🔵 Smicolon Nuxt.js Conventions (MANDATORY)

Before proceeding, remember these CRITICAL Smicolon standards:

1. **TypeScript Strict Mode** - All code must be properly typed
   - No 'any' types
   - Proper interface definitions

2. **Vue 3 Composition API** - Always use <script setup lang=\"ts\">

3. **Form Validation** - Use VeeValidate + Zod for all forms

4. **Data Fetching** - Use Nuxt composables (useFetch, useAsyncData)

5. **State Management** - Use Pinia for global state

6. **Styling** - Use Tailwind CSS

7. **Auto-imports** - Leverage Nuxt auto-import system

8. **Accessibility** - WCAG 2.1 AA compliance required

9. **Testing Required** - All features must have tests
   - Unit tests: Components, composables, utilities (80%+ coverage)
   - Integration tests: Forms, API calls, user flows
   - E2E tests: Critical user journeys
   - Accessibility tests: All components must pass axe
   - Use @frontend-tester agent for comprehensive testing
"

elif [ -f "package.json" ] && grep -q "\"@nestjs/core\"" package.json 2>/dev/null; then
  # NestJS project detected
  INJECT_CONVENTIONS="

## 🔵 Smicolon NestJS Conventions (MANDATORY)

Before proceeding, remember these CRITICAL Smicolon standards:

1. **ABSOLUTE IMPORTS** - Always use absolute imports from barrel exports
   - ✅ CORRECT: import { User } from 'src/users/entities'
   - ✅ CORRECT: import { UsersService } from 'src/users/services'
   - ✅ CORRECT: import { CreateUserDto } from 'src/users/dto'
   - ❌ WRONG: import { User } from './entities/user.entity' (relative import)
   - ❌ WRONG: import { User } from '../entities' (relative import)

2. **Entity Pattern** - All entities must have:
   - UUID primary key: @PrimaryGeneratedColumn('uuid')
   - Timestamps: @CreateDateColumn(), @UpdateDateColumn()
   - Soft delete: @DeleteDateColumn()

3. **DTOs with Validation** - Use class-validator decorators

4. **Dependency Injection** - Use @Injectable() and constructor injection

5. **Guards** - All protected routes need @UseGuards()

6. **Index Files** - Export all from index.ts in each folder (barrel exports)
"
fi

# Output the modified prompt
echo "${USER_PROMPT}${INJECT_CONVENTIONS}"
