# Repository Structure

## Overview

This repository provides Claude Code infrastructure for enforcing Smicolon development conventions across all company projects.

## Directory Layout

```
claude-infra/
├── .claude-plugin/               # Plugin system
│   └── plugin.json               # Plugin manifest for Claude Code
│
├── marketplace-registry.json     # Plugin marketplace registry
│
├── agents/                       # Specialized agents (14 total)
│   ├── django-architect.md
│   ├── django-builder.md
│   ├── django-feature-based.md
│   ├── django-tester.md
│   ├── django-reviewer.md
│   ├── nestjs-architect.md
│   ├── nestjs-builder.md
│   ├── nestjs-tester.md
│   ├── nextjs-architect.md
│   ├── nextjs-modular.md
│   ├── nuxtjs-architect.md
│   ├── frontend-visual.md
│   ├── frontend-tester.md
│   └── system-architect.md
│
├── hooks/                        # Enforcement hooks
│   ├── user-prompt-submit-hook.sh
│   ├── post-write-hook.sh
│   └── post-write-visual-hook.sh
│
├── scripts/                      # Installation and utilities
│   └── install.sh                # Smart installer with project detection
│
├── templates/                    # Project templates
│   ├── design-system-template.md # Design system template for projects
│   ├── django-project/
│   │   ├── .claude-project.json
│   │   └── README.md
│   ├── nestjs-project/
│   │   ├── .claude-project.json
│   │   └── README.md
│   ├── nextjs-project/
│   │   └── README.md
│   └── nuxtjs-project/
│       └── README.md
│
├── .gitignore                    # Git ignore rules
├── INDEX.md                      # Quick navigation/table of contents
├── README.md                     # Main documentation
├── PLUGIN_INSTALL.md             # Plugin installation guide
├── CHANGELOG.md                  # Version history and changes
├── MCP_SETUP.md                  # MCP server setup
└── STRUCTURE.md                  # This file
```

## Key Components

### Plugin System (.claude-plugin/)

**Claude Code Plugin:**
- `plugin.json` - Manifest defining agents, hooks, and metadata
- Enables installation via `/plugin install smicolon-standards`
- Automatic updates and version management
- Centralized distribution via marketplace

**Marketplace Registry (marketplace-registry.json):**
- Central registry for plugin discovery
- Version tracking and metadata
- Enables team distribution and forking for custom standards

### Agents (agents/)

Specialized Claude agents for different tasks and tech stacks (14 total):

**Django (Python backend) - 5 agents:**
- `django-architect` - Architecture design
- `django-builder` - Feature implementation
- `django-feature-based` - Large-scale feature-based architecture
- `django-tester` - Test writing (90%+ coverage)
- `django-reviewer` - Security and code review

**NestJS (TypeScript backend) - 3 agents:**
- `nestjs-architect` - Architecture design
- `nestjs-builder` - Feature implementation
- `nestjs-tester` - Test writing

**Frontend - 5 agents:**
- `nextjs-architect` - Next.js/React architecture
- `nextjs-modular` - Large-scale Next.js modular architecture
- `nuxtjs-architect` - Nuxt.js/Vue 3 architecture
- `frontend-visual` - Visual QA with Playwright MCP + Figma MCP
- `frontend-tester` - Frontend testing (unit, integration, E2E, accessibility)

**System Architecture - 1 agent:**
- `system-architect` - Eraser.io diagram-as-code (ERD, flowcharts, cloud, sequence, BPMN)

### Hooks (hooks/)

**Pre-Prompt Hook (user-prompt-submit-hook.sh):**
- Auto-detects project type (Django, NestJS, Next.js, Nuxt.js)
- Injects framework-specific conventions before Claude processes prompts
- Enforces testing requirements for frontend projects
- Ensures conventions are always applied

**Post-Write Hook (post-write-hook.sh):**
- Validates generated code against conventions
- Checks import patterns, model structure, security requirements
- Flags violations immediately with fix suggestions

**Post-Write Visual Hook (post-write-visual-hook.sh):**
- Validates visual/frontend code changes
- Checks design system adherence
- Ensures accessibility standards

### Installation (scripts/install.sh)

Smart installer that:
- Detects project type automatically
- Installs only relevant agents
- Supports global or project-specific installation
- Creates symlinks for easy updates

### Templates (templates/)

Pre-configured project templates with:
- Smicolon conventions built-in
- Example patterns and structures
- README documentation

## File Organization

### Documentation Files

- `README.md` - Primary documentation (installation, usage, conventions)
- `PLUGIN_INSTALL.md` - Plugin installation guide and marketplace setup
- `INDEX.md` - Navigation and quick reference
- `STRUCTURE.md` - This file, repository organization
- `CHANGELOG.md` - Version history and feature additions
- `MCP_SETUP.md` - Playwright + Figma MCP server setup
- `templates/*/README.md` - Template-specific documentation
- `templates/design-system-template.md` - Design system template for projects
- `archive/README.md` - Archive documentation

### Configuration Files

- `.gitignore` - Git ignore rules
- `templates/*/.claude-project.json` - Project-specific Claude configuration

### Executable Files

- `scripts/install.sh` - Installation script
- `.claude/hooks/*.sh` - Hook scripts (must be executable)

## Installation Behavior

### Global Installation

Creates `~/.smicolon/` containing:
```
~/.smicolon/
├── agents/          # Copied from repo's agents/ directory
├── hooks/           # Copied from repo's hooks/ directory
└── scripts/
    └── init-project.sh
```

### Project Installation

Creates `.claude/` in project:
```
your-project/.claude/
├── agents/          # Symlinked (global) or copied (project)
├── hooks/           # Symlinked (global) or copied (project)
└── custom/          # Project-specific configuration
    └── project-context.md
```

## Maintenance

### Adding New Agents

1. Create agent file in `agents/` directory
2. Follow naming convention: `{stack}-{role}.md`
3. Update `.claude-plugin/plugin.json` to register the agent
4. Update `scripts/install.sh` installer (for script method compatibility)
5. Add to README.md documentation

### Updating Conventions

Global installation:
```bash
cd ~/.smicolon
git pull  # Updates all projects via symlinks
```

Project installation:
```bash
cd your-project
bash /path/to/scripts/install.sh  # Reinstall
```

### Archive Management

Old code lives in `archive/`. Do not delete - useful for reference and history.

## Distribution

Repository can be distributed via:
1. **Claude Code Plugin (Recommended)** - Install via `/plugin install smicolon-standards`
2. **Plugin Marketplace** - Custom marketplace for team distribution
3. Internal git repository
4. Tar/zip packages
5. Network share
6. NPM package (custom)

See README.md and PLUGIN_INSTALL.md for distribution details.

## Installation Methods

### Plugin Installation (Recommended)

```bash
# Add marketplace
/plugin marketplace add smicolon https://github.com/smicolon/claude-infra

# Install plugin
/plugin install smicolon-standards

# Agents immediately available in all projects
```

Benefits:
- Zero manual setup
- Automatic updates
- Centralized version management
- Easy team distribution

### Script Installation (Alternative)

```bash
# Global installation
bash scripts/install.sh --global
source ~/.zshrc

# Project installation
cd your-project
smicolon-init
```

Benefits:
- Works without plugin system
- Backwards compatible
- Full control over installation location
