# MCP Setup for Visual Testing & Design Integration

## Overview

The `@frontend-visual` agent uses two MCP servers:
1. **Playwright MCP** - Visual testing and verification of implementations
2. **Figma MCP** - Design analysis and design token extraction from Figma files

## Quick Start

```bash
# 1. Install Playwright MCP
claude mcp add playwright npx @playwright/mcp@latest

# 2. Enable Figma MCP server in Figma Desktop:
#    - Open Figma Desktop app
#    - Preferences → Enable "Enable Dev Mode MCP Server"
#    - Restart Figma, open a file, enable Dev Mode

# 3. Add Figma MCP to Claude
claude mcp add --transport sse figma-dev-mode-mcp-server http://127.0.0.1:3845/sse

# 4. Verify
claude mcp list
```

Now you can use `@frontend-visual` with both Playwright and Figma integration!

## Installation

### Simple Installation (Recommended)

Use Claude Code's built-in MCP management commands:

#### 1. Install Playwright MCP

```bash
claude mcp add playwright npx @playwright/mcp@latest
```

This automatically configures Playwright MCP for visual testing.

#### 2. Install Figma Dev Mode MCP

**Requirements:**
- Figma Desktop app (latest version)
- **Dev seat or Full seat** Figma account (Free/Viewer accounts cannot use Dev Mode)
- At least one design file in Figma

**Setup Figma MCP Server:**

1. **Update Figma Desktop**: Ensure you have the latest version
   - Figma Desktop → Help → Check for Updates

2. **Open Figma Desktop app** (required - web version doesn't support MCP server)

3. **Open a design file**: The MCP server requires an active file

4. **Enable MCP Server**:
   - Go to **Preferences** (macOS: Figma → Preferences, Windows: Settings)
   - Find **"Enable Dev Mode MCP Server"** option
   - Toggle it **ON**
   - Restart Figma Desktop if prompted

5. **Enable Dev Mode** (toggle in top-right corner)

6. The local MCP server is now available at `http://127.0.0.1:3845/sse`

**Add to Claude Code:**

```bash
claude mcp add --transport sse figma-dev-mode-mcp-server http://127.0.0.1:3845/sse
```

**Verify Installation:**

```bash
# List all MCP servers
claude mcp list

# You should see:
# - figma-dev-mode-mcp-server (http://127.0.0.1:3845/sse)
```

**Important Notes:**
- **Figma Desktop app is required** - the MCP server feature is not available in the web version
- **Dev or Full seat required** - Free/Viewer accounts don't have Dev Mode access
- The MCP server only runs when Figma Desktop is open with a file
- Dev Mode must be enabled for Claude to access design data

**Reference:** [Full setup guide](https://www.builder.io/blog/claude-code-figma-mcp-server)

### Manual Installation (Alternative)

If you prefer manual configuration:

**Location:** `~/.claude/mcp.json` (or project-specific `.claude/mcp.json`)

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp@latest"],
      "env": {}
    },
    "figma-dev-mode-mcp-server": {
      "transport": "sse",
      "url": "http://127.0.0.1:3845/sse"
    }
  }
}
```

### Verify Installation

Start Claude Code and check that both MCP servers' tools are available:

```bash
claude

# In Claude, you should see these tools available:

# Playwright tools:
# - mcp__playwright__navigate
# - mcp__playwright__screenshot
# - mcp__playwright__click
# - mcp__playwright__fill
# - mcp__playwright__evaluate
# - etc.

