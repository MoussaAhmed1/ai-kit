# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This repository is a **Claude Code Marketplace** providing 5 independent plugins for enforcing Smicolon company-wide development standards across Django, NestJS, Next.js, Nuxt.js, and system architecture. Each plugin includes specialized agents and hooks that automatically inject conventions and validate code.

## Core Architecture

### Directory Structure

```
claude-infra/                     # Smicolon Marketplace
├── .claude-plugin/
│   └── marketplace.json          # Single source of truth - all plugin configuration
├── plugins/
│   ├── smi-django/               # Django plugin (5 agents, 3 commands)
│   │   ├── agents/               # Agent definitions
│   │   ├── commands/             # Slash commands
│   │   ├── hooks/                # Auto-injection hooks
│   │   └── README.md
│   ├── smi-nestjs/               # NestJS plugin (3 agents, 1 command)
│   ├── smi-nextjs/               # Next.js plugin (4 agents, 1 command)
│   ├── smi-nuxtjs/               # Nuxt.js plugin (3 agents, 0 commands)
│   └── smi-architect/            # System architecture plugin (1 agent, 1 command)
├── workflows/                    # Multi-agent orchestration workflows
│   ├── feature-development.md
│   └── code-review.md
├── scripts/
│   └── cleanup-plugins.sh        # Development cleanup utility
├── templates/                    # Project templates with pre-configured conventions
└── .claude/                      # Local Claude Code configuration (not committed)
```

### Installation Method

**Plugin Installation**
- Install as Claude Code plugins via marketplace
- Install only what you need (e.g., just Django or just Next.js)
- Automatic updates per plugin
- Independent versioning
- Zero manual setup required

```bash
# Add marketplace
/plugin marketplace add https://github.com/smicolon/claude-infra

# Install specific plugins
/plugin install smi-django          # Django only (5 agents)
/plugin install smi-nextjs          # Next.js only (4 agents)
/plugin install smi-architect       # System diagrams (1 agent)

# Or install all
/plugin install smi-django smi-nestjs smi-nextjs smi-nuxtjs smi-architect
```

## Agent System

### Agent Categories (14 Total Across 5 Plugins)

**smi-django Plugin** (5 agents):
- `@django-architect` - Architecture design
- `@django-builder` - Feature implementation
- `@django-feature-based` - Large-scale feature-based architecture
- `@django-tester` - Test writing (90%+ coverage target)
- `@django-reviewer` - Security and code review

**smi-nestjs Plugin** (3 agents):
- `@nestjs-architect` - Backend architecture
- `@nestjs-builder` - Feature implementation
- `@nestjs-tester` - Test writing

**smi-nextjs Plugin** (4 agents):
- `@nextjs-architect` - Next.js/React architecture
- `@nextjs-modular` - Large-scale Next.js modular architecture
- `@frontend-visual` - Visual QA with Playwright MCP + Figma MCP
- `@frontend-tester` - Frontend testing (unit, integration, E2E, accessibility)

**smi-nuxtjs Plugin** (3 agents):
- `@nuxtjs-architect` - Nuxt.js/Vue 3 architecture
- `@frontend-visual` - Visual QA with Playwright MCP + Figma MCP (shared with Next.js)
- `@frontend-tester` - Frontend testing (shared with Next.js)

**smi-architect Plugin** (1 agent):
- `@system-architect` - Eraser.io diagram-as-code specialist (ERD, flowcharts, cloud, sequence, BPMN)

### Agent Usage Pattern

Agents are invoked with `@agent-name` syntax in Claude Code. They enforce specific conventions for each framework through detailed prompt engineering. Each plugin's agents are only available when that plugin is installed.

## Command System

Each plugin includes specialized slash commands that provide interactive workflows for common development tasks.

### Command Categories

**smi-django Commands:**
- `/model-create` - Create Django models following Smicolon conventions
- `/api-endpoint` - Create complete REST API endpoints (serializer, service, view, tests)
- `/test-generate` - Generate comprehensive tests (90%+ coverage target)

**smi-nestjs Commands:**
- `/module-create` - Create complete NestJS modules (entity, DTOs, service, controller)

**smi-nextjs Commands:**
- `/component-create` - Create React/Next.js components (UI, forms, server components)

**smi-architect Commands:**
- `/diagram-create` - Create system diagrams using Eraser.io (ERD, cloud, sequence, flowcharts)

### Command Usage Pattern

Commands are invoked with `/command-name` syntax. They provide step-by-step interactive workflows:

```bash
# Create a Django model
/model-create

# Create an API endpoint
/api-endpoint

# Generate tests
/test-generate

# Create a system diagram
/diagram-create
```

## Workflow System

Multi-agent orchestration workflows that coordinate specialized agents for complex tasks.

### Available Workflows

**feature-development.md** - Complete feature development from architecture to deployment
- Phase 1: Architecture & Design
- Phase 2: Backend Implementation
- Phase 3: Frontend Implementation
- Phase 4: Testing (90%+ coverage)
- Phase 5: Code Review & Security
- Phase 6: Documentation & Deployment

**code-review.md** - Comprehensive code review workflow
- Phase 1: Convention Compliance
- Phase 2: Security Review
- Phase 3: Performance Review
- Phase 4: Testing Coverage
- Phase 5: Code Quality
- Phase 6: Documentation

### Workflow Usage Example

```bash
# Full feature development workflow
# 1. Architecture
@system-architect "Create ERD for user authentication"
@django-architect "Design auth API with JWT"

# 2. Implementation
@django-builder "Implement authentication endpoints"

# 3. Testing
@django-tester "Generate comprehensive auth tests"

# 4. Review
@django-reviewer "Security audit of authentication"

# 5. Visual verification (if frontend)
@frontend-visual "Verify login page design"
```

