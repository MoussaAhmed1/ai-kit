#!/bin/bash
# Smicolon Claude Code Infrastructure Installer
# One-command setup for company-wide conventions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Smicolon branding
echo ""
echo "${CYAN}${BOLD}╔═══════════════════════════════════════════════════════╗${NC}"
echo "${CYAN}${BOLD}║                                                       ║${NC}"
echo "${CYAN}${BOLD}║         🎯 Smicolon Claude Code Setup                ║${NC}"
echo "${CYAN}${BOLD}║         Company-Wide Development Standards           ║${NC}"
echo "${CYAN}${BOLD}║                                                       ║${NC}"
echo "${CYAN}${BOLD}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if Claude Code is installed
echo "${BLUE}→${NC} Checking for Claude Code installation..."
if ! command -v claude &> /dev/null; then
    echo "${YELLOW}⚠️  Claude Code not found. Installing...${NC}"
    npm install -g @anthropic-ai/claude-code
    echo "${GREEN}✅ Claude Code installed${NC}"
else
    echo "${GREEN}✅ Claude Code is already installed${NC}"
fi

# Determine installation mode
INSTALL_MODE=""
if [ "$1" == "--global" ] || [ "$1" == "-g" ]; then
    INSTALL_MODE="global"
elif [ -d ".git" ] || [ -f "manage.py" ] || [ -f "package.json" ]; then
    INSTALL_MODE="project"
else
    echo ""
    echo "${BOLD}Installation Mode:${NC}"
    echo "  1) ${GREEN}Global${NC} - Install Smicolon conventions globally (~/.smicolon)"
    echo "  2) ${BLUE}Project${NC} - Install in current project (.claude/)"
    echo ""
    read -p "Select mode (1 or 2): " mode_choice

    if [ "$mode_choice" == "1" ]; then
        INSTALL_MODE="global"
    else
        INSTALL_MODE="project"
    fi
fi

echo ""
echo "${BLUE}→${NC} Installation mode: ${BOLD}$INSTALL_MODE${NC}"
echo ""

# Global installation
if [ "$INSTALL_MODE" == "global" ]; then
    INSTALL_DIR="$HOME/.smicolon"

    echo "${BLUE}→${NC} Installing Smicolon conventions to ${BOLD}$INSTALL_DIR${NC}..."

    # Create directory
    mkdir -p "$INSTALL_DIR"

    # Get the script directory (where this install.sh is located)
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    REPO_DIR="$(dirname "$SCRIPT_DIR")"

    # Copy agents and hooks directories
    cp -r "$REPO_DIR/agents" "$INSTALL_DIR/"
    cp -r "$REPO_DIR/hooks" "$INSTALL_DIR/"

    echo "${GREEN}✅ Smicolon conventions installed globally${NC}"

    # Add to shell profile
    echo ""
    echo "${BLUE}→${NC} Setting up shell integration..."

    # Detect shell
    if [ -n "$ZSH_VERSION" ]; then
        PROFILE="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        if [ -f "$HOME/.bashrc" ]; then
            PROFILE="$HOME/.bashrc"
        else
            PROFILE="$HOME/.bash_profile"
        fi
    else
        PROFILE="$HOME/.profile"
    fi

    # Add alias if not already present
    if ! grep -q "SMICOLON_CLAUDE" "$PROFILE" 2>/dev/null; then
        cat >> "$PROFILE" << 'EOF'

# Smicolon Claude Code Integration
export SMICOLON_CLAUDE="$HOME/.smicolon"
alias smicolon-init='bash $HOME/.smicolon/scripts/init-project.sh'
alias smicolon-update='cd $HOME/.smicolon && git pull'

EOF
        echo "${GREEN}✅ Added shell integration to $PROFILE${NC}"
        echo "${YELLOW}   Run: ${BOLD}source $PROFILE${NC}"
    else
        echo "${GREEN}✅ Shell integration already configured${NC}"
    fi

    # Create helper scripts
    mkdir -p "$INSTALL_DIR/scripts"

    # Create init-project script
    cat > "$INSTALL_DIR/scripts/init-project.sh" << 'INITSCRIPT'