# Figma tools:
# - mcp__figma__get_file
# - mcp__figma__get_file_styles
# - mcp__figma__get_node
# - mcp__figma__get_image
# - etc.
```

## Usage with @frontend-visual Agent

### Workflow 1: Implementing from Figma

1. **Provide Figma URL:**
   ```bash
   claude @frontend-visual
   ```

   ```
   "Implement this login form from Figma:
   https://www.figma.com/file/ABC123DEF456/Project?node-id=123:456"
   ```

2. **Agent will:**
   - Extract file_key and node_id from URL
   - Use Figma MCP to get design system and component details
   - Extract colors, spacing, typography from Figma
   - Implement the component using project's tech stack
   - Verify with Playwright screenshots
   - Compare implementation with Figma design
   - Report findings and iterations needed

### Workflow 2: Verifying Existing Implementation

1. **Start your dev server:**
   ```bash
   npm run dev
   # Server running at http://localhost:3000
   ```

2. **Use the visual agent:**
   ```bash
   claude @frontend-visual
   ```

3. **Provide context:**
   ```
   "I just implemented a login form at /login.
   Please verify it matches the design system and test all states."
   ```

4. **Agent will:**
   - Load project design system (.claude/custom/design-system.md or tailwind.config.js)
   - Navigate to http://localhost:3000/login
   - Take screenshots
   - Measure spacing, colors, typography
   - Verify against project design system
   - Test interactions (hover, focus, validation)
   - Test responsive breakpoints
   - Report findings

### Workflow 3: Design System Extraction

1. **Provide Figma file URL:**
   ```bash
   claude @frontend-visual
   ```

   ```
   "Extract the design system from this Figma file:
   https://www.figma.com/file/ABC123DEF456/Design-System"
   ```

2. **Agent will:**
   - Use Figma MCP to get file styles
   - Extract color palette
   - Extract typography scale
   - Extract spacing system
   - Extract component patterns
   - Create `.claude/custom/design-system.md` documentation
   - Report complete design system

### Example Session with Figma

```bash
$ claude @frontend-visual

You: Implement this dashboard from Figma:
https://www.figma.com/file/ABC123/Project?node-id=123:456

Agent: I'll implement the dashboard from Figma.

[Agent uses Figma MCP first:]
1. mcp__figma__get_file({ file_key: "ABC123" })
2. mcp__figma__get_file_styles({ file_key: "ABC123" })
   - Extracted design system: Colors, typography, spacing
3. mcp__figma__get_node({ file_key: "ABC123", node_id: "123:456" })
   - Dashboard structure, layout, dimensions
4. mcp__figma__get_image({ file_key: "ABC123", node_ids: ["123:456"] })
   - Reference screenshot saved

Agent: Design system extracted:
- Primary color: #2563EB
- Font: Inter, sizes 14/16/20/24/32px
- Spacing: 4/8/16/24/32/48px
- Layout: 240px sidebar, 64px header

[Agent implements Dashboard.tsx using extracted values]

[Agent uses Playwright MCP to verify:]
1. npm run dev
2. mcp__playwright__navigate({ url: "http://localhost:3000/dashboard" })
3. mcp__playwright__screenshot({ name: "dashboard-implementation" })
4. mcp__playwright__evaluate({ script: "..." }) # Measure spacing

