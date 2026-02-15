# MCP Server Setup Guide

This guide explains how MCP (Model Context Protocol) servers are configured in the Smicolon marketplace templates for automatic, context-aware loading.

## Why Project-Scoped MCPs?

### The Context Problem
- MCPs loaded globally consume **40k-108k tokens** before any conversation starts
- With 200k context window, this leaves only **~92k tokens** for actual work
- Solution: **Project-scoped `.mcp.json` files** that only load when working in specific projects

### Token Savings
```
Global MCP setup:  108k tokens consumed (all projects)
Project-scoped:    ~5-10k tokens (only relevant MCPs)
Savings:           ~100k tokens freed for coding!
```

## Project-Scoped Configuration

Each template includes a `.mcp.json` file at the project root that automatically loads framework-specific MCPs when you work in that directory.

### Directory-Based Auto-Loading

```bash
# Django project
cd ~/projects/django-app
claude  # Auto-loads: Linear + PostgreSQL MCPs

# Next.js project
cd ~/projects/nextjs-app
claude  # Auto-loads: Linear + Playwright + Figma MCPs

# Change directory = different MCPs automatically!
```

## MCP Servers by Framework

### Django / NestJS Projects

**MCPs Configured:**
- **Linear**: Issue tracking and project management
- **PostgreSQL**: Database inspection and read-only queries

**`.mcp.json`:**
```json
{
  "mcpServers": {
    "linear": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "https://mcp.linear.app/mcp"]
    },
    "postgres": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-postgres",
        "postgresql://localhost/YOUR_DATABASE_NAME"
      ]
    }
  }
}
```

**Setup Steps:**
1. Update `YOUR_DATABASE_NAME` with actual database name
2. Add credentials if database requires authentication:
   ```json
   "postgresql://username:password@localhost:5432/dbname"
   ```
3. Authenticate Linear (one-time OAuth when prompted)

### Next.js / Nuxt.js Projects

**MCPs Configured:**
- **Linear**: Issue tracking and project management
- **Playwright**: Browser automation and visual testing
- **Figma**: Design file integration (remote)

**`.mcp.json`:**
```json
{
  "mcpServers": {
    "linear": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "https://mcp.linear.app/mcp"]
    },
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp@latest"]
    },
    "figma": {
      "transport": "http",
      "url": "https://mcp.figma.com/mcp"
    }
  }
}
```

**Setup Steps:**
1. Authenticate Linear (one-time OAuth)
2. Authenticate Figma (requires Dev Mode permissions)
3. Run `npm run dev` before using Playwright MCP
4. No configuration needed - works out of the box!

## MCP Server Details

### Linear MCP

**Purpose:** Seamless issue tracking integration

**Features:**
- Create Linear issues from Claude
- Update existing issues
- Search and filter issues
- Link commits to issues

**Authentication:**
- OAuth flow (one-time setup)
- Click "Authenticate" when prompted
- Authorize access in browser

**Usage Examples:**
```bash
# Create issue
"Create a Linear issue: Fix authentication bug"

# Update issue
"Update Linear issue ABC-123: Mark as completed"

# Search issues
"Show all P0 bugs in Linear"
```

**Token Cost:** ~2k tokens

---

### PostgreSQL MCP

**Purpose:** Database inspection and debugging

**Features:**
- View database schemas
- Execute read-only SQL queries
- Inspect table structures
- Check relationships and indexes

**Security:**
- **Read-only access** - cannot modify data
- Safe for production database inspection
- No destructive operations allowed

**Configuration:**
```json
"postgresql://username:password@host:port/database"
```

**Usage Examples:**
```bash
# Inspect schema
"Show me the users table schema"

# Read-only query
"How many active users are in the database?"

# Relationships
"What tables reference the users table?"
```

**Token Cost:** ~3k tokens

---

### Playwright MCP

**Purpose:** Browser automation and visual testing

**Features:**
- Navigate pages and interact with UI
- Take screenshots for verification
- Execute JavaScript in browser
- Submit forms and test flows
- Works with `@frontend-visual` agent

**Requirements:**
- Local dev server running (`npm run dev`)
- Browser window will be visible during testing

**Usage with @frontend-visual:**
```bash
# Start dev server
npm run dev

# Visual testing
@frontend-visual "Verify login page matches design"

# Playwright will:
# - Open browser to http://localhost:3000
# - Navigate to login page
# - Take screenshots
# - Compare with Figma (if configured)
# - Report discrepancies
```

**Token Cost:** ~4k tokens

**Installation (if not using templates):**
```bash
# Install Playwright browsers first
npx playwright install
npx playwright install-deps
```

---

### Figma MCP (Remote)

**Purpose:** Design file integration for pixel-perfect implementation

**Features:**
- Fetch design specs from Figma files
- Extract colors, typography, spacing
- Compare implementation vs design
- Works with `@frontend-visual` agent

