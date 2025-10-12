# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This repository provides Claude Code infrastructure for enforcing Smicolon company-wide development standards across Django, NestJS, Next.js, and Nuxt.js projects. It includes specialized agents and hooks that automatically inject conventions and validate code.

## Core Architecture

### Directory Structure

```
claude-infra/
├── .claude-plugin/       # Plugin manifest for Claude Code
├── agents/               # 14 specialized agent prompts
├── hooks/                # Pre-prompt and post-write validation hooks
├── scripts/              # Installation scripts (legacy compatibility)
├── templates/            # Project templates with pre-configured conventions
├── marketplace-registry.json  # Plugin marketplace configuration
└── .claude/              # Local Claude Code configuration (not committed)
```

### Installation Methods

**Recommended: Plugin Installation**
- Install as Claude Code plugin via `/plugin install smicolon-standards`
- Automatic updates across all projects
- Zero manual setup required
- Centralized version management

**Alternative: Script Installation (Legacy)**
- Global install: Copies to `~/.smicolon/`
- Project install: Copies/symlinks to project's `.claude/agents/` and `.claude/hooks/`
- Manual updates via `git pull`

## Installation System

### Installation System

**Plugin Installation (Recommended):**
```bash
# Add marketplace and install
/plugin marketplace add smicolon https://github.com/smicolon/claude-infra
/plugin install smicolon-standards
```

**Script Installation (Legacy):**
```bash
# Global installation
bash scripts/install.sh --global
source ~/.zshrc

# Project initialization
smicolon-init
```

### Installation Flow (Script Method)

1. Detects project type (Django/NestJS/Next.js/Nuxt.js) via file inspection
2. Copies relevant agents from `agents/` directory
3. Copies hooks from `hooks/` directory (conditional execution based on project type)
4. Creates `.claude/custom/project-context.md` with project-specific template
5. Updates `.gitignore` to exclude `.claude/custom/private/`

## Agent System

### Agent Categories (14 Total)

**Django** (5 agents):
- `@django-architect` - Architecture design
- `@django-builder` - Feature implementation
- `@django-feature-based` - Large-scale feature-based architecture
- `@django-tester` - Test writing (90%+ coverage target)
- `@django-reviewer` - Security and code review

**NestJS** (3 agents):
- `@nestjs-architect` - Backend architecture
- `@nestjs-builder` - Feature implementation
- `@nestjs-tester` - Test writing

**Frontend** (5 agents):
- `@nextjs-architect` - Next.js/React architecture
- `@nextjs-modular` - Large-scale Next.js modular architecture
- `@nuxtjs-architect` - Nuxt.js/Vue 3 architecture
- `@frontend-visual` - Visual QA with Playwright MCP + Figma MCP
- `@frontend-tester` - Frontend testing (unit, integration, E2E, accessibility)

**System Architecture** (1 agent):
- `@system-architect` - Eraser.io diagram-as-code specialist (ERD, flowcharts, cloud, sequence, BPMN)

### Agent Usage Pattern

Agents are invoked with `@agent-name` syntax in Claude Code. They enforce specific conventions for each framework through detailed prompt engineering.

## Hook System

### user-prompt-submit-hook.sh

Runs **before** Claude processes prompts. Detects project type and injects framework-specific conventions into every prompt:

**Detection Logic:**
- Django: Checks for `manage.py` or `config/settings/`
- Next.js: Checks `package.json` for `"next"`
- Nuxt.js: Checks `package.json` for `"nuxt"`
- NestJS: Checks `package.json` for `"@nestjs/core"`

**Injected Conventions Include:**
- Import patterns (absolute imports with aliases)
- Model/entity structure (UUID, timestamps, soft deletes)
- Security requirements (permissions, guards)
- Validation requirements

### post-write-hook.sh

Runs **after** Claude writes files. Validates generated code against conventions (implementation depends on framework detection).

### post-write-visual-hook.sh

Specialized hook for visual testing workflows with Playwright MCP.

## Development Standards Enforced

### Django Conventions

