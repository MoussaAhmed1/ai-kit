# Smicolon Claude Code Infrastructure

## Documentation

- **[QUICK_START.md](QUICK_START.md)** - ⚡ Quick start guide (start here!)
- **[README.md](README.md)** - Complete documentation (installation, usage, conventions)
- **[PLUGIN_INSTALL.md](PLUGIN_INSTALL.md)** - Plugin installation guide (recommended)
- **[STRUCTURE.md](STRUCTURE.md)** - Repository organization and file layout
- **[MCP_SETUP.md](MCP_SETUP.md)** - Playwright + Figma MCP setup for visual testing
- **[templates/](templates/)** - Project templates with pre-configured conventions

## Quick Start

### Plugin Installation (Recommended)

```bash
# Install as Claude Code plugin
/plugin marketplace add smicolon https://github.com/smicolon/claude-infra
/plugin install smicolon-standards

# Verify installation
/help

# Start using
@django-architect
# Agents are immediately available in any project!
```

### Script Installation (Alternative)

```bash
# Install globally
bash scripts/install.sh --global
source ~/.zshrc

# Initialize in your project
cd your-project
smicolon-init

# Start using
claude
@django-architect
```

## Repository Structure

```
claude-infra/
├── .claude-plugin/
│   └── plugin.json            # Plugin manifest
├── marketplace-registry.json  # Plugin marketplace
├── agents/                    # 14 specialized agents
├── hooks/                     # Convention enforcement hooks
├── scripts/
│   └── install.sh             # Smart installer
├── templates/                 # Project templates
│   ├── django-project/
│   ├── nestjs-project/
│   ├── nextjs-project/
│   └── nuxtjs-project/
├── README.md                  # Main documentation
├── PLUGIN_INSTALL.md          # Plugin installation guide
├── STRUCTURE.md               # Detailed organization
└── INDEX.md                   # This file
```

## Available Agents

### Django (Python Backend)
- `@django-architect` - System architecture design
- `@django-builder` - Feature implementation
- `@django-feature-based` - Large-scale architecture
- `@django-tester` - Test writing (90%+ coverage)
- `@django-reviewer` - Security and code review

### NestJS (TypeScript Backend)
- `@nestjs-architect` - Backend architecture
- `@nestjs-builder` - Feature implementation
- `@nestjs-tester` - Test writing

### Frontend
- `@nextjs-architect` - Next.js/React architecture
- `@nextjs-modular` - Large-scale Next.js modular architecture
- `@nuxtjs-architect` - Nuxt.js/Vue 3 architecture
- `@frontend-visual` - Visual QA and pixel-perfect implementation (Playwright MCP + Figma MCP)
- `@frontend-tester` - Frontend testing specialist (unit, integration, E2E, accessibility)

### System Architecture
- `@system-architect` - Eraser.io diagram-as-code specialist (ERD, flowcharts, cloud architecture, sequence diagrams, BPMN)

## Support

- **Documentation**: README.md and STRUCTURE.md
- **Templates**: See templates/ directory
- **Issues**: Create issues in repository
- **Updates**: `git pull` (global installation)
