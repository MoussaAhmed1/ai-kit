# Smicolon Claude Code Infrastructure

Company-wide development standards enforcement for Claude Code.

**📚 New here? Start with the [Quick Start Guide →](QUICK_START.md)**

## Overview

This repository provides Claude Code agents and hooks that automatically enforce Smicolon development conventions across all projects. The system:

- Auto-detects project types (Django, NestJS, Next.js, Nuxt.js)
- Injects company conventions into every Claude interaction
- Validates code after generation
- Provides specialized agents for different tasks
- **Available as a Claude Code plugin** or traditional installation

## Installation

### 🎉 Recommended: Plugin Installation

Install as a Claude Code plugin for automatic updates and easy management:

```bash
# Add the Smicolon marketplace (one-time setup)
/plugin marketplace add smicolon-marketplace https://github.com/smicolon/claude-infra

# Install the plugin
/plugin install smicolon-standards

# Verify - agents are immediately available!
/help
```

**Benefits:**
- ✅ Automatic updates across all projects
- ✅ Zero manual setup
- ✅ Centralized version management
- ✅ Easy team distribution via marketplace
- ✅ Plugin discovery through registry

See [PLUGIN_INSTALL.md](PLUGIN_INSTALL.md) for complete plugin installation guide.

**For Companies:** Fork this repository to create your own company-specific marketplace! See the "Creating Your Own Marketplace" section in [PLUGIN_INSTALL.md](PLUGIN_INSTALL.md).

---

### Alternative: Script-Based Installation

### Global Installation

Install once, use everywhere:

```bash
# Clone the repository (if you haven't already)
git clone https://github.com/smicolon/claude-infra.git
cd claude-infra

# Run global installation
bash scripts/install.sh --global
source ~/.zshrc  # or ~/.bashrc
```

This creates `~/.smicolon/` with all agents and hooks.

### Project Installation

Initialize Smicolon conventions in a project:

```bash
cd your-project
smicolon-init
```

For auto-detected projects, this installs only relevant agents. Manual selection available for non-standard setups.

## Usage

### Available Agents

**Django** (Python backend):
- `@django-architect` - System design and architecture
- `@django-builder` - Feature implementation
- `@django-feature-based` - Large-scale feature-based architecture
- `@django-tester` - Test writing (90%+ coverage target)
- `@django-reviewer` - Security and code review

**NestJS** (TypeScript backend):
- `@nestjs-architect` - Backend architecture design
- `@nestjs-builder` - Feature implementation
- `@nestjs-tester` - Test writing

**Frontend**:
- `@nextjs-architect` - Next.js/React architecture
- `@nextjs-modular` - Large-scale Next.js modular architecture
- `@nuxtjs-architect` - Nuxt.js/Vue 3 architecture
- `@frontend-visual` - Visual QA and pixel-perfect implementation (Playwright MCP + Figma MCP)
- `@frontend-tester` - Frontend testing specialist (unit, integration, E2E, accessibility)

**System Architecture**:
- `@system-architect` - Eraser.io diagram-as-code specialist (ERD, flowcharts, cloud architecture, sequence diagrams, BPMN)

### Basic Workflow

**Backend (Django/NestJS):**
```bash
# Design phase
@django-architect
# Prompt: "Design a payment processing system"

# Implementation phase
@django-builder
# Prompt: "Implement the payment system"

# Testing phase
@django-tester
# Prompt: "Write tests for payment processing"

# Review phase
@django-reviewer
# Prompt: "Review payment code for security issues"
```

**Frontend (Next.js/Nuxt.js):**
```bash
# Architecture phase
@nextjs-architect
# Prompt: "Design authentication flow UI"

# Implementation phase
# Implement components...

# Testing phase
@frontend-tester
# Prompt: "Write comprehensive tests for authentication flow"
# Agent writes unit, integration, and E2E tests

# Visual QA phase (Playwright MCP + Figma MCP)
@frontend-visual
# Prompt: "Verify login form matches Figma design"
# Agent uses Figma MCP to extract design and Playwright to verify
```

**System Architecture:**
```bash
# Create diagrams for documentation
@system-architect
# Prompt: "Create an ERD for our e-commerce database"
# Prompt: "Design a cloud architecture diagram for our AWS infrastructure"
# Prompt: "Create a sequence diagram for the checkout flow"
```

## Conventions Enforced

### Django

**Import Pattern:**
```python
# Correct
import users.models as _models
import users.services as _services

# Usage
user = _models.User.objects.get(id=user_id)

# Incorrect (caught by hooks)
from .models import User
from ..services import UserService
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

**Required Standards:**
- Absolute modular imports with aliases
- UUID primary keys
- Timestamps (created_at, updated_at)
- Soft deletes (is_deleted)
- Service layer for business logic
- Type hints on all functions
- Permission classes on all views

### NestJS

**Import Pattern:**
```typescript
// Correct - absolute imports from barrel exports
import { User } from 'src/users/entities'
import { UsersService } from 'src/users/services'
import { CreateUserDto } from 'src/users/dto'

// Incorrect
import { User } from './entities/user.entity'
import { User } from '../entities'
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

**Required Standards:**
- Absolute imports from barrel exports (index.ts)
- UUID primary keys
- Timestamps (createdAt, updatedAt)
- Soft deletes (deletedAt)
- DTOs with class-validator
- Dependency injection
- Guards on protected routes

### Next.js