Agent: Verification complete:
✅ Layout structure matches Figma
✅ Colors match design system (#2563EB primary)
✅ Sidebar is 240px as specified
✅ Header is 64px as specified
✅ Spacing follows 4/8/16 scale
✅ Typography uses Inter font with correct sizes

Implementation is pixel-perfect and matches Figma design.
```

### Example Session with Screenshot

```bash
$ claude @frontend-visual

You: I implemented a dashboard at /dashboard. Verify against the design system.

Agent: I'll verify your dashboard implementation.

[Agent loads project design system:]
1. Read('.claude/custom/design-system.md')
   - Project uses: #3B82F6 primary, Roboto font, 8px spacing scale

[Agent uses Playwright MCP:]
1. mcp__playwright__navigate({ url: "http://localhost:3000/dashboard" })
2. mcp__playwright__screenshot({ name: "dashboard-current" })
3. mcp__playwright__evaluate({ script: "..." }) # Measure spacing

Agent: Verification results:
✅ Layout structure is correct
✅ Colors match project design system (#3B82F6)
❌ Header padding is 16px, should be 24px (3 * 8px per design system)
❌ Sidebar is 220px wide, should be 240px (30 * 8px)
✅ Font is Roboto as specified
✅ Mobile responsive works correctly

I can fix these spacing issues. Should I proceed?
```

## Available MCP Tools

### Figma MCP Tools

#### Get File
```typescript
mcp__figma__get_file({
  file_key: "ABC123DEF456"  // From Figma URL
})
// Returns: File metadata, document structure, pages, frames
```

#### Get File Styles (Design Tokens)
```typescript
mcp__figma__get_file_styles({
  file_key: "ABC123DEF456"
})
// Returns:
// - Color styles (fills, strokes)
// - Text styles (typography)
// - Effect styles (shadows, blurs)
// - Grid styles (layout grids)
```

#### Get Node
```typescript
mcp__figma__get_node({
  file_key: "ABC123DEF456",
  node_id: "123:456"  // From Figma URL after node-id=
})
// Returns: Specific node/component details, layout, styles, children
```

#### Get Image Export
```typescript
mcp__figma__get_image({
  file_key: "ABC123DEF456",
  node_ids: ["123:456", "123:457"],
  format: "png",  // or "svg", "jpg", "pdf"
  scale: 2  // 1, 2, 3, 4 for @2x, @3x, @4x
})
// Returns: URLs to exported images
```

#### Get Comments
```typescript
mcp__figma__get_comments({
  file_key: "ABC123DEF456"
})
// Returns: All comments on the file (useful for design feedback)
```

### Playwright MCP Tools

#### Navigation
```typescript
mcp__playwright__navigate({
  url: "http://localhost:3000/page",
  browser?: "chromium" | "firefox" | "webkit"
})
```

#### Screenshots
```typescript
mcp__playwright__screenshot({
  name: "component-state",
  fullPage?: boolean,
  selector?: string  // Screenshot specific element
})
```

### Interactions
```typescript
mcp__playwright__click({ selector: "button.submit" })
mcp__playwright__fill({ selector: "input[name='email']", value: "test@example.com" })
mcp__playwright__hover({ selector: ".card" })
mcp__playwright__focus({ selector: "input" })
```

### Evaluation
```typescript
mcp__playwright__evaluate({
  script: `
    const element = document.querySelector('.card');
    const styles = window.getComputedStyle(element);
    return {
      padding: styles.padding,
      margin: styles.margin,
      backgroundColor: styles.backgroundColor
    };
  `
})
```

### Viewport
```typescript
mcp__playwright__setViewportSize({
  width: 375,
  height: 667
})
```

### Waiting
```typescript
mcp__playwright__waitForSelector({
  selector: ".loading",
  state: "hidden"
})
```

## Best Practices

### 1. Start Dev Server First
Always ensure your development server is running before using visual testing:

```bash
# Terminal 1: Dev server
npm run dev

# Terminal 2: Claude with visual agent
claude @frontend-visual
```

### 2. Use with Storybook
For component library testing, use Storybook:

```bash
# Terminal 1: Storybook
npm run storybook

# Terminal 2: Visual testing
claude @frontend-visual
# "Test all Button component variants at http://localhost:6006"
```

### 3. Design Comparison Workflow
When implementing from design:

1. Save design mockup in project: `/designs/page-name.png`
2. Implement the page/component
3. Use @frontend-visual to capture implementation
4. Provide both images to agent for comparison
5. Agent measures differences and suggests fixes

### 4. Visual Regression Testing
After making changes:

```bash
# Before changes
@frontend-visual "Capture baseline screenshots of dashboard"

# Make your changes...

# After changes
@frontend-visual "Compare current dashboard with baseline"
```

## Troubleshooting

### Playwright MCP Issues

#### MCP Server Not Found

**Error:** `playwright MCP server not available`

**Solution:**
```bash
# Install globally
npm install -g @playwright/mcp-server

# Or use npx (no installation needed)
# Update mcp.json to use npx
```

### Figma MCP Issues

#### Figma Dev Mode MCP Server Not Found

**Error:** `figma-dev-mode-mcp-server not available`

**Solution:**
```bash
# Add the Figma Dev Mode MCP server
claude mcp add --transport sse figma-dev-mode-mcp-server http://127.0.0.1:3845/sse
```

#### Cannot Connect to Figma Dev Mode Server

**Error:** `Connection refused` or `Server not available at http://127.0.0.1:3845/sse`

**Solution:**
1. **Use Figma Desktop app**: MCP server is only available in Desktop app, not web version
2. **Enable MCP Server in Figma**:
   - Open Figma Desktop → Settings/Preferences
   - Find "Enable MCP Server" option
   - Toggle it ON
   - Restart Figma Desktop
3. **Ensure Figma is running**: Figma Desktop app must be open
4. **Open a design file**: The MCP server only runs when a file is open
5. **Enable Dev Mode**:
   - Click the "Dev Mode" toggle in top-right of Figma
   - Dev Mode must be active for the MCP server to work
6. **Check port 3845**: Ensure nothing else is using this port
   ```bash
   lsof -i :3845
   ```
7. **Restart Figma Desktop** if the server still isn't starting

#### Figma File Not Open

**Error:** `No active file` or `Cannot access design data`

**Solution:**
- Ensure the Figma file you want to access is currently open in Figma
- The Figma Dev Mode MCP server only provides access to currently open files
- Switch to the correct file tab in Figma if multiple files are open

#### Dev Mode Not Available

**Error:** `Dev Mode not accessible` or `MCP Server option not visible`

**Solution:**
- **Seat type required**: You must have a **Dev seat** or **Full seat** in Figma
- **Free/Viewer accounts** cannot use Dev Mode or the MCP server
- Dev Mode is available on:
  - Figma Professional plans (Dev or Full seats)
  - Organization plans (Dev or Full seats)
  - Enterprise plans (Dev or Full seats)
- Check your seat type:
  - Figma → Settings → Account → Your plan and seat type
- Solutions:
  - Ask your team admin to upgrade you to a Dev seat
  - Use a team workspace with appropriate seats
  - Subscribe to Figma Professional plan ($12/month with Dev seat)

### Port Already in Use

**Error:** `EADDRINUSE: address already in use`

**Solution:**
```bash
# Find and kill process on port 3000
lsof -ti:3000 | xargs kill -9

# Or use different port
npm run dev -- -p 3001
```

### Screenshots Not Saved

Screenshots are saved in Claude Code's context and shown to you visually. They're not saved to your filesystem by default.

To save screenshots:
```typescript
// Agent will show you the screenshot
// You can ask: "Save that screenshot to /screenshots/filename.png"
```

### Browser Not Launching

**Error:** `Browser not found`

**Solution:**
```bash
# Install Playwright browsers
npx playwright install
npx playwright install-deps
```

## Integration with CI/CD

For automated visual testing in CI:

```yaml
# .github/workflows/visual-tests.yml
name: Visual Tests

on: [push, pull_request]

jobs:
  visual-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3

      - name: Install dependencies
        run: npm ci

      - name: Install Playwright
        run: npx playwright install --with-deps

      - name: Build and start dev server
        run: |
          npm run build
          npm run start &
          npx wait-on http://localhost:3000

      - name: Run visual tests with Claude Code
        run: |
          # Use Claude Code API or script to run visual tests
          claude-code --agent frontend-visual --prompt "Test all pages"
```

## Tips for Pixel-Perfect Implementation

1. **Exact measurements:** Use Playwright to measure actual vs expected
2. **Color verification:** Get computed colors and compare with design
3. **Responsive testing:** Test all breakpoints systematically
4. **State testing:** Test hover, focus, disabled, error states
5. **Cross-browser:** Test in Chromium, Firefox, and WebKit

## Support

- Playwright MCP: https://github.com/microsoft/playwright-mcp
- Claude Code MCP: https://docs.claude.com/claude-code/mcp
- Issues: Create issue in this repository

## Example Project Structure

```
your-project/
├── src/
│   ├── app/
│   ├── components/
│   └── features/
├── designs/              # Design mockups
│   ├── dashboard.png
│   └── login.png
├── screenshots/          # Visual test screenshots
│   ├── baseline/
│   └── current/
├── .claude/
│   ├── agents/
│   │   └── frontend-visual.md
│   └── mcp.json         # Playwright MCP config
└── package.json
```
