# Changelog

## [1.0.0] - 2024-10-12

### Major Changes: Claude Code Plugin System

This repository has been restructured as a complete Claude Code plugin with marketplace support.

### Added

#### Plugin System
- ✅ **Plugin manifest** (`.claude-plugin/plugin.json`) for Claude Code integration
- ✅ **Marketplace registry** (`marketplace-registry.json`) for centralized distribution
- ✅ **YAML frontmatter** on all 14 agent files for proper sub-agent support
- ✅ **Direct plugin structure** - Agents and hooks at root level for clean plugin architecture
- ✅ **PLUGIN_INSTALL.md** - Complete plugin installation guide

#### Frontend Testing
- ✅ **@frontend-tester agent** - Comprehensive testing for Next.js and Nuxt.js
  - Unit tests (components, hooks, utilities)
  - Integration tests (forms, API calls)
  - E2E tests (Playwright)
  - Accessibility tests (axe-core)
  - 80%+ coverage requirements

#### System Architecture
- ✅ **@system-architect agent** - Eraser.io diagram-as-code specialist
  - Entity Relationship Diagrams (ERD) for data models
  - Flowcharts for process flows and logic
  - Cloud architecture diagrams (AWS, GCP, Azure)
  - Sequence diagrams for API interactions
  - BPMN/Swimlane diagrams for business processes
  - Complete syntax coverage with examples

#### Frontend Visual QA Improvements
- ✅ **Figma MCP integration** - Extract design tokens directly from Figma
- ✅ **Project-adaptive design systems** - No hardcoded colors/spacing
- ✅ **Design system detection** - Reads from `.claude/custom/design-system.md` or `tailwind.config.js`
- ✅ **Multi-project support** - Works with different design systems per project
- ✅ **Design system template** (`templates/design-system-template.md`)

#### MCP Setup
- ✅ **Updated MCP_SETUP.md** with Figma Dev Mode MCP instructions
- ✅ **Simplified installation** using `claude mcp add` commands
- ✅ **Figma Desktop setup guide** with all requirements

#### Testing Standards
- ✅ **Pre-prompt hooks updated** - Now inject testing requirements for frontend projects
- ✅ **Next.js**: Requires 80%+ coverage with unit/integration/E2E tests
- ✅ **Nuxt.js**: Requires 80%+ coverage with unit/integration/E2E tests

### Changed

#### All Agent Files
- ✅ **Added YAML frontmatter** with `name`, `description`, and `model` fields
- ✅ **Removed `tools` frontmatter** - Agents now have access to all tools
- ✅ **Proper sub-agent format** - Compatible with Claude Code `/agent` command

#### Documentation
- ✅ **README.md** - Added plugin installation as recommended method
- ✅ **INDEX.md** - Updated quick start with plugin commands
- ✅ **STRUCTURE.md** - Remains documenting repository organization

### Repository Structure

```
claude-infra/
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest
├── marketplace-registry.json     # Marketplace registry
├── agents/                      # 14 agents (with YAML frontmatter)
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
│   ├── frontend-visual.md       # Updated with Figma MCP
│   ├── frontend-tester.md       # NEW
│   └── system-architect.md      # NEW
└── hooks/                       # 3 hooks
    ├── user-prompt-submit-hook.sh
    ├── post-write-hook.sh
    └── post-write-visual-hook.sh
├── scripts/                     # Installation scripts (backwards compatible)
├── templates/
│   ├── design-system-template.md  # NEW
│   ├── django-project/
│   ├── nestjs-project/
│   ├── nextjs-project/
│   └── nuxtjs-project/
└── docs/
    ├── README.md
    ├── PLUGIN_INSTALL.md        # NEW
    ├── MCP_SETUP.md            # Updated
    ├── STRUCTURE.md
    └── INDEX.md

```

## Installation Methods

### Plugin Installation (Recommended)

```bash
/plugin marketplace add smicolon-marketplace https://github.com/smicolon/claude-infra
/plugin install smicolon-standards
```

### Script Installation (Backwards Compatible)

```bash
bash scripts/install.sh --global
source ~/.zshrc
cd your-project && smicolon-init
```

## Backwards Compatibility

✅ **All existing installation methods still work**
- Script-based global installation
- Script-based project installation
- Manual symlink creation
- Distribution via tarball

## For Companies

Companies can now:
1. **Fork this repository** to create company-specific standards
2. **Customize** agents, hooks, and conventions
3. **Host** their own plugin marketplace
4. **Distribute** to team via Claude Code plugin system

See "Creating Your Own Marketplace" in [PLUGIN_INSTALL.md](PLUGIN_INSTALL.md).

## Breaking Changes

None - all existing installations continue to work.

## Migration Guide

### From Script Installation to Plugin

If you used script installation previously:

```bash
# Optional: Remove old installation (if desired)
rm -rf ~/.smicolon
# Remove from shell profile if added

# Install as plugin
/plugin marketplace add smicolon-marketplace https://github.com/smicolon/claude-infra
/plugin install smicolon-standards
```

Agents and hooks work identically in both methods.

## Statistics

- **14 Agents**: Django (5), NestJS (3), Frontend (5), System Architecture (1)
- **3 Hooks**: Pre-prompt, post-write, visual
- **4 Frameworks Supported**: Django, NestJS, Next.js, Nuxt.js
- **2 MCP Servers**: Playwright, Figma
- **1 Diagram Tool**: Eraser.io diagram-as-code
- **Coverage Targets**: 90% (Django/NestJS), 80% (Frontend)

## Contributors

- Smicolon Development Team

## License

MIT License
