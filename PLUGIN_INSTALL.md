# Plugin Installation Guide

This repository can be installed as a Claude Code plugin for seamless integration.

## Installation as Plugin

### Method 1: From Smicolon Marketplace (Recommended)

```bash
# Add the Smicolon marketplace (one-time setup)
/plugin marketplace add smicolon-marketplace https://github.com/smicolon/claude-infra

# Install the plugin
/plugin install smicolon-standards

# Verify installation
/help
```

This method installs from the official Smicolon plugin marketplace, which provides:
- ✅ Official plugin listings
- ✅ Version management
- ✅ Plugin discovery
- ✅ Team-wide distribution

### Method 2: Direct from GitHub

```bash
# Install directly from the GitHub repository
/plugin marketplace add smicolon https://github.com/smicolon/claude-infra
/plugin install smicolon-standards

# Verify installation
/help
```

You should now see all Smicolon agents available:
- `@django-architect`
- `@django-builder`
- `@django-feature-based`
- `@django-tester`
- `@django-reviewer`
- `@nestjs-architect`
- `@nestjs-builder`
- `@nestjs-tester`
- `@nextjs-architect`
- `@nextjs-modular`
- `@nuxtjs-architect`
- `@frontend-visual`
- `@frontend-tester`
- `@system-architect`

### Method 3: From Local Directory (Development)

```bash
# Clone the repository
git clone https://github.com/smicolon/claude-infra.git ~/smicolon-claude

# Add as local marketplace
/plugin marketplace add smicolon-local file://~/smicolon-claude

# Install the plugin
/plugin install smicolon-standards

# Verify installation
/help
```

### Method 4: Direct Plugin URL

```bash
# Install directly from Git repository URL
/plugin install https://github.com/smicolon/claude-infra
```

## Creating Your Own Marketplace

If you want to host your own company marketplace:

### 1. Fork or Clone the Repository

```bash
git clone https://github.com/smicolon/claude-infra.git your-company-standards
cd your-company-standards
```

### 2. Customize the Marketplace

Edit `marketplace-registry.json`:

```json
{
  "name": "your-company-marketplace",
  "displayName": "Your Company Plugin Marketplace",
  "owner": {
    "name": "Your Company Dev Team",
    "email": "dev@yourcompany.com",
    "url": "https://yourcompany.com"
  },
  "plugins": [
    {
      "name": "your-company-standards",
      "displayName": "Your Company Standards",
      "source": ".",
      "description": "Your company-specific development standards",
      "version": "1.0.0"
    }
  ]
}
```

### 3. Customize Agents and Hooks

- Edit agents in `agents/` directory to match your conventions
- Modify hooks in `hooks/` directory for your standards
- Update `.claude-plugin/plugin.json` with your information
- Update `marketplace-registry.json` with your marketplace details

### 4. Host on GitHub/GitLab

```bash
git add .
git commit -m "Customize for our company"
git push origin main
```

### 5. Distribute to Team

Share with your team:

```bash
# Team members run:
/plugin marketplace add your-company https://github.com/yourcompany/company-standards
/plugin install your-company-standards
```

## Plugin Features

### Agents (14 total)

**Django (5 agents):**
- `@django-architect` - System architecture design
- `@django-builder` - Feature implementation
- `@django-feature-based` - Large-scale feature-based architecture
- `@django-tester` - Test writing (90%+ coverage)
- `@django-reviewer` - Security and code review

**NestJS (3 agents):**
- `@nestjs-architect` - Backend architecture
- `@nestjs-builder` - Feature implementation
- `@nestjs-tester` - Test writing

**Frontend (5 agents):**
- `@nextjs-architect` - Next.js/React architecture
- `@nextjs-modular` - Large-scale Next.js modular architecture
- `@nuxtjs-architect` - Nuxt.js/Vue 3 architecture
- `@frontend-visual` - Visual QA with Playwright + Figma MCP
- `@frontend-tester` - Frontend testing (80%+ coverage)

**System Architecture (1 agent):**
- `@system-architect` - Eraser.io diagram-as-code specialist for ERD, flowcharts, cloud architecture, sequence diagrams, and BPMN

### Hooks (Automatic)

The plugin automatically installs hooks that enforce Smicolon conventions:

**Pre-Prompt Hook:**
- Auto-detects project type (Django/NestJS/Next.js/Nuxt.js)
- Injects framework-specific conventions before each prompt
- Ensures consistent code standards

**Post-Write Hook:**
- Validates generated code against conventions
- Checks import patterns, model structure, security
- Flags violations immediately

## Using the Plugin

### Basic Workflow

**Django Project:**
```bash
# Architecture
@django-architect "Design a payment processing system"

# Implementation
@django-builder "Implement the payment system"

# Testing
@django-tester "Write tests for payment processing"

# Review
@django-reviewer "Review payment code for security"
```

**Next.js Project:**
```bash
# Architecture
@nextjs-architect "Design authentication flow UI"

# Testing
@frontend-tester "Write comprehensive tests for auth flow"

# Visual QA (with Figma URL)
@frontend-visual "Verify login form matches Figma design: https://figma.com/file/..."
```

### Project-Specific Configuration

Create `.claude/custom/project-context.md` in your project to add project-specific rules:

```markdown
# My Project

## Tech Stack
- Django 5.0
- PostgreSQL 16
- Redis

## Custom Rules
- Use Redis for session storage
- All API endpoints require JWT authentication
- Rate limiting: 100 requests/minute per user

## Environment Setup
\```bash
python manage.py migrate
python manage.py createsuperuser
\```
```

## Plugin Management

### Update Plugin

```bash
# Update to latest version
/plugin update smicolon-standards
```

### Disable/Enable Plugin

```bash
# Temporarily disable
/plugin disable smicolon-standards

# Re-enable
/plugin enable smicolon-standards
```

### Uninstall Plugin

```bash
# Remove the plugin
/plugin uninstall smicolon-standards
```

### List Installed Plugins

```bash
# View all plugins
/plugin list
```

## Advantages of Plugin Installation

✅ **Automatic Updates**: Easy to update across all projects
✅ **No Manual Setup**: No need to run installation scripts
✅ **Centralized Management**: One installation for all projects
✅ **Version Control**: Easy to pin or update versions
✅ **Team Distribution**: Share plugin URL with team
✅ **No Symlinks**: Clean project directories
✅ **Backwards Compatible**: Works alongside existing installations

## Alternative Installation Methods

If you prefer the traditional approach, see [README.md](README.md) for script-based installation using `scripts/install.sh`.

## Troubleshooting

### Plugin Not Found

```bash
# Check marketplace
/plugin marketplace list

# Re-add marketplace
/plugin marketplace add smicolon https://github.com/smicolon/claude-infra
```

### Agents Not Appearing

```bash
# Verify plugin is enabled
/plugin list

# Check help
/help

# Restart Claude Code
```

### Hooks Not Running

Hooks are automatically installed with the plugin. If they're not running:
1. Verify plugin is enabled
2. Check `.claude/custom/` directory exists
3. Restart Claude Code

## Support

- **Documentation**: [README.md](README.md)
- **Plugin System**: [Claude Code Plugins](https://docs.claude.com/en/docs/claude-code/plugins)
- **Issues**: Create an issue in the repository

## License

MIT License - See [LICENSE](LICENSE) file for details.
