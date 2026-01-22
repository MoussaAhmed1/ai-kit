<!--
  SYNC IMPACT REPORT
  ==================
  Version Change: 0.0.0 → 1.0.0 (Initial ratification)

  Added Principles:
  - I. Convention Enforcement First
  - II. Test-First Development
  - III. Security by Default
  - IV. Framework-Specific Standards
  - V. Simplicity & YAGNI

  Added Sections:
  - Framework-Specific Standards (Django, NestJS, Next.js/Nuxt.js, Hono, TanStack)
  - Plugin Development Standards
  - Governance

  Templates Requiring Updates:
  - .specify/templates/plan-template.md: ✅ No changes needed (Constitution Check already present)
  - .specify/templates/spec-template.md: ✅ No changes needed (generic template)
  - .specify/templates/tasks-template.md: ✅ No changes needed (generic template)

  Follow-up TODOs: None
-->

# Smicolon Claude Infra Constitution

## Core Principles

### I. Convention Enforcement First

All code generated or reviewed by Smicolon plugins MUST adhere to framework-specific
conventions automatically. Convention enforcement is not optional—it is the primary
purpose of this marketplace.

**Non-Negotiables:**
- Import patterns MUST follow framework-specific absolute import standards
- Model/Entity structures MUST include UUID primary keys, timestamps, and soft deletes
- Type safety MUST be enforced (TypeScript strict mode, Python type hints)
- Skills auto-invoke to enforce conventions without manual intervention

**Rationale:** Consistent conventions across projects reduce cognitive load, enable
code sharing, and eliminate debates about style during code reviews.

### II. Test-First Development

Testing is a first-class citizen. All features SHOULD be developed using TDD
(Test-Driven Development) methodology when explicitly requested.

**Non-Negotiables:**
- Test coverage target: 90%+ for all implemented features
- Red-Green-Refactor cycle MUST be followed when TDD is requested
- Tests MUST fail before implementation code is written (red phase verification)
- Integration tests MUST cover cross-component interactions

**Rationale:** Tests written first ensure requirements are understood before
implementation begins. High coverage prevents regression and enables refactoring.

### III. Security by Default

Security MUST NOT be an afterthought. Every endpoint, form, and data access point
MUST have security considerations built in from the start.

**Non-Negotiables:**
- All API endpoints MUST have explicit permission classes/guards
- All user input MUST be validated (Zod, class-validator, Django validators)
- Rate limiting MUST be considered for public endpoints
- Sensitive data MUST never be logged or exposed in error messages
- OWASP Top 10 vulnerabilities MUST be prevented by default

**Rationale:** Security breaches are costly. Building security in from the start
is far cheaper than retrofitting it later.

### IV. Framework-Specific Standards

Each framework has opinionated standards that MUST be followed. These are not
suggestions—they are enforced by auto-invoking skills.

**Rationale:** Framework-specific conventions exist because they solve real problems
specific to that ecosystem. Deviating creates maintenance burden and confusion.

### V. Simplicity & YAGNI

Complexity MUST be justified. Every abstraction, pattern, or additional layer
requires explicit rationale for its existence.

**Non-Negotiables:**
- No premature abstractions—implement what is needed NOW
- No speculative features—build only what is explicitly requested
- Prefer boring, readable code over clever solutions
- Three similar lines of code are better than one premature abstraction
- Maximum 3 layers of indirection without explicit justification

**Rationale:** Over-engineering creates technical debt that slows future development.
Simple code is easier to understand, test, and modify.

## Framework-Specific Standards

### Django Standards

**Import Pattern:**
```python
# ✅ REQUIRED - Absolute modular imports with aliases
import users.models as _users_models
import users.services as _users_services

user = _users_models.User.objects.get(id=user_id)

# ❌ FORBIDDEN
from .models import User  # Relative import
from users.models import User  # Direct import without alias
```

**Model Pattern:**
```python
# ✅ REQUIRED - All models MUST include these fields
class YourModel(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_deleted = models.BooleanField(default=False)
```

**Additional Requirements:**
- Service layer for business logic (no business logic in views)
- Type hints on all function signatures
- Permission classes on all API views
- Serializers for all API endpoints

### NestJS Standards

**Import Pattern:**
```typescript
// ✅ REQUIRED - Absolute imports from barrel exports
import { User } from 'src/users/entities';
import { UsersService } from 'src/users/services';

// ❌ FORBIDDEN
import { User } from './entities/user.entity';
```

**Entity Pattern:**
```typescript
// ✅ REQUIRED - All entities MUST include these decorators
@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @DeleteDateColumn()
  deletedAt?: Date;
}
```

**Additional Requirements:**
- Barrel exports (index.ts) in all module directories
- DTOs with class-validator decorators
- Guards on all protected routes
- TypeScript strict mode enabled

### Next.js Standards

**Requirements:**
- TypeScript strict mode (no `any` types)
- Zod validation for all forms (React Hook Form + Zod)
- TanStack Query for API data fetching
- Proper error and loading states for all async operations
- Tailwind CSS for styling
- WCAG 2.1 AA accessibility compliance
- Path aliases (@/) for imports

### Nuxt.js Standards

**Requirements:**
- TypeScript strict mode
- Vue 3 Composition API (`<script setup lang="ts">`)
- VeeValidate + Zod for form validation
- Nuxt composables (useFetch, useAsyncData) for data fetching
- Pinia for state management
- WCAG 2.1 AA accessibility compliance
- Path aliases (~/) for imports

### Hono Standards

**Requirements:**
- TypeScript strict mode
- Zod validation for all request bodies
- Proper middleware typing
- Cloudflare bindings integration when targeting Workers
- Type-safe RPC clients for frontend consumption

### TanStack Standards

**Requirements:**
- File-based routing with proper typing
- Query factory pattern for data fetching
- TanStack Form with Zod validation
- Proper loading and error states
- Virtual scrolling for large lists

## Plugin Development Standards

All plugins in this marketplace MUST adhere to the following standards:

**Structure:**
- Each plugin MUST have its own directory under `plugins/`
- Each plugin MUST include a README.md documenting its agents, commands, and skills
- Each plugin MUST include a CHANGELOG.md following Keep a Changelog format
- Version MUST follow semantic versioning (MAJOR.MINOR.PATCH)

**Quality:**
- New plugins start at version 0.1.0 (experimental)
- Promotion to 1.0.0 requires: usage in 2+ real projects, no major bugs in 30 days
- Breaking changes require MAJOR version bump
- All agents MUST have clear role definitions and deliverables

**Documentation:**
- Agent files MUST document: role, conventions enforced, example usage
- Skills MUST document: trigger conditions, enforcement rules
- Commands MUST document: purpose, arguments, expected output

## Governance

### Amendment Process

1. Proposed changes MUST be documented with rationale
2. Changes affecting conventions MUST include migration guidance
3. Version bump type determined by change scope:
   - PATCH: Clarifications, typos, non-semantic changes
   - MINOR: New principle/section added, expanded guidance
   - MAJOR: Principle removed, redefined, or backward-incompatible change

### Compliance

- All PRs/code reviews MUST verify convention compliance
- Complexity beyond these standards MUST be justified in PR description
- Agents and skills MUST enforce these principles automatically
- Manual override of convention enforcement requires explicit approval

### Versioning Policy

This constitution follows semantic versioning. The version reflects the maturity
and stability of the governance framework, not the plugins themselves.

**Version**: 1.0.0 | **Ratified**: 2026-01-06 | **Last Amended**: 2026-01-06