**Import Pattern:**
```python
# CORRECT - Absolute modular imports with aliases
import users.models as _models
import users.services as _services

# Usage
user = _models.User.objects.get(id=user_id)

# WRONG - Never use
from .models import User  # Relative import
from users.models import User  # Direct import
```

**Model Standard:**
- UUID primary keys (`id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)`)
- Timestamps (`created_at`, `updated_at`)
- Soft deletes (`is_deleted = models.BooleanField(default=False)`)
- Service layer for business logic
- Type hints required
- Permission classes on all views

### NestJS Conventions

**Import Pattern:**
```typescript
// CORRECT - Absolute imports from barrel exports
import { User } from 'src/users/entities'
import { UsersService } from 'src/users/services'
import { CreateUserDto } from 'src/users/dto'

// WRONG - Relative imports
import { User } from './entities/user.entity'
import { User } from '../entities'
```

**Entity Standard:**
- UUID primary keys (`@PrimaryGeneratedColumn('uuid')`)
- Timestamps (`@CreateDateColumn()`, `@UpdateDateColumn()`)
- Soft deletes (`@DeleteDateColumn()`)
- DTOs with class-validator
- Guards on protected routes
- Barrel exports (index.ts) in all folders

### Next.js Conventions

- TypeScript strict mode (no `any`)
- Zod validation for forms (React Hook Form + Zod)
- TanStack Query for API calls
- Proper error and loading states
- Tailwind CSS
- WCAG 2.1 AA accessibility

### Nuxt.js Conventions

- TypeScript strict mode
- Vue 3 Composition API (`<script setup lang="ts">`)
- VeeValidate + Zod for forms
- Nuxt composables (useFetch, useAsyncData)
- Pinia for state management
- WCAG 2.1 AA accessibility

## Common Commands

### Installation and Setup

**Plugin Method (Recommended):**
```bash
# Install plugin
/plugin marketplace add smicolon https://github.com/smicolon/claude-infra
/plugin install smicolon-standards

# Update plugin
/plugin update smicolon-standards
```

**Script Method (Legacy):**
```bash
# Install globally
bash scripts/install.sh --global
source ~/.zshrc  # or ~/.bashrc

# Initialize in a project
cd your-project
smicolon-init

# Update global installation
cd ~/.smicolon
git pull
```

### Project Installation (Direct)

```bash
# In a project directory
bash /path/to/claude-infra/scripts/install.sh
```

### Distribution and Publishing

```bash
# Create distribution package
bash scripts/package.sh

# Publish to production channel
bash scripts/publish.sh production

# Publish to dev channel
bash scripts/publish.sh dev
```

### Testing Installation

```bash
# Test in a Django project
cd test-django-project
bash /path/to/claude-infra/scripts/install.sh
ls .claude/agents/  # Should show django-*.md files

# Verify hooks are executable
ls -la .claude/hooks/
```

## Project Type Detection Logic

Used by `install.sh` and hooks to determine which agents and conventions to apply:

1. **Django**: `[ -f "manage.py" ] || [ -d "config/settings" ]`
2. **NestJS**: `[ -f "package.json" ] && grep -q "@nestjs/core" package.json`
3. **Next.js**: `[ -f "package.json" ] && grep -q "\"next\"" package.json`
4. **Nuxt.js**: `[ -f "package.json" ] && grep -q "nuxt" package.json`

## Distribution System

### Publishing Workflow

1. **Build**: `bash scripts/package.sh` creates `dist/smicolon-claude-{channel}-{date}.tar.gz`
2. **Publish**: `bash scripts/publish.sh {channel}` distributes via configured method
3. **Install**: Teams use `curl -fsSL {url}/quick-install.sh | bash`

### Configuration Variables

```bash
# Rsync method
export SMICOLON_PUBLISH_METHOD=rsync
export SMICOLON_PUBLISH_HOST=user@server.com
export SMICOLON_PUBLISH_PATH=/var/www/smicolon-claude

# S3 method
export SMICOLON_PUBLISH_METHOD=s3
export SMICOLON_S3_BUCKET=s3://bucket/smicolon-claude

# Local method (testing)
export SMICOLON_PUBLISH_METHOD=local
```