**Required Standards:**
- TypeScript strict mode (no `any`)
- Zod validation for all forms
- TanStack Query for API calls
- Proper error and loading states
- Tailwind CSS
- WCAG 2.1 AA accessibility

### Nuxt.js

**Required Standards:**
- TypeScript strict mode
- Vue 3 Composition API (`<script setup lang="ts">`)
- VeeValidate + Zod for forms
- Nuxt composables (useFetch, useAsyncData)
- Pinia for state management
- WCAG 2.1 AA accessibility

## Hooks

### Pre-Prompt Hook

Runs before Claude processes prompts. Detects project type and injects appropriate conventions.

### Post-Write Hook

Runs after Claude writes files. Validates:
- Import patterns
- Model/entity structure
- Required fields (UUID, timestamps, soft deletes)
- Security requirements (guards, permissions)

Violations are flagged immediately with fix suggestions.

## Directory Structure

Repository structure:

```
claude-infra/
├── .claude-plugin/       # Plugin manifest
├── agents/               # 14 specialized agents
├── hooks/                # Enforcement hooks
├── scripts/
│   └── install.sh        # Smart installer (backwards compatibility)
├── templates/            # Project templates
│   ├── django-project/
│   ├── nestjs-project/
│   ├── nextjs-project/
│   └── nuxtjs-project/
└── marketplace-registry.json
```

After global installation (legacy `~/.smicolon/`):

```
~/.smicolon/
├── agents/
├── hooks/
└── scripts/
    └── init-project.sh
```

After project initialization (`.claude/` in your project):

```
your-project/
├── .claude/              # Created by installer (Claude Code reads this)
│   ├── agents/          # Symlinked to ~/.smicolon/agents/
│   ├── hooks/           # Symlinked to ~/.smicolon/hooks/
│   └── custom/          # Project-specific configuration
│       └── project-context.md
```

## Updates

### Global Installation Updates

```bash
cd ~/.smicolon
git pull
```

Changes propagate immediately to all projects via symlinks.

### Project Installation Updates

Re-run the installer to get the latest version:

```bash
cd your-project

# If you have the repo cloned locally
bash /path/to/claude-infra/scripts/install.sh

# Or use the quick installer to get the latest
curl -fsSL https://your-cdn.com/smicolon-claude/production/quick-install.sh | bash --project
```

## Customization

### Project-Specific Rules

Edit `.claude/custom/project-context.md`:

```markdown
# Project Name

## Tech Stack
- List your stack

## Custom Rules
- Project-specific conventions
- API requirements
- Security policies
```

### Company-Wide Conventions

For plugin installation: Fork and modify the repository, then distribute via your own marketplace.

For script installation: Edit agents in `~/.smicolon/agents/` (global install) or `.claude/agents/` (project install).

## Best Practices

### Working on Multiple Features Simultaneously

Use git worktrees to work on multiple features in parallel with separate Claude sessions:

```bash
# In your project directory
cd ~/projects/your-app

# Create worktrees for different features
git worktree add ../your-app-feature-auth feature/authentication
git worktree add ../your-app-feature-payments feature/payments
git worktree add ../your-app-bugfix bugfix/user-validation

# Each worktree has its own .claude/ with full agent access
cd ../your-app-feature-auth
claude  # Start Claude session for auth feature

# In another terminal
cd ../your-app-feature-payments
claude  # Start Claude session for payments feature
```

This allows:
- Multiple Claude sessions on different features without conflicts
- Independent agent interactions per feature
- Parallel development without switching branches
- Each worktree maintains its own file state

List and manage worktrees:
```bash
git worktree list
git worktree remove ../your-app-feature-auth
```

## Distribution

### Publishing

Configure publishing method:

```bash
# For rsync to server
export SMICOLON_PUBLISH_METHOD=rsync
export SMICOLON_PUBLISH_HOST=user@your-server.com
export SMICOLON_PUBLISH_PATH=/var/www/smicolon-claude

# For AWS S3
export SMICOLON_PUBLISH_METHOD=s3
export SMICOLON_S3_BUCKET=s3://your-bucket/smicolon-claude

# For local testing
export SMICOLON_PUBLISH_METHOD=local
```

Build and publish:

```bash
# Build package
bash scripts/package.sh

# Publish to channel
bash scripts/publish.sh production  # or dev, beta, etc.
```

### Team Installation

Update `PACKAGE_BASE_URL` in `scripts/quick-install.sh`, then team installs with:

```bash
# Production channel (stable)
curl -fsSL https://your-cdn.com/smicolon-claude/production/quick-install.sh | bash

# Development channel (latest features)
SMICOLON_CHANNEL=dev curl -fsSL https://your-cdn.com/smicolon-claude/dev/quick-install.sh | bash
```

After installation, initialize in any project:
```bash
cd your-project
smicolon-init
```

## Troubleshooting

**Agents not found:**
```bash
ls .claude/agents/
# If empty, run:
smicolon-init
```

**Hooks not running:**
```bash
chmod +x .claude/hooks/*.sh
```

**Conventions not enforced:**
Verify project type detection worked:
```bash
cat .claude/custom/project-context.md
```

**Need different agents:**
Re-run installer and select different project type:
```bash
bash /path/to/claude-infra/scripts/install.sh
```

## Support

- Documentation: This file and agent files in `.claude/agents/`
- Issues: Create issues in the repository
- Updates:
  - Plugin install: `/plugin update smicolon-standards`
  - Script install: `cd ~/.smicolon && git pull`

## License

Internal use - Smicolon Company
