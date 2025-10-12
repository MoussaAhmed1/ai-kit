# Changelog

All notable changes to Smicolon Claude Code Infrastructure will be documented in this file.

## [2.1.0] - 2025-10-12

### Added

#### Commands System
- ✅ **Slash Commands** - Interactive workflows for common development tasks
- ✅ **6 Total Commands** across plugins:
  - `/model-create` - Django model creation with Smicolon conventions
  - `/api-endpoint` - Complete REST API endpoint generation (serializer, service, view, tests)
  - `/test-generate` - Comprehensive test generation (90%+ coverage target)
  - `/module-create` - NestJS module scaffolding (entity, DTOs, service, controller)
  - `/component-create` - React/Next.js component creation (UI, forms, server components)
  - `/diagram-create` - System diagram generation with Eraser.io

#### Workflows System
- ✅ **Multi-Agent Orchestration Workflows** in `workflows/` directory:
  - `feature-development.md` - End-to-end feature development (Architecture → Implementation → Testing → Review → Deployment)
  - `code-review.md` - Comprehensive code review (Conventions → Security → Performance → Testing → Quality → Documentation)

### Changed

#### Architecture Simplification
- **Simplified plugin structure** - Removed individual `plugin.json` files from each plugin
- **Single source of truth** - All plugin configuration now in `.claude-plugin/marketplace.json`
- **Cleaner directories** - Plugin folders only contain agents/, commands/, hooks/, and README.md

**Before:**
```
plugins/smi-django/
├── .claude-plugin/plugin.json  ❌ Removed
├── agents/
└── hooks/
```

**After:**
```
plugins/smi-django/
├── agents/
├── commands/                    ✅ New
└── hooks/
```

#### Enhanced Marketplace Manifest
- Added `category` field for each plugin (backend/frontend/architecture)
- Added `commands` array listing available slash commands
- Added `agents` array with file paths
- Added `license`, `homepage`, and `repository` fields for each plugin

### Benefits

#### For Users
- ✅ **Interactive commands** - Step-by-step workflows for common tasks
- ✅ **Pre-built workflows** - Multi-agent orchestration for complex features
- ✅ **Cleaner structure** - Easier to understand and navigate

#### For Maintainers
- ✅ **Single source of truth** - Update one file instead of 6
- ✅ **Better organization** - Commands separated from agents
- ✅ **Workflow documentation** - Best practices captured in reusable workflows

### Documentation

- Updated README.md with commands and workflows sections
- Updated CLAUDE.md with complete command and workflow documentation
- Updated directory structure diagrams

---

## [2.0.0] - 2025-10-12

### BREAKING CHANGE: Marketplace Architecture

Complete restructure from monolithic plugin to marketplace with individual plugins.

### Added

#### Marketplace System
- ✅ **Claude Code Marketplace** (`.claude-plugin/marketplace.json`) with 5 independent plugins
- ✅ **Plugin-per-tech-stack** architecture for granular installation
- ✅ **smi- branding** - All plugins use `smi-` prefix for clear naming

#### 5 Independent Plugins

**smi-django** (5 agents):
- @django-architect - Architecture design
- @django-builder - Feature implementation
- @django-feature-based - Large-scale architecture
- @django-tester - Testing (90%+ coverage)
- @django-reviewer - Security review

**smi-nestjs** (3 agents):
- @nestjs-architect - Backend architecture
- @nestjs-builder - Feature implementation
- @nestjs-tester - Testing

**smi-nextjs** (4 agents):
- @nextjs-architect - Frontend architecture
- @nextjs-modular - Large-scale modular architecture
- @frontend-visual - Visual QA (Playwright + Figma MCP)
- @frontend-tester - Testing (unit/integration/E2E/a11y)

**smi-nuxtjs** (3 agents):
- @nuxtjs-architect - Vue 3 architecture
- @frontend-visual - Visual QA (Playwright + Figma MCP)
- @frontend-tester - Testing

**smi-architect** (1 agent):
- @system-architect - Eraser.io diagram-as-code specialist

