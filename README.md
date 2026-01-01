# Smicolon Claude Code Infrastructure

**Company-wide development standards enforcement via Claude Code marketplace.**

7 plugins for Django, NestJS, Next.js, Nuxt.js, system architecture, dev loops, and failure memory.

---

## Quick Start (2 minutes)

```bash
# 1. Add Smicolon marketplace
/plugin marketplace add https://github.com/smicolon/claude-infra
# or
/plugin marketplace add smicolon/claude-infra

# 2. Install plugins for your tech stack
/plugin install smi-django          # Django (5 agents)
/plugin install smi-nextjs          # Next.js (4 agents)
/plugin install smi-architect       # System diagrams (1 agent)

# Or install everything
/plugin install smi-django smi-nestjs smi-nextjs smi-nuxtjs smi-architect smi-dev-loop smi-failure-log

# 3. Verify and start using
/help
@django-architect "Design a user authentication system"
```

Done! Agents are now available in **all your projects** automatically.

---

## Table of Contents

- [7 Available Plugins](#7-available-plugins)
- [What You Get](#what-you-get)
- [Installation Methods](#installation-methods)
- [Usage Examples](#usage-examples)
- [Conventions Enforced](#conventions-enforced)
- [Repository Structure](#repository-structure)
- [Customization](#customization)
- [Updates](#updates)
- [For Companies](#for-companies)
- [Troubleshooting](#troubleshooting)

---

## 7 Available Plugins

### 🐍 smi-django (5 agents, 3 commands, 8 skills)

Django backend development with Python

```bash
/plugin install smi-django
```

**Agents:**

- `@django-architect` - System architecture design
- `@django-builder` - Feature implementation
- `@django-feature-based` - Large-scale feature-based architecture
- `@django-tester` - Test writing (90%+ coverage target)
- `@django-reviewer` - Security and code review

**Commands:**

- `/model-create` - Create Django models with Smicolon conventions
- `/api-endpoint` - Generate complete REST API endpoints
- `/test-generate` - Generate comprehensive tests (90%+ coverage)

**Skills (Auto-Enforcing):**

- `import-convention-enforcer` - Auto-fixes to absolute modular imports
- `model-entity-validator` - Ensures UUID, timestamps, soft delete
- `security-first-validator` - Checks permissions, authentication, validation
- `test-coverage-advisor` - Suggests missing tests for 90%+ coverage
- `performance-optimizer` - Detects N+1 queries, missing indexes
- `migration-safety-checker` - Validates safe database migrations
- `test-validity-checker` - Ensures test quality
- `red-phase-verifier` - Verifies TDD red phase

### 🦅 smi-nestjs (3 agents, 1 command, 2 skills)

NestJS backend development with TypeScript

```bash
/plugin install smi-nestjs
```

**Agents:**

- `@nestjs-architect` - Backend architecture design
- `@nestjs-builder` - Feature implementation
- `@nestjs-tester` - Test writing

**Commands:**

- `/module-create` - Create complete NestJS modules

**Skills (Auto-Enforcing):**

- `barrel-export-manager` - Auto-creates and maintains index.ts exports
- `import-convention-enforcer` - Enforces absolute imports from barrel exports

### ⚛️ smi-nextjs (4 agents, 1 command, 3 skills)

Next.js frontend development with React

```bash
/plugin install smi-nextjs
```

**Agents:**

- `@nextjs-architect` - Frontend architecture
- `@nextjs-modular` - Large-scale modular architecture
- `@frontend-visual` - Visual QA (Playwright + Figma MCP)
- `@frontend-tester` - Testing (unit/integration/E2E/accessibility)

**Commands:**

- `/component-create` - Create React/Next.js components

**Skills (Auto-Enforcing):**

- `accessibility-validator` - WCAG 2.1 AA compliance
- `react-form-validator` - React Hook Form + Zod enforcement
- `import-convention-enforcer` - Path alias (@/) enforcement

### 💚 smi-nuxtjs (3 agents, 1 command, 3 skills)

Nuxt.js frontend development with Vue 3

```bash
/plugin install smi-nuxtjs
```

**Agents:**

- `@nuxtjs-architect` - Vue 3 architecture
- `@frontend-visual` - Visual QA (Playwright + Figma MCP)
- `@frontend-tester` - Testing (unit/integration/E2E/accessibility)

**Commands:**

- `/component-create` - Create Vue 3/Nuxt.js components

**Skills (Auto-Enforcing):**

- `accessibility-validator` - WCAG 2.1 AA compliance
- `veevalidate-form-validator` - VeeValidate + Zod enforcement
- `import-convention-enforcer` - ~/ path alias enforcement

### 🏗️ smi-architect (1 agent, 1 command)

System architecture and diagram-as-code

```bash
/plugin install smi-architect
```

**Agent:**

- `@system-architect` - Eraser.io diagrams (ERD, flowcharts, cloud, sequence, BPMN)

**Commands:**

- `/diagram-create` - Create system diagrams with Eraser.io

### 🔄 smi-dev-loop (2 commands, 1 hook)

Autonomous development loops for iterative coding

```bash
/plugin install smi-dev-loop
```

**Commands:**

- `/dev-loop` - Start autonomous development loop (Red-Green-Refactor)
- `/cancel-dev` - Cancel active development loop

**Hooks:**

- Automatic continuation logic for iterative development

### 🧠 smi-failure-log (2 commands, 1 skill, 2 hooks)

Persistent failure memory that prevents repeating mistakes

```bash
/plugin install smi-failure-log
```

**Commands:**

- `/failure-add` - Log a mistake to prevent repeating it
- `/failure-list` - View all logged failures

**Skills:**

- `failure-log-manager` - Knowledge for reading/writing failure logs

**Features:**

- Automatic context injection of known mistakes
- Semi-automatic failure detection on Write/Edit
- Project-specific storage in `.claude/failure-log.local.md`
- Categories: imports, security, testing, architecture, conventions

---

## What You Get

### Specialized Agents (16 total)

Each plugin includes agents specialized for that tech stack with deep knowledge of:

- Architecture patterns
- Best practices
- Testing strategies
- Security requirements
- Performance optimization

### Auto-Enforcing Skills (17 total)

Skills automatically activate based on context:

- **Import Convention Enforcers** - Auto-fix import patterns per framework
- **Model/Entity Validators** - Ensure required fields (UUID, timestamps)
- **Security Validators** - Check permissions, guards, validation
- **Form Validators** - Enforce React Hook Form/VeeValidate + Zod
- **Accessibility Validators** - WCAG 2.1 AA compliance
- **Performance Optimizers** - Detect N+1, missing indexes
- **Test Validators** - Quality checks, TDD phase verification
- **Failure Log Manager** - Persistent memory of mistakes to avoid

### Interactive Commands (11 total)

Slash commands provide step-by-step interactive workflows:

- `/model-create` - Django model generation
- `/api-endpoint` - Complete API endpoint scaffolding
- `/test-generate` - Comprehensive test generation
- `/module-create` - NestJS module scaffolding
- `/component-create` - React/Vue component creation (Next.js & Nuxt.js)
- `/diagram-create` - System diagram generation
- `/dev-loop` - Autonomous development loop
- `/cancel-dev` - Cancel development loop
- `/failure-add` - Log a mistake to avoid
- `/failure-list` - View logged failures

### Multi-Agent Workflows

Pre-built orchestration workflows in `workflows/`:

- `feature-development.md` - End-to-end feature development (6 phases)
- `code-review.md` - Comprehensive code review workflow (6 phases)

### Automatic Convention Enforcement

Hooks automatically enforce company standards:

- ✅ Import patterns (absolute imports with aliases)
- ✅ Model structure (UUID, timestamps, soft deletes)
- ✅ Type safety (strict TypeScript, Python type hints)
- ✅ Security (permissions, guards, validation)
- ✅ Testing requirements (80-90% coverage)
- ✅ Accessibility (WCAG 2.1 AA)

### Visual QA Integration

Frontend plugins integrate with:

- **Playwright MCP** - Automated browser testing
- **Figma MCP** - Design comparison and validation

See [MCP_SETUP.md](MCP_SETUP.md) for setup instructions.

---

## Installation

**Simple plugin installation:**

```bash
# Add marketplace (one-time)
/plugin marketplace add https://github.com/smicolon/claude-infra

# Install specific plugins
/plugin install smi-django
/plugin install smi-nextjs

# Or install all
/plugin install smi-django smi-nestjs smi-nextjs smi-nuxtjs smi-architect

# Update later
/plugin update smi-django
```

---

## Usage Examples

### Django Workflow

```bash
# Architecture phase
@django-architect "Design a payment processing system with subscriptions"

# Implementation phase
@django-builder "Implement the payment system with Stripe integration"

# Testing phase
@django-tester "Write tests for payment processing (90%+ coverage)"

# Review phase
@django-reviewer "Review payment code for security vulnerabilities"
```

### Next.js Workflow

```bash
# Architecture phase
@nextjs-architect "Design a dashboard with real-time analytics"

# Large-scale architecture
@nextjs-modular "Design modular architecture for e-commerce platform"

# Testing phase
@frontend-tester "Write comprehensive tests for dashboard"

# Visual QA (with Playwright + Figma MCP)
@frontend-visual "Verify dashboard matches Figma design"
```

### Full-Stack Workflow

```bash
# Backend
/plugin install smi-django
@django-architect "Design REST API for inventory management"

# Frontend
/plugin install smi-nextjs
@nextjs-architect "Design admin dashboard consuming the API"

# System design
/plugin install smi-architect
@system-architect "Create system architecture diagram showing frontend, API, and database"
```

---

## Conventions Enforced

### Django Standards

**Import Pattern:**

```python
# ✅ CORRECT - Absolute modular imports with aliases
import users.models as _users_models
import users.services as _users_services

user = _users_models.User.objects.get(id=user_id)

# ❌ WRONG
from .models import User
from users.models import User
```

**Model Pattern:**

```python
import uuid
from django.db import models

class YourModel(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_deleted = models.BooleanField(default=False)
```

**Required:**

- UUID primary keys
- Timestamps (created_at, updated_at)
- Soft deletes (is_deleted)
- Service layer for business logic
- Type hints on all functions
- Permission classes on all views

### NestJS Standards

**Import Pattern:**

```typescript
// ✅ CORRECT - Absolute imports from barrel exports
import { User } from "src/users/entities";
import { UsersService } from "src/users/services";

// ❌ WRONG
import { User } from "./entities/user.entity";
```

**Entity Pattern:**

```typescript
@Entity("users")
export class User {
  @PrimaryGeneratedColumn("uuid")
  id: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @DeleteDateColumn()
  deletedAt?: Date;
}
```

**Required:**

- UUID primary keys
- Timestamps (createdAt, updatedAt)
- Soft deletes (deletedAt)
- DTOs with class-validator
- Guards on protected routes
- Barrel exports (index.ts) in all folders

### Frontend Standards (Next.js/Nuxt.js)

**Next.js:**

- TypeScript strict mode (no `any`)
- Zod validation for all forms
- TanStack Query for API calls
- Proper error and loading states
- Tailwind CSS
- WCAG 2.1 AA accessibility

**Nuxt.js:**

- TypeScript strict mode
- Vue 3 Composition API (`<script setup lang="ts">`)
- VeeValidate + Zod for forms
- Nuxt composables (useFetch, useAsyncData)
- Pinia for state management
- WCAG 2.1 AA accessibility

---

## Repository Structure

```
claude-infra/                     # Smicolon Marketplace
├── .claude-plugin/
│   └── marketplace.json          # Single source of truth - all plugin config
├── plugins/
│   ├── smi-django/               # Django plugin (5 agents, 3 commands, 8 skills)
│   ├── smi-nestjs/               # NestJS plugin (3 agents, 1 command, 2 skills)
│   ├── smi-nextjs/               # Next.js plugin (4 agents, 1 command, 3 skills)
│   ├── smi-nuxtjs/               # Nuxt.js plugin (3 agents, 1 command, 3 skills)
│   ├── smi-architect/            # System architecture plugin (1 agent, 1 command)
│   ├── smi-dev-loop/             # Dev loop automation (2 commands, 1 hook)
│   └── smi-failure-log/          # Failure memory (2 commands, 1 skill, 2 hooks)
├── workflows/                    # Multi-agent orchestration workflows
├── scripts/                      # Development utilities
├── templates/                    # Project templates
├── MCP_SETUP.md                  # Playwright + Figma setup
└── README.md                     # This file
```

---

## Customization

### Project-Specific Rules

Create `.claude/custom/project-context.md` in your project:

````markdown
# My Project

## Tech Stack

- Django 5.0 + PostgreSQL
- Next.js 15 + TypeScript

## Custom Rules

- Use Redis for session storage
- All API endpoints require JWT
- Rate limiting: 100 requests/minute

## Environment

\```bash
python manage.py migrate
npm run dev
\```
````

### Company-Wide Customization

**For Companies:** Fork this repository to create your own standards!

1. Fork https://github.com/smicolon/claude-infra
2. Customize agents in `plugins/*/agents/`
3. Modify hooks in `plugins/*/hooks/`
4. Update plugin names and descriptions
5. Distribute to team:

```bash
# Team members install from your fork
/plugin marketplace add yourcompany https://github.com/yourcompany/claude-infra
/plugin install yourcompany-django
```

---

## Updates

```bash
# Update specific plugin
/plugin update smi-django

# Update all plugins
/plugin update smi-django smi-nestjs smi-nextjs smi-nuxtjs smi-architect smi-dev-loop smi-failure-log

# Check for updates
/plugin list
```

---

## For Companies

### Create Your Own Marketplace

1. **Fork this repository**

   ```bash
   git clone https://github.com/smicolon/claude-infra.git your-company-standards
   ```

2. **Customize**

   - Edit `plugins/*/agents/` for your conventions
   - Modify `plugins/*/hooks/` for your standards
   - Update `.claude-plugin/marketplace.json`

3. **Distribute**

   ```bash
   # Push to your GitHub
   git push origin main

   # Team installs
   /plugin marketplace add yourcompany https://github.com/yourcompany/standards
   /plugin install yourcompany-django
   ```

### Git Worktree Pattern (Multiple Features)

Work on multiple features simultaneously with separate Claude sessions:

```bash
# Main project
cd ~/projects/your-app

# Create worktrees for parallel features
git worktree add ../your-app-auth feature/authentication
git worktree add ../your-app-payments feature/payments

# Each has independent Claude session
cd ../your-app-auth
claude @django-architect

# In another terminal
cd ../your-app-payments
claude @nestjs-builder
```

---

## Troubleshooting

### Agents not appearing?

```bash
# Check plugin is installed
/plugin list

# Reinstall if needed
/plugin uninstall smi-django
/plugin install smi-django

# Verify
/help
```

### Hooks not running?

Hooks are automatic with plugin installation. If hooks aren't working:

```bash
# Reinstall the plugin
/plugin uninstall smi-django
/plugin install smi-django
```

### Need different agents?

Install additional plugins:

```bash
# Add frontend to Django project
/plugin install smi-nextjs

# Now you have Django + Next.js agents
```

---

## Documentation

- **[MCP_SETUP.md](MCP_SETUP.md)** - Playwright + Figma MCP integration setup
- **Plugin READMEs** - Each plugin has its own documentation in `plugins/*/README.md`

---

## Support

- **Issues**: [GitHub Issues](https://github.com/smicolon/claude-infra/issues)
- **Custom Marketplace**: Fork and customize

---

## License

Copyright (c) 2024-2025 Smicolon Company. All rights reserved.

This is for Internal use only.
