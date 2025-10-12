# Quick Start Guide

Get started with Smicolon Claude Code Infrastructure in under 2 minutes!

## Choose Your Installation Method

### 🎉 Method 1: Plugin Installation (Recommended)

**Fastest and easiest - zero configuration required!**

```bash
# Step 1: Add the Smicolon marketplace
/plugin marketplace add smicolon https://github.com/smicolon/claude-infra

# Step 2: Install plugins for your tech stack
/plugin install smi-django        # Django backend (5 agents)
/plugin install smi-nextjs        # Next.js frontend (4 agents)
/plugin install smi-architect        # System architecture (1 agent)

# Step 3: Verify installation
/help
```

That's it! Only the agents you need are now available in ALL your projects automatically.

**Start using immediately:**
```bash
# In any project directory
claude

# Try an agent (from installed plugins)
@django-architect "Design a user authentication system"
@nextjs-architect "Design a dashboard layout"
@system-architect "Create an ERD for our database"
```

**Want everything?** Install all plugins:
```bash
/plugin install smi-django smi-nestjs smi-nextjs smi-nuxtjs smi-architect
```

---

### 🔧 Method 2: Script Installation (Legacy)

**For teams that prefer traditional installation or need custom configurations.**

#### Global Installation (One-time setup)

```bash
# Step 1: Clone the repository
git clone https://github.com/smicolon/claude-infra.git
cd claude-infra

# Step 2: Run global installation
bash scripts/install.sh --global

# Step 3: Reload your shell
source ~/.zshrc  # or ~/.bashrc for bash users
```

#### Project Initialization

```bash
# Navigate to your project
cd ~/projects/your-django-app

# Initialize Smicolon standards
smicolon-init
```

The installer will:
- ✅ Auto-detect your project type (Django/NestJS/Next.js/Nuxt.js)
- ✅ Install relevant agents only
- ✅ Set up hooks for automatic convention enforcement
- ✅ Create project-specific configuration

---

## What You Get

### 5 Independent Plugins with 14 Agents Total

**smi-django** (5 agents):
- `@django-architect` - System architecture
- `@django-builder` - Feature implementation
- `@django-feature-based` - Large-scale architecture
- `@django-tester` - Testing (90%+ coverage)
- `@django-reviewer` - Security review

**smi-nestjs** (3 agents):
- `@nestjs-architect` - Backend architecture
- `@nestjs-builder` - Feature implementation
- `@nestjs-tester` - Testing

**smi-nextjs** (4 agents):
- `@nextjs-architect` - Frontend architecture
- `@nextjs-modular` - Large-scale modular architecture
- `@frontend-visual` - Visual QA (Playwright + Figma)
- `@frontend-tester` - Testing (unit/integration/E2E/a11y)

**smi-nuxtjs** (3 agents):
- `@nuxtjs-architect` - Vue 3 architecture
- `@frontend-visual` - Visual QA (Playwright + Figma)
- `@frontend-tester` - Testing

**smi-architect** (1 agent):
- `@system-architect` - Eraser.io diagrams (ERD, flowcharts, cloud, sequence, BPMN)

### Automatic Convention Enforcement

The hooks automatically enforce:

**Django:**
- Absolute modular imports with aliases (`import users.models as _models`)
- UUID primary keys
- Timestamps (created_at, updated_at)
- Soft deletes (is_deleted)
- Type hints required
- Permission classes on all views

**NestJS:**
- Absolute imports from barrel exports
- UUID primary keys
- Timestamps (createdAt, updatedAt)
- Soft deletes (deletedAt)
- DTOs with class-validator
- Guards on protected routes

**Frontend (Next.js/Nuxt.js):**
- TypeScript strict mode (no `any`)
- Zod validation for forms
- TanStack Query/Nuxt composables for API calls
- WCAG 2.1 AA accessibility
- Proper error and loading states

---

## Basic Workflow Examples

### Django Project

```bash
# 1. Architecture phase
@django-architect
> "Design a payment processing system with subscriptions"

# 2. Implementation phase
@django-builder
> "Implement the payment system"

# 3. Testing phase
@django-tester
> "Write comprehensive tests for payment processing"

# 4. Review phase
@django-reviewer
> "Review the payment code for security issues"
```

### Next.js Project

```bash
# 1. Architecture phase
@nextjs-architect
> "Design an authentication flow with social login"

# 2. Implementation phase
# (Implement using Claude or your preferred method)

# 3. Testing phase
@frontend-tester
> "Write unit, integration, and E2E tests for auth flow"

# 4. Visual QA phase (with Figma design)
@frontend-visual
> "Verify login form matches Figma design: https://figma.com/file/..."
```

### System Architecture

```bash
@system-architect
> "Create an ERD for our e-commerce database"
> "Design a cloud architecture diagram for AWS infrastructure"
> "Create a sequence diagram for the checkout flow"
```

---

## Verification

### Check Installed Agents

```bash
# Plugin installation
/plugin list

# Script installation
ls ~/.smicolon/agents/

# Project installation
ls .claude/agents/
```

### Test an Agent

```bash
cd ~/projects/your-app
claude

# Django projects
@django-architect "Design a blog system"

# NestJS projects
@nestjs-architect "Design a REST API for inventory management"

# Next.js projects
@nextjs-architect "Design a dashboard with analytics"
```

---

## Updating

### Plugin Installation

```bash
# Update to latest version
/plugin update smicolon-standards

# Check version
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

## Next Steps

1. **Customize for your project**: Edit `.claude/custom/project-context.md` to add project-specific rules
2. **Set up MCP servers**: See [MCP_SETUP.md](MCP_SETUP.md) for Playwright + Figma integration
3. **Explore agents**: Try different agents to see how they enforce conventions
4. **Read full docs**: See [README.md](README.md) for complete documentation

---

## Troubleshooting

### Agents not appearing?

**Plugin method:**
```bash
/plugin list
# Ensure "smicolon-standards" is listed and enabled
```

**Script method:**
```bash
ls .claude/agents/
# If empty, run: smicolon-init
```

### Hooks not running?

```bash
# Make hooks executable
chmod +x .claude/hooks/*.sh

# Verify hooks exist
ls -la .claude/hooks/
```

### Wrong project type detected?

```bash
# Re-run installer and manually select type
bash /path/to/claude-infra/scripts/install.sh
```

---

## Support

- **Full Documentation**: [README.md](README.md)
- **Plugin Guide**: [PLUGIN_INSTALL.md](PLUGIN_INSTALL.md)
- **Repository Structure**: [STRUCTURE.md](STRUCTURE.md)
- **MCP Setup**: [MCP_SETUP.md](MCP_SETUP.md)
- **Issues**: Create an issue in the repository

---

## For Companies

Want to create your own company-specific marketplace?

See the "Creating Your Own Marketplace" section in [PLUGIN_INSTALL.md](PLUGIN_INSTALL.md) for instructions on forking and customizing this infrastructure for your organization.