**Requirements:**
- Figma account with **Dev Mode permissions**
- OAuth authentication (one-time)
- **Remote MCP** - no local Figma app needed

**Authentication:**
```bash
# Claude will prompt for authentication
# Click "Authenticate" → Opens browser
# Sign in to Figma → Authorize access
```

**Usage Examples:**
```bash
# Get design specs
"Get design specs from Figma file XYZ"

# Extract styles
"Extract color palette from Figma design"

# Compare implementation
@frontend-visual "Compare dashboard with Figma design ABC-123"
```

**Token Cost:** ~3k tokens

**Alternative: Figma Desktop MCP (Local)**

If you prefer using Figma Desktop app:

```json
{
  "mcpServers": {
    "figma-dev-mode": {
      "transport": "sse",
      "url": "http://127.0.0.1:3845/sse"
    }
  }
}
```

**Requirements:**
1. Figma Desktop app (latest version)
2. Enable "Dev Mode MCP Server" in Figma Preferences
3. Open a design file
4. Toggle Dev Mode ON

## Scope Hierarchy

Claude Code uses three MCP scopes with priority:

```
1. Local (.claude/mcp.json in project)     [Highest Priority]
2. Project (.mcp.json at project root)     [Medium Priority]
3. User (~/.claude/mcp.json)               [Lowest Priority]
```

### Recommended Strategy

**User Scope** (`~/.claude/mcp.json`):
- Minimal global MCPs (GitHub, Git only)
- Tools used across ALL projects

**Project Scope** (`.mcp.json`):
- Framework-specific MCPs
- Team-shared configuration
- **Commit to git for team consistency**

**Local Scope** (`.claude/mcp.json`):
- Personal overrides
- Sensitive credentials
- **Do NOT commit to git**

### Example Setup

```bash
# Global (always loaded)
~/.claude/mcp.json
{
  "mcpServers": {
    "github": { ... }  # 2k tokens
  }
}

# Django project (auto-loads in this directory)
~/projects/django-app/.mcp.json
{
  "mcpServers": {
    "linear": { ... },    # 2k tokens
    "postgres": { ... }   # 3k tokens
  }
}

# Next.js project (auto-loads in this directory)
~/projects/nextjs-app/.mcp.json
{
  "mcpServers": {
    "linear": { ... },     # 2k tokens
    "playwright": { ... }, # 4k tokens
    "figma": { ... }       # 3k tokens
  }
}

Result:
- Django session:  2k + 2k + 3k = 7k tokens  (vs 108k global)
- Next.js session: 2k + 2k + 4k + 3k = 11k tokens (vs 108k global)
- 90%+ token reduction achieved!
```

## Visual Testing with @frontend-visual

The `@frontend-visual` agent uses Playwright and Figma MCPs for pixel-perfect implementation verification.

### Workflow 1: Implementing from Figma

```bash
# Start dev server
npm run dev

# Use visual agent
claude @frontend-visual

# Provide Figma URL
"Implement this login form from Figma:
https://www.figma.com/file/ABC123/Project?node-id=123:456"
```

**Agent will:**
1. Extract design specs from Figma MCP
2. Get colors, typography, spacing
3. Implement component using project tech stack
4. Use Playwright to capture implementation
5. Compare with Figma design
6. Report differences and suggest fixes

### Workflow 2: Verifying Existing Implementation

```bash
# Start dev server
npm run dev

# Visual verification
claude @frontend-visual

"Verify the dashboard at /dashboard matches the design system"
```

**Agent will:**
1. Load project design system (from tailwind.config.js or design-system.md)
2. Navigate to page with Playwright
3. Take screenshots
4. Measure spacing, colors, typography
5. Compare with design system
6. Test responsive breakpoints
7. Report findings

### Workflow 3: Design System Extraction

```bash
claude @frontend-visual

"Extract design system from Figma file:
https://www.figma.com/file/ABC123/Design-System"
```

**Agent will:**
1. Use Figma MCP to get file styles
2. Extract color palette
3. Extract typography scale
4. Extract spacing system
5. Create `.claude/custom/design-system.md`
6. Generate Tailwind config (if applicable)

## Team Setup

### For New Projects

```bash
# 1. Clone template
npx degit smicolon/ai-kit/templates/django-project my-project
cd my-project

# 2. Update .mcp.json
# Edit database connection string

# 3. Start Claude Code
claude

# 4. Authenticate MCPs (first time only)
# Linear: Click "Authenticate" when prompted
# PostgreSQL: No auth needed (connection string)

# 5. Start building
@django-architect "Design user management system"
```

### For Existing Projects