#### Documentation
- ✅ **QUICK_START.md** - New beginner-friendly quick start guide
- ✅ **Plugin-specific READMEs** - Each plugin has its own documentation
- ✅ **Updated all docs** - Reflects marketplace structure throughout

### Changed

#### Installation Method
- **Old**: Install monolithic plugin with all 14 agents
- **New**: Install only the plugins you need

```bash
# Before (v1.0.0)
/plugin install smicolon-standards  # All 14 agents

# Now (v2.0.0)
/plugin marketplace add smicolon https://github.com/smicolon/claude-infra
/plugin install smi-django          # Only 5 Django agents
/plugin install smi-nextjs          # Only 4 Next.js agents
```

#### Repository Structure
```
claude-infra/                        # Now a marketplace
├── .claude-plugin/
│   └── marketplace.json             # Marketplace manifest
├── plugins/                         # NEW - Individual plugins
│   ├── smi-django/
│   │   ├── .claude-plugin/
│   │   ├── agents/
│   │   ├── hooks/
│   │   └── README.md
│   ├── smi-nestjs/
│   ├── smi-nextjs/
│   ├── smi-nuxtjs/
│   └── smi-architect/
├── scripts/
│   └── install.sh                   # Legacy script installation only
├── templates/
└── README.md
```

### Removed

#### Deprecated Files
- ❌ Root `/agents/` directory (moved into plugins)
- ❌ Root `/hooks/` directory (moved into plugins)
- ❌ `.claude-plugin/plugin.json` (now marketplace.json)
- ❌ `marketplace-registry.json` (redundant)
- ❌ `scripts/package.sh` (not needed for plugin installation)
- ❌ `scripts/publish.sh` (not needed for plugin installation)
- ❌ `scripts/quick-install.sh` (not needed for plugin installation)

#### Legacy Installation Methods
- Removed tarball packaging (users install from GitHub directly)
- Removed distribution scripts (marketplace handles distribution)
- Kept `scripts/install.sh` for local development only

### Benefits

#### For Users
- ✅ **Install only what you need** - Smaller, faster installations
- ✅ **Independent versioning** - Update Django without affecting Next.js
- ✅ **Mix and match** - Use Django backend + Next.js frontend
- ✅ **Automatic updates** - Plugin system handles updates

#### For Maintainers
- ✅ **Better organization** - Self-contained plugins
- ✅ **Easier testing** - Test individual plugins
- ✅ **Clear separation** - Each tech stack is independent
- ✅ **Simpler distribution** - GitHub-native, no packaging needed

### Migration Guide

#### From v1.0.0 (Monolithic Plugin)

If you had the old plugin installed:

```bash
# Remove old plugin
/plugin uninstall smicolon-standards

# Add marketplace
/plugin marketplace add smicolon https://github.com/smicolon/claude-infra

# Install what you need
/plugin install smi-django smi-nextjs
```

#### From Script Installation

Script installation is now legacy but still supported:

```bash
# Script method still works
cd your-project
bash /path/to/claude-infra/scripts/install.sh --global
smicolon-init
```

But plugin installation is recommended for automatic updates.

### Statistics

- **5 Plugins**: Django, NestJS, Next.js, Nuxt.js, System Architecture
- **14 Total Agents**: Distributed across plugins
- **3 Hooks per backend plugin**: Pre-prompt, post-write, visual
- **4 Frameworks Supported**: Django, NestJS, Next.js, Nuxt.js
- **2 MCP Integrations**: Playwright, Figma
- **1 Diagram Tool**: Eraser.io diagram-as-code

---

## [1.0.0] - 2024-10-12

### Initial Release

First release of Smicolon Claude Code Infrastructure as a monolithic plugin.

#### Features
- 14 specialized agents for Django, NestJS, Next.js, Nuxt.js
- Automatic convention enforcement via hooks
- Visual QA with Playwright MCP
- System architecture with Eraser.io
- Plugin manifest for Claude Code

#### Installation
- Single plugin installation with all agents
- Script-based installation for legacy support
- Distribution via marketplace-registry.json

---

## Contributors

- Smicolon Development Team

## License

MIT License