## Hook System

Currently, only `smi-dev-loop` includes hooks for autonomous development loops:

### smi-dev-loop Hooks

Located in `plugins/smi-dev-loop/hooks/`

- `stop-hook.sh` - Handles dev loop continuation logic

**Note:** Convention enforcement is handled by **skills** (auto-invoked based on context) and **rules** (path-specific patterns), not hooks.

## Development Standards Enforced

### Django Conventions

**Import Pattern:**
```python
# CORRECT - Absolute modular imports with aliases
import users.models as _users_models
import users.services as _users_services

# Usage
user = _users_models.User.objects.get(id=user_id)

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

```bash
# Add Smicolon marketplace
/plugin marketplace add https://github.com/smicolon/claude-infra

# Install specific plugins
/plugin install smi-django          # Django only
/plugin install smi-nextjs          # Next.js only
/plugin install smi-architect       # System architecture only

# Or install all
/plugin install smi-django smi-nestjs smi-nextjs smi-nuxtjs smi-architect

# Update plugins
/plugin update smi-django
/plugin update smi-django smi-nestjs smi-nextjs smi-nuxtjs smi-architect
```

### Testing Installation

```bash
# Test plugin installation
/plugin marketplace add https://github.com/smicolon/claude-infra
/plugin install smi-django
/help  # Should show @django-* agents
```

## Project Type Detection Logic

Used by hooks to determine which agents and conventions to apply:

1. **Django**: `[ -f "manage.py" ] || [ -d "config/settings" ]`
2. **NestJS**: `[ -f "package.json" ] && grep -q "@nestjs/core" package.json`
3. **Next.js**: `[ -f "package.json" ] && grep -q "\"next\"" package.json`
4. **Nuxt.js**: `[ -f "package.json" ] && grep -q "nuxt" package.json`

## Distribution System

The repository uses GitHub-native distribution via Claude Code's plugin system. No packaging or publishing scripts are needed:

1. **Development**: Make changes to plugins in `plugins/` directory
2. **Commit**: Commit and push changes to GitHub
3. **Distribution**: Users install/update directly from GitHub via `/plugin marketplace add` and `/plugin install`

**Benefits:**
- No build or packaging step required
- Automatic updates via Claude Code plugin system
- Independent versioning per plugin
- Git-based version control

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

- `.claude-plugin/marketplace.json` - Single source of truth for all plugin configuration
- `plugins/smi-django/skills/` - Auto-enforcing skills for convention compliance
- `plugins/smi-django/agents/django-architect.md` - Example agent structure and conventions

### Documentation

- `README.md` - Complete user-facing documentation (Quick Start, installation, usage, conventions)
- `MCP_SETUP.md` - Playwright + Figma MCP integration setup
- `plugins/*/README.md` - Plugin-specific documentation

### Not Committed

- `.claude/` in repository root (local development only)

## Development Workflow

### Adding New Agents

1. Choose the appropriate plugin (e.g., `plugins/smi-django/`)
2. Create agent file in `plugins/smi-django/agents/{role}.md`
3. Follow existing agent structure (role definition, conventions, deliverables)
4. Update `.claude-plugin/marketplace.json` to register the agent in the plugin's `agents` array
5. Update plugin's README.md to document new agent
6. Update root README.md to reflect new agent count
7. Test plugin installation in sample project

### Modifying Conventions

1. Edit agent files in `plugins/*/agents/` directory
2. Update corresponding skills in `plugins/*/skills/` directory
3. Update rules in `plugins/*/rules/` directory if path-specific
4. Test with sample project
5. Update plugin's README.md if visible changes
6. Increment plugin version in `.claude-plugin/marketplace.json`

### Creating New Plugins

1. Create `plugins/smi-{name}/` directory
2. Create `agents/` directory with agent files
3. Create `commands/` directory with command files (if needed)
4. Create `skills/` directory with auto-enforcing skills (if needed)
5. Create `rules/` directory with path-specific rules (if needed)
6. Create plugin README.md
7. Add plugin configuration to `.claude-plugin/marketplace.json` in the `plugins` array
8. Update root README.md to document the new plugin

### Testing Changes

```bash
# Test plugin installation
/plugin marketplace add https://github.com/smicolon/claude-infra
/plugin install smi-django
/help  # Verify agents appear
```

## Troubleshooting

**Agents not appearing after plugin installation:**
- Verify plugin is installed: `/plugin list`
- Check plugin installation: `/help` should show agents
- Reinstall if needed: `/plugin uninstall smi-django && /plugin install smi-django`

**Skills not activating:**
- Skills auto-invoke based on context (e.g., writing models triggers model-entity-validator)
- Check that skill is registered in `marketplace.json`
- Verify SKILL.md frontmatter has correct `name` and `description`

**Plugin installation fails:**
- Verify marketplace URL is correct: `https://github.com/smicolon/claude-infra`
- Check GitHub repository is accessible
- Try removing and re-adding marketplace

## Repository Maintenance

### Archive Policy

Old/experimental code goes in `archive/` directory. Do not delete - useful for reference and understanding evolution of conventions.

### Update Propagation

**Plugin Installation:**
- Updates via Claude Code plugin system: `/plugin update smi-django`
- Automatic version checking
- Per-plugin independent updates

### Version Management

- Each plugin has independent versioning in `.claude-plugin/marketplace.json` (in each plugin object)
- Marketplace version in `.claude-plugin/marketplace.json` (at root level)
- Semantic versioning recommended (MAJOR.MINOR.PATCH)
- Test your own work, and make sure it's working please