#!/bin/bash
# Initialize Smicolon conventions in a project

echo "🎯 Initializing Smicolon conventions in current project..."

if [ ! -d ".git" ]; then
    echo "⚠️  Warning: Not a git repository"
    read -p "Continue anyway? (y/n): " continue
    if [[ ! $continue =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

# Create .claude directory
mkdir -p .claude

# Link to global Smicolon conventions
ln -sf "$HOME/.smicolon/agents" .claude/agents
ln -sf "$HOME/.smicolon/hooks" .claude/hooks

# Create project-specific custom directory
mkdir -p .claude/custom

# Detect project type and create project context
if [ -f "manage.py" ]; then
    PROJECT_TYPE="Django"
    cat > .claude/custom/project-context.md << 'DJANGOCTX'
# Smicolon Django Project

## Project Name
[TODO: Add your project name]

## Tech Stack
- Django + Django REST Framework
- PostgreSQL
- Celery (background tasks)
- Redis (cache)

## Smicolon Conventions Applied
✅ Absolute imports only
✅ UUID primary keys
✅ Timestamps on all models
✅ Soft deletes (is_deleted)
✅ Service layer for business logic

## Custom Project Rules
- [Add any project-specific rules here]

## Environment Setup
```bash
# Add your setup commands
python manage.py migrate
python manage.py createsuperuser
```
DJANGOCTX

elif [ -f "package.json" ] && grep -q "next" package.json 2>/dev/null; then
    PROJECT_TYPE="Next.js"
    cat > .claude/custom/project-context.md << 'NEXTCTX'
# Smicolon Next.js Project

## Project Name
[TODO: Add your project name]

## Tech Stack
- Next.js 15+ (App Router)
- TypeScript (strict mode)
- Tailwind CSS
- TanStack Query
- Zod validation

## Smicolon Conventions Applied
✅ TypeScript strict mode
✅ Zod for form validation
✅ TanStack Query for API calls
✅ Proper error handling
✅ Accessibility (WCAG 2.1 AA)

## Custom Project Rules
- [Add any project-specific rules here]

## Environment Setup
```bash
# Add your setup commands
npm install
npm run dev
```
NEXTCTX

elif [ -f "package.json" ] && grep -q "@nestjs/core" package.json 2>/dev/null; then
    PROJECT_TYPE="NestJS"
    cat > .claude/custom/project-context.md << 'NESTCTX'
# Smicolon NestJS Project

## Project Name
[TODO: Add your project name]

## Tech Stack
- NestJS (TypeScript backend)
- TypeORM or Prisma
- PostgreSQL
- JWT + Passport
- class-validator

## Smicolon Conventions Applied
✅ TypeScript strict mode
✅ Modular imports with aliases (import * as _module from 'src/...')
✅ UUID primary keys
✅ Timestamps (createdAt, updatedAt)
✅ Soft deletes (deletedAt)
✅ DTOs with validation
✅ Dependency injection

## Custom Project Rules
- [Add any project-specific rules here]

## Environment Setup
```bash
# Add your setup commands
npm install
npm run start:dev
```
NESTCTX

elif [ -f "package.json" ] && grep -q "nuxt" package.json 2>/dev/null; then
    PROJECT_TYPE="Nuxt.js"
    cat > .claude/custom/project-context.md << 'NUXTCTX'
# Smicolon Nuxt.js Project

## Project Name
[TODO: Add your project name]

## Tech Stack
- Nuxt 3
- Vue 3 Composition API
- TypeScript (strict mode)
- Tailwind CSS
- Pinia (state management)
- VeeValidate + Zod

## Smicolon Conventions Applied
✅ TypeScript strict mode
✅ Vue 3 Composition API (<script setup>)
✅ Zod for form validation
✅ Pinia for state management
✅ Nuxt composables (useFetch, useAsyncData)
✅ Auto-imports enabled
✅ Accessibility (WCAG 2.1 AA)

## Custom Project Rules
- [Add any project-specific rules here]

## Environment Setup
```bash
# Add your setup commands
npm install
npm run dev
```
NUXTCTX

else
    PROJECT_TYPE="Generic"
    cat > .claude/custom/project-context.md << 'GENCTX'
# Smicolon Project

## Project Name
[TODO: Add your project name]

## Tech Stack
- [TODO: List your tech stack]

## Smicolon Conventions
- [Add your conventions here]

## Environment Setup
```bash
# Add your setup commands
```
GENCTX
fi

# Add .claude to .gitignore if not already there
if [ -f ".gitignore" ]; then
    if ! grep -q "^.claude/custom/private" .gitignore 2>/dev/null; then
        echo "" >> .gitignore
        echo "# Claude Code - ignore private customizations" >> .gitignore
        echo ".claude/custom/private/" >> .gitignore
    fi
fi

echo "✅ Smicolon conventions initialized!"
echo "📁 Project type: $PROJECT_TYPE"
echo ""
echo "Available agents:"
echo "  @django-architect       - Architecture design specialist"
echo "  @django-builder         - Feature implementation specialist"
echo "  @django-feature-based   - Large-scale architecture specialist"
echo "  @django-tester          - Testing specialist (90%+ coverage)"
echo "  @django-reviewer        - Security review specialist"
echo "  @nestjs-architect       - Backend architecture (NestJS/TypeScript)"
echo "  @nestjs-builder         - Backend implementation (NestJS)"
echo "  @nestjs-tester          - Testing specialist (NestJS)"
echo "  @nextjs-architect       - Frontend architecture (Next.js/React)"
echo "  @nextjs-modular         - Large-scale Next.js modular architecture"
echo "  @nuxtjs-architect       - Frontend architecture (Nuxt.js/Vue 3)"
echo "  @frontend-visual        - Visual QA with Playwright MCP + Figma MCP"
echo "  @frontend-tester        - Frontend testing specialist (80%+ coverage)"
echo ""
echo "📝 Edit .claude/custom/project-context.md to customize for your project"
echo ""
echo ""
echo "Start coding: ${BOLD}claude @django-architect${NC}"
INITSCRIPT

    chmod +x "$INSTALL_DIR/scripts/init-project.sh"

    echo ""
    echo "${GREEN}${BOLD}╔═══════════════════════════════════════════════════════╗${NC}"
    echo "${GREEN}${BOLD}║                                                       ║${NC}"
    echo "${GREEN}${BOLD}║         ✅ Global Installation Complete!              ║${NC}"
    echo "${GREEN}${BOLD}║                                                       ║${NC}"
    echo "${GREEN}${BOLD}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "${BOLD}Next steps:${NC}"
    echo ""
    echo "1. ${CYAN}Reload your shell:${NC}"
    echo "   ${BOLD}source $PROFILE${NC}"
    echo ""
    echo "2. ${CYAN}Initialize a project:${NC}"
    echo "   ${BOLD}cd /path/to/your/project${NC}"
    echo "   ${BOLD}smicolon-init${NC}"
    echo ""
    echo "3. ${CYAN}Start coding with an agent:${NC}"
    echo "   ${BOLD}claude @django-architect${NC}"
    echo "   Or: ${BOLD}claude @django-builder${NC}, ${BOLD}@nestjs-architect${NC}, ${BOLD}@nextjs-architect${NC}"
    echo ""

# Project installation
else
    echo "${BLUE}→${NC} Installing Smicolon conventions in current project..."

    # Get the script directory
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    REPO_DIR="$(dirname "$SCRIPT_DIR")"

    # Create .claude directory
    mkdir -p .claude
    mkdir -p .claude/agents
    mkdir -p .claude/custom

    # Detect project type
    echo ""
    echo "${BLUE}→${NC} Detecting project type..."
    PROJECT_TYPE=""
    AUTO_DETECTED=""

    if [ -f "manage.py" ]; then
        PROJECT_TYPE="Django"
        AUTO_DETECTED="yes"
        echo "${GREEN}✅ Auto-detected: Django project${NC}"
    elif [ -f "package.json" ] && grep -q "@nestjs/core" package.json 2>/dev/null; then
        PROJECT_TYPE="NestJS"
        AUTO_DETECTED="yes"
        echo "${GREEN}✅ Auto-detected: NestJS project${NC}"
    elif [ -f "package.json" ] && grep -q "\"next\"" package.json 2>/dev/null; then
        PROJECT_TYPE="Next.js"
        AUTO_DETECTED="yes"
        echo "${GREEN}✅ Auto-detected: Next.js project${NC}"
    elif [ -f "package.json" ] && grep -q "nuxt" package.json 2>/dev/null; then
        PROJECT_TYPE="Nuxt.js"
        AUTO_DETECTED="yes"
        echo "${GREEN}✅ Auto-detected: Nuxt.js project${NC}"
    else
        echo "${YELLOW}⚠️  Could not auto-detect project type${NC}"
    fi

    # If couldn't auto-detect, ask user
    if [ -z "$AUTO_DETECTED" ]; then
        echo ""
        echo "${BOLD}Please select your project type:${NC}"
        echo "  1) Django (Python backend)"
        echo "  2) NestJS (TypeScript backend)"
        echo "  3) Next.js (React frontend)"
        echo "  4) Nuxt.js (Vue 3 frontend)"
        echo "  5) Multiple (install multiple agent sets)"
        echo "  6) All (install all agents)"
        echo ""
        read -p "Select (1-6): " type_choice

        case $type_choice in
            1) PROJECT_TYPE="Django" ;;
            2) PROJECT_TYPE="NestJS" ;;
            3) PROJECT_TYPE="Next.js" ;;
            4) PROJECT_TYPE="Nuxt.js" ;;
            5) PROJECT_TYPE="Multiple" ;;
            6) PROJECT_TYPE="All" ;;
            *)
                echo "${RED}Invalid selection. Defaulting to All.${NC}"
                PROJECT_TYPE="All"
                ;;
        esac
    fi

    echo ""
    echo "${BLUE}→${NC} Installing agents for: ${BOLD}$PROJECT_TYPE${NC}"
    echo ""

    # Copy relevant agents based on project type
    if [ "$PROJECT_TYPE" == "All" ]; then
        # Copy all agents
        cp -r "$REPO_DIR/agents/"* .claude/agents/
        echo "${GREEN}✅ Installed all agent types${NC}"
    elif [ "$PROJECT_TYPE" == "Multiple" ]; then
        # Ask which ones to install
        echo "${BOLD}Select agent types to install (space-separated numbers):${NC}"
        echo "  1) Django"
        echo "  2) NestJS"
        echo "  3) Next.js"
        echo "  4) Nuxt.js"
        echo ""
        read -p "Enter numbers (e.g., 1 2): " selections

        for selection in $selections; do
            case $selection in
                1)
                    cp "$REPO_DIR/agents/django-"*.md .claude/agents/ 2>/dev/null
                    echo "${GREEN}✅ Installed Django agents${NC}"
                    ;;
                2)
                    cp "$REPO_DIR/agents/nestjs-"*.md .claude/agents/ 2>/dev/null
                    echo "${GREEN}✅ Installed NestJS agents${NC}"
                    ;;
                3)
                    cp "$REPO_DIR/agents/nextjs-"*.md .claude/agents/ 2>/dev/null
                    echo "${GREEN}✅ Installed Next.js agents${NC}"
                    ;;
                4)
                    cp "$REPO_DIR/agents/nuxtjs-"*.md .claude/agents/ 2>/dev/null
                    echo "${GREEN}✅ Installed Nuxt.js agents${NC}"
                    ;;
            esac
        done
    else
        # Install agents for detected/selected project type
        case $PROJECT_TYPE in
            "Django")
                cp "$REPO_DIR/agents/django-"*.md .claude/agents/
                echo "${GREEN}✅ Installed Django agents (5 agents)${NC}"
                ;;
            "NestJS")
                cp "$REPO_DIR/agents/nestjs-"*.md .claude/agents/
                echo "${GREEN}✅ Installed NestJS agents (3 agents)${NC}"
                ;;
            "Next.js")
                cp "$REPO_DIR/agents/nextjs-"*.md .claude/agents/
                cp "$REPO_DIR/agents/frontend-visual.md" .claude/agents/
                cp "$REPO_DIR/agents/frontend-tester.md" .claude/agents/
                echo "${GREEN}✅ Installed Next.js agents (4 agents)${NC}"
                ;;
            "Nuxt.js")
                cp "$REPO_DIR/agents/nuxtjs-"*.md .claude/agents/
                cp "$REPO_DIR/agents/frontend-visual.md" .claude/agents/
                cp "$REPO_DIR/agents/frontend-tester.md" .claude/agents/
                echo "${GREEN}✅ Installed Nuxt.js agents (3 agents)${NC}"
                ;;
        esac
    fi

    # Copy hooks (they're conditional based on project type)
    cp -r "$REPO_DIR/hooks" .claude/
    echo "${GREEN}✅ Installed hooks${NC}"

    # Add to .gitignore
    if [ -f ".gitignore" ]; then
        if ! grep -q "^.claude/custom/private" .gitignore 2>/dev/null; then
            echo "" >> .gitignore
            echo "# Claude Code - ignore private customizations" >> .gitignore
            echo ".claude/custom/private/" >> .gitignore
            echo "${GREEN}✅ Updated .gitignore${NC}"
        fi
    fi

    echo "${GREEN}✅ Smicolon conventions installed in project${NC}"
    echo ""
    echo "${GREEN}${BOLD}╔═══════════════════════════════════════════════════════╗${NC}"
    echo "${GREEN}${BOLD}║                                                       ║${NC}"
    echo "${GREEN}${BOLD}║         ✅ Project Installation Complete!             ║${NC}"
    echo "${GREEN}${BOLD}║                                                       ║${NC}"
    echo "${GREEN}${BOLD}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "${BOLD}Installed agents:${NC}"

    # List installed agents dynamically
    if [ -f ".claude/agents/django-architect.md" ]; then
        echo "  ${CYAN}@django-architect${NC}       - Architecture design specialist"
        echo "  ${CYAN}@django-builder${NC}         - Feature implementation specialist"
        echo "  ${CYAN}@django-feature-based${NC}   - Large-scale architecture specialist"
        echo "  ${CYAN}@django-tester${NC}          - Testing specialist"
        echo "  ${CYAN}@django-reviewer${NC}        - Security review specialist"
    fi

    if [ -f ".claude/agents/nestjs-architect.md" ]; then
        echo "  ${CYAN}@nestjs-architect${NC}       - Backend architecture (NestJS/TypeScript)"
        echo "  ${CYAN}@nestjs-builder${NC}         - Backend implementation (NestJS)"
        echo "  ${CYAN}@nestjs-tester${NC}          - Testing specialist (NestJS)"
    fi

    if [ -f ".claude/agents/nextjs-architect.md" ]; then
        echo "  ${CYAN}@nextjs-architect${NC}       - Frontend architecture (Next.js/React)"
        echo "  ${CYAN}@nextjs-modular${NC}         - Large-scale Next.js modular architecture"
    fi

    if [ -f ".claude/agents/nuxtjs-architect.md" ]; then
        echo "  ${CYAN}@nuxtjs-architect${NC}       - Frontend architecture (Nuxt.js/Vue 3)"
    fi

    if [ -f ".claude/agents/frontend-visual.md" ]; then
        echo "  ${CYAN}@frontend-visual${NC}        - Visual QA with Playwright MCP"
    fi

    if [ -f ".claude/agents/frontend-tester.md" ]; then
        echo "  ${CYAN}@frontend-tester${NC}        - Frontend testing specialist"
    fi

    echo ""
    echo "${BOLD}Start coding:${NC}"

    # Show appropriate first agent based on what's installed
    if [ -f ".claude/agents/django-architect.md" ]; then
        echo "  ${BOLD}claude @django-architect${NC}"
    elif [ -f ".claude/agents/nestjs-architect.md" ]; then
        echo "  ${BOLD}claude @nestjs-architect${NC}"
    elif [ -f ".claude/agents/nextjs-architect.md" ]; then
        echo "  ${BOLD}claude @nextjs-architect${NC}"
    elif [ -f ".claude/agents/nuxtjs-architect.md" ]; then
        echo "  ${BOLD}claude @nuxtjs-architect${NC}"
    fi

    echo ""
fi

echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "${BOLD}  Smicolon Claude Code - Enforcing Excellence  ${NC}"
echo "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
