# Smicolon Claude Code Infrastructure

**Company-wide development standards enforcement via Claude Code marketplace.**

5 independent plugins for Django, NestJS, Next.js, Nuxt.js, and system architecture.

---

## Quick Start (2 minutes)

```bash
# 1. Add Smicolon marketplace
/plugin marketplace add smicolon https://github.com/smicolon/claude-infra

# 2. Install plugins for your tech stack
/plugin install smi-django          # Django (5 agents)
/plugin install smi-nextjs          # Next.js (4 agents)
/plugin install smi-architect       # System diagrams (1 agent)

# Or install everything
/plugin install smi-django smi-nestjs smi-nextjs smi-nuxtjs smi-architect

# 3. Verify and start using
/help
@django-architect "Design a user authentication system"
```

Done! Agents are now available in **all your projects** automatically.

---

## Table of Contents

- [5 Available Plugins](#5-available-plugins)
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

## 5 Available Plugins

### 🐍 smi-django (5 agents)
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

### 🦅 smi-nestjs (3 agents)
NestJS backend development with TypeScript

```bash
/plugin install smi-nestjs
```

**Agents:**
- `@nestjs-architect` - Backend architecture design
- `@nestjs-builder` - Feature implementation
- `@nestjs-tester` - Test writing

### ⚛️ smi-nextjs (4 agents)
Next.js frontend development with React

```bash
/plugin install smi-nextjs
```

**Agents:**
- `@nextjs-architect` - Frontend architecture
- `@nextjs-modular` - Large-scale modular architecture
- `@frontend-visual` - Visual QA (Playwright + Figma MCP)
- `@frontend-tester` - Testing (unit/integration/E2E/accessibility)

### 💚 smi-nuxtjs (3 agents)
Nuxt.js frontend development with Vue 3

```bash
/plugin install smi-nuxtjs
```

**Agents:**
- `@nuxtjs-architect` - Vue 3 architecture
- `@frontend-visual` - Visual QA (Playwright + Figma MCP)
- `@frontend-tester` - Testing (unit/integration/E2E/accessibility)

### 🏗️ smi-architect (1 agent)
System architecture and diagram-as-code

```bash
/plugin install smi-architect
```

**Agent:**
- `@system-architect` - Eraser.io diagrams (ERD, flowcharts, cloud, sequence, BPMN)

---

## What You Get

### Specialized Agents (14 total)

Each plugin includes agents specialized for that tech stack with deep knowledge of:
- Architecture patterns
- Best practices
- Testing strategies
- Security requirements
- Performance optimization

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

## Installation Methods

### Method 1: Plugin Installation (Recommended)

**Benefits:** Install only what you need, automatic updates, independent versioning

```bash
# Add marketplace (one-time)
/plugin marketplace add smicolon https://github.com/smicolon/claude-infra

# Install specific plugins
/plugin install smi-django
/plugin install smi-nextjs

# Or install all
/plugin install smi-django smi-nestjs smi-nextjs smi-nuxtjs smi-architect

# Update later
/plugin update smi-django
```

### Method 2: Script Installation (Legacy)

**Use for:** Local development and testing only

```bash
# Clone repository
git clone https://github.com/smicolon/claude-infra.git
cd claude-infra

# Global installation
bash scripts/install.sh --global
source ~/.zshrc

# Initialize in a project
cd your-project
smicolon-init
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
import users.models as _models
import users.services as _services

user = _models.User.objects.get(id=user_id)

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
import { User } from 'src/users/entities'
import { UsersService } from 'src/users/services'

// ❌ WRONG
import { User } from './entities/user.entity'
```

**Entity Pattern:**
```typescript
@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string

  @CreateDateColumn()
  createdAt: Date

  @UpdateDateColumn()
  updatedAt: Date

  @DeleteDateColumn()
  deletedAt?: Date
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
│   └── marketplace.json          # Lists all 5 plugins
├── plugins/
│   ├── smi-django/               # Django plugin
│   │   ├── .claude-plugin/plugin.json
│   │   ├── agents/              # 5 agents
│   │   ├── hooks/               # 3 hooks
│   │   └── README.md
│   ├── smi-nestjs/               # NestJS plugin
│   ├── smi-nextjs/               # Next.js plugin
│   ├── smi-nuxtjs/               # Nuxt.js plugin
│   └── smi-architect/            # System architecture plugin
├── scripts/
│   └── install.sh                # Legacy script installation
├── templates/                    # Project templates
├── CHANGELOG.md                  # Version history
├── MCP_SETUP.md                  # Playwright + Figma setup
└── README.md                     # This file
```

---

## Customization

### Project-Specific Rules

Create `.claude/custom/project-context.md` in your project:

```markdown
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
```

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

### Plugin Installation

```bash
# Update specific plugin
/plugin update smi-django

# Update all plugins
/plugin update smi-django smi-nestjs smi-nextjs smi-nuxtjs smi-architect

# Check for updates
/plugin list
```

### Script Installation

```bash
# Update global installation
cd ~/.smicolon
git pull

# Changes propagate automatically via symlinks
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

```bash
# Plugin installation: Hooks are automatic
# Script installation: Make executable
chmod +x .claude/hooks/*.sh
```

### Wrong project type detected?

Script installation only - re-run installer:
```bash
bash /path/to/claude-infra/scripts/install.sh
# Manually select project type
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

- **[CHANGELOG.md](CHANGELOG.md)** - Version history and breaking changes
- **[MCP_SETUP.md](MCP_SETUP.md)** - Playwright + Figma MCP integration setup
- **Plugin READMEs** - Each plugin has its own documentation in `plugins/*/README.md`

---

## Support

- **Issues**: [GitHub Issues](https://github.com/smicolon/claude-infra/issues)
- **Updates**: See [CHANGELOG.md](CHANGELOG.md)
- **Custom Marketplace**: Fork and customize

---

## License

MIT License - Internal use by Smicolon Company
