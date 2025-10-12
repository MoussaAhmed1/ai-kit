---
name: feature-development
description: Complete feature development workflow from architecture to deployment
---

# Feature Development Workflow

Multi-agent orchestration workflow for end-to-end feature development following Smicolon standards.

## Overview

This workflow coordinates multiple specialized agents to deliver a complete feature from requirements to production-ready code.

## Workflow Phases

### Phase 1: Architecture & Design

**Agents Involved:**
- `@django-architect` (Django projects)
- `@nestjs-architect` (NestJS projects)
- `@nextjs-architect` (Next.js projects)
- `@system-architect` (System diagrams)

**Deliverables:**
1. Data model design (ERD)
2. API endpoint specifications
3. System architecture diagrams
4. Security and performance plan
5. Component/module structure

**Actions:**
```
1. @system-architect: Create ERD and architecture diagrams
2. @{framework}-architect: Design data models and API endpoints
3. Review and validate architecture
4. Get approval before implementation
```

### Phase 2: Backend Implementation

**Agents Involved:**
- `@django-builder` (Django)
- `@nestjs-builder` (NestJS)

**Deliverables:**
1. Models/Entities with migrations
2. Service layer with business logic
3. API endpoints with validation
4. Permission/guard configuration

**Actions:**
```
1. @{framework}-builder: Implement models/entities
2. @{framework}-builder: Implement service layer
3. @{framework}-builder: Implement API endpoints
4. Run migrations and verify database
```

### Phase 3: Frontend Implementation

**Agents Involved:**
- `@nextjs-modular` (Next.js large-scale)
- `@nuxtjs-architect` (Nuxt.js)

**Deliverables:**
1. UI components (TypeScript, Tailwind)
2. Forms with Zod validation
3. API integration with TanStack Query
4. Error and loading states
5. Accessibility compliance

**Actions:**
```
1. @{framework}-architect: Create components
2. @{framework}-architect: Implement forms and validation
3. @{framework}-architect: Integrate with backend API
4. @frontend-visual: Verify visual design (if applicable)
```

### Phase 4: Testing

**Agents Involved:**
- `@django-tester` (Django)
- `@nestjs-tester` (NestJS)
- `@frontend-tester` (Next.js/Nuxt.js)

**Deliverables:**
1. Unit tests (90%+ coverage)
2. Integration tests
3. API endpoint tests
4. E2E tests (frontend)
5. Accessibility tests

**Actions:**
```
1. @{framework}-tester: Generate unit tests
2. @{framework}-tester: Generate integration tests
3. @frontend-tester: Generate E2E tests (if frontend)
4. Run test suite and verify coverage
5. Fix any failing tests
```

### Phase 5: Code Review & Security

**Agents Involved:**
- `@django-reviewer` (Django)
- Security review agents

**Deliverables:**
1. Security audit report
2. Code quality assessment
3. Performance review
4. Recommendations and fixes

**Actions:**
```
1. @django-reviewer: Review security and code quality
2. Address identified issues
3. Re-run tests after fixes
4. Final approval
```

### Phase 6: Documentation & Deployment

**Deliverables:**
1. API documentation
2. Component documentation
3. Deployment guide
4. Migration guide

**Actions:**
```
1. Generate API documentation (Swagger/OpenAPI)
2. Document components and usage
3. Create deployment checklist
4. Create rollback plan
```

## Usage Example

### Django + Next.js Feature

```bash
# 1. Start with architecture
@system-architect "Create ERD for user authentication system with social login"
@django-architect "Design authentication API with JWT and OAuth2"
@nextjs-architect "Design login/signup UI with social buttons"

# 2. Backend implementation
@django-builder "Implement authentication models and API endpoints"

# 3. Frontend implementation
@nextjs-modular "Implement login/signup forms with social auth"

# 4. Testing
@django-tester "Generate tests for authentication API"
@frontend-tester "Generate E2E tests for login flow"

# 5. Review
@django-reviewer "Review authentication implementation for security"

# 6. Visual verification
@frontend-visual "Verify login page matches design"
```

### NestJS API Feature

```bash
# 1. Architecture
@nestjs-architect "Design inventory management module with real-time updates"

# 2. Implementation
@nestjs-builder "Implement inventory module with WebSocket support"

# 3. Testing
@nestjs-tester "Generate comprehensive tests for inventory module"
```

## Best Practices

### Sequential Agent Execution
- **Architecture first** - Always start with design
- **Backend before frontend** - API should be stable before UI
- **Implementation before tests** - Code must exist to test
- **Tests before review** - Ensure code works before review

### Parallel Agent Execution
- Multiple architects can work in parallel (different concerns)
- Frontend and backend can be built in parallel (if API is designed)
- Different test types can run in parallel

### Iteration
- Don't hesitate to go back to previous phases
- Architecture changes may require implementation updates
- Test failures may reveal design flaws

### Communication
- Share architecture documents with all agents
- Pass API specifications to frontend agents
- Share test results with reviewers

## Success Criteria

- [ ] All architecture diagrams created
- [ ] All models/entities implement standard fields (UUID, timestamps, soft delete)
- [ ] All imports follow absolute path conventions
- [ ] API endpoints have proper validation and permissions
- [ ] Frontend components are accessible (WCAG 2.1 AA)
- [ ] Test coverage ≥ 90%
- [ ] No security vulnerabilities identified
- [ ] Code passes review
- [ ] Documentation complete

## Common Pitfalls

1. **Skipping architecture phase** - Leads to rework and inconsistencies
2. **Not using conventions** - Agents assume Smicolon standards are followed
3. **Insufficient testing** - 90% coverage is mandatory
4. **Ignoring security review** - Critical for production code
5. **Missing documentation** - Future developers need context

## Time Estimates

- **Small Feature** (1-2 models, 3-5 endpoints): 2-4 hours
- **Medium Feature** (3-5 models, 10-15 endpoints): 4-8 hours
- **Large Feature** (5+ models, complex logic): 1-3 days

## Notes

- This workflow assumes all Smicolon plugins are installed
- Adjust agent selection based on your tech stack
- Use `/plugin install` to add missing agents
- Consider git worktrees for parallel feature development
