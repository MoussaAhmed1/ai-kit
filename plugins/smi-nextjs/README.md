# Next.js Development Standards Plugin

Smicolon company standards for Next.js/React projects.

## Installation

```bash
# Add Smicolon marketplace
/plugin marketplace add smicolon https://github.com/smicolon/claude-infra

# Install Next.js plugin
/plugin install smi-nextjs
```

## What's Included

### 4 Specialized Agents

- `@nextjs-architect` - Next.js/React architecture design
- `@nextjs-modular` - Large-scale Next.js modular architecture
- `@frontend-visual` - Visual QA with Playwright + Figma MCP integration
- `@frontend-tester` - Frontend testing (unit, integration, E2E, accessibility)

### Automatic Convention Enforcement

**Required Standards:**
- TypeScript strict mode (no `any`)
- Zod validation for all forms
- TanStack Query for API calls
- Proper error and loading states
- Tailwind CSS
- WCAG 2.1 AA accessibility

### Visual QA Integration

The `@frontend-visual` agent integrates with:
- **Playwright MCP** for automated browser testing
- **Figma MCP** for design comparison

See [MCP_SETUP.md](../../MCP_SETUP.md) for configuration.

## Usage

```bash
# Design architecture
@nextjs-architect "Design a dashboard with real-time analytics"

# Large-scale architecture
@nextjs-modular "Design modular architecture for e-commerce platform"

# Write comprehensive tests
@frontend-tester "Write tests for authentication flow"

# Visual QA (requires Playwright + Figma MCP)
@frontend-visual "Verify dashboard matches Figma: https://figma.com/file/..."
```

## Documentation

See the main [Smicolon Claude Infra repository](https://github.com/smicolon/claude-infra) for complete documentation.