### Channels

- `production` - Stable releases
- `dev` - Development/testing
- `beta` - Beta testing
- Custom channels supported

## Git Worktree Pattern

Recommended workflow for multiple feature development (documented in README.md):

```bash
# Main project
cd ~/projects/your-app

# Create worktrees for parallel features
git worktree add ../your-app-feature-auth feature/authentication
git worktree add ../your-app-feature-payments feature/payments

# Each has independent .claude/ directory
cd ../your-app-feature-auth
claude @django-architect  # Separate Claude session
```

## MCP Integration (Playwright Visual Testing)

The `@frontend-visual` agent integrates with Playwright MCP server for visual testing. Configuration in `MCP_SETUP.md`:

**Setup:**
```json
// ~/.claude/mcp.json or project .claude/mcp.json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp-server"],
      "env": {}
    }
  }
}
```

**Usage:**
```bash
npm run dev  # Start dev server
claude @frontend-visual
# "Verify dashboard at /dashboard is pixel-perfect"
```

## Important Files to Understand

### Core Configuration

- `hooks/user-prompt-submit-hook.sh` - Convention injection logic (most critical)
- `scripts/install.sh` - Installation logic and project detection
- `agents/django-architect.md` - Example agent structure and conventions
- `.claude-plugin/plugin.json` - Plugin manifest for Claude Code
- `marketplace-registry.json` - Plugin marketplace configuration

### Documentation

- `README.md` - User-facing documentation
- `STRUCTURE.md` - Repository organization
- `MCP_SETUP.md` - Playwright MCP setup
- `INDEX.md` - Quick navigation

### Not Committed

- `.claude/` in repository root (local development only)
- `dist/` directory (generated packages)

## Development Workflow

### Adding New Agents

1. Create agent file in `agents/{framework}-{role}.md`
2. Follow existing agent structure (role definition, conventions, deliverables)
3. Update `.claude-plugin/plugin.json` to register the agent
4. Update `scripts/install.sh` installation logic (for script method compatibility)
5. Update README.md to document new agent
6. Test installation in sample project

### Modifying Conventions

1. Edit agent files in `agents/` directory
2. Update corresponding hook in `hooks/user-prompt-submit-hook.sh`
3. Test with sample project
4. Update README.md if visible changes
5. Increment plugin version in `.claude-plugin/plugin.json`

### Testing Changes

```bash
# Test global install
bash scripts/install.sh --global
cd /tmp/test-project
smicolon-init

# Test project install
cd /tmp/test-project
bash /path/to/claude-infra/scripts/install.sh

# Verify
ls .claude/agents/
ls .claude/hooks/
cat .claude/custom/project-context.md
```

## Troubleshooting

**Agents not appearing:**
- Check `.claude/agents/` directory exists and contains `.md` files
- Verify files are readable (`ls -la .claude/agents/`)
- Re-run `smicolon-init` or installation script

**Hooks not executing:**
- Check hooks are executable: `chmod +x .claude/hooks/*.sh`
- Verify hook syntax with `bash -n .claude/hooks/user-prompt-submit-hook.sh`
- Check project detection logic matches your project

**Wrong agents installed:**
- Check project type detection logic
- Manually reinstall with correct type: `bash scripts/install.sh`
- Select project type manually when prompted

**Global install not working:**
- Verify `~/.smicolon/` directory exists
- Check shell profile has been sourced: `source ~/.zshrc`
- Verify alias: `type smicolon-init`

## Repository Maintenance

### Archive Policy

Old/experimental code goes in `archive/` directory. Do not delete - useful for reference and understanding evolution of conventions.

### Update Propagation

- **Global installation**: Updates via symlinks (`git pull` in `~/.smicolon/`)
- **Project installation**: Requires reinstallation or manual copy

### Version Management

No formal versioning yet. Distribution channels (production/dev/beta) provide staging for updates.