```bash
# 1. Copy .mcp.json from template
cp /path/to/template/.mcp.json .

# 2. Update configuration
# Edit database connection, etc.

# 3. Commit to git
git add .mcp.json
git commit -m "Add project-scoped MCP configuration"
git push

# 4. Team members pull
# They get MCPs automatically!
```

## Troubleshooting

### MCPs Not Loading

**Check installation:**
```bash
/mcp  # In Claude Code, view active MCPs
```

**Verify .mcp.json location:**
```bash
ls -la .mcp.json  # Should be at project root
```

**Restart Claude Code:**
```bash
# Exit and restart for new .mcp.json to load
```

### Linear Authentication Issues

**Error:** `Linear authentication failed`

**Solution:**
1. Type `/mcp` in Claude Code
2. Select Linear from the list
3. Click "Authenticate"
4. Complete OAuth flow in browser
5. Verify authentication success

### PostgreSQL Connection Issues

**Error:** `Connection refused`

**Solution:**
1. Verify database is running:
   ```bash
   psql -U username -d dbname
   ```
2. Check connection string format:
   ```json
   "postgresql://username:password@localhost:5432/dbname"
   ```
3. Test connection outside Claude:
   ```bash
   psql "postgresql://username:password@localhost:5432/dbname"
   ```

### Playwright Browser Not Launching

**Error:** `Browser not found`

**Solution:**
```bash
# Install Playwright browsers
npx playwright install
npx playwright install-deps
```

### Figma Authentication Issues

**Error:** `Figma authentication failed` or `Dev Mode not available`

**Solution:**
1. Verify Figma account has **Dev Mode permissions**
2. Free/Viewer accounts cannot use Dev Mode
3. Requires Professional/Organization/Enterprise plan with Dev seat
4. Click "Authenticate" when prompted
5. Complete OAuth flow in browser

**Using Figma Desktop MCP instead:**
1. Install Figma Desktop app
2. Enable "Dev Mode MCP Server" in Preferences
3. Open a design file
4. Toggle Dev Mode ON
5. Use SSE transport: `http://127.0.0.1:3845/sse`

### High Token Usage

**Check context breakdown:**
```bash
/context  # View token usage

# Shows:
# - MCP tools: X tokens
# - Memory files: Y tokens
# - Available: Z tokens
```

**Optimize:**
1. Move global MCPs to project-scoped files
2. Remove unused MCPs
3. Use project templates (pre-optimized)

## Best Practices

1. **Always use project-scoped `.mcp.json`** for framework-specific MCPs
2. **Keep global MCPs minimal** (GitHub, Git only)
3. **Commit `.mcp.json` to git** for team consistency
4. **Update connection strings** before first use
5. **Authenticate once** per MCP (OAuth persists)
6. **Monitor token usage** with `/context` command
7. **Use specific MCPs** for specific projects (not all MCPs everywhere)
8. **Run dev server** before using Playwright MCP
9. **Use @frontend-visual** agent for visual testing (don't invoke MCPs directly)
10. **Document MCP requirements** in project README

## Future Enhancements

### Lazy Loading (Planned)

GitHub issue #7336 proposes lazy loading:
- Load only lightweight index at startup (~5k tokens)
- Load tools on-demand based on keywords
- 95% token reduction potential

**Status:** Feature request with proof-of-concept

### Skills Integration (Planned)

Skills will work with MCPs:
- Skills can declare `required-mcps` in SKILL.md
- Auto-prompt to install if missing
- Seamless integration with project MCPs

## Available MCP Tools

### Linear MCP Tools
- `create_issue` - Create Linear issue
- `update_issue` - Update existing issue
- `search_issues` - Search/filter issues
- `get_issue` - Get issue details
- `add_comment` - Add comment to issue

### PostgreSQL MCP Tools
- `query` - Execute read-only SQL query
- `list_tables` - List all tables
- `describe_table` - Get table schema
- `get_indexes` - List table indexes

### Playwright MCP Tools
- `navigate` - Navigate to URL
- `screenshot` - Take screenshot
- `click` - Click element
- `fill` - Fill form field
- `evaluate` - Execute JavaScript
- `setViewportSize` - Set viewport size
- `waitForSelector` - Wait for element

### Figma MCP Tools
- `get_file` - Get Figma file details
- `get_file_styles` - Get design tokens
- `get_node` - Get component details
- `get_image` - Export design as image
- `get_comments` - Get design comments

## Summary

Project-scoped MCPs provide:
- ✅ **Automatic context-based loading** (change directory = different MCPs)
- ✅ **90%+ token reduction** (7-11k vs 108k global)
- ✅ **Team consistency** (commit `.mcp.json` to git)
- ✅ **Framework-specific tools** (Django gets PostgreSQL, Next.js gets Playwright)
- ✅ **Seamless integration** with agents and workflows
- ✅ **Zero manual toggling** (MCPs load automatically per project)

**Result:** More context for actual coding, less overhead from unused tools!
