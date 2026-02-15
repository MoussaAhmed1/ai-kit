# @smicolon/ai-kit

AI coding tool pack manager. Install convention packs (agents, skills, commands, rules, hooks) for any AI coding tool.

## Quick Start

```bash
npx @smicolon/ai-kit init
```

This walks you through selecting your AI tools and stack, then installs the right files in the right places.

## Commands

### `init`

Interactive first-time setup. Prompts for your AI tools, stack, and component preferences.

```bash
npx @smicolon/ai-kit init
npx @smicolon/ai-kit init --cwd apps/web  # monorepo sub-package
```

### `add <pack>`

Add a pack to your project.

```bash
npx @smicolon/ai-kit add django
npx @smicolon/ai-kit add django --skills-only
npx @smicolon/ai-kit add django --agents-only
npx @smicolon/ai-kit add django --rules-only
npx @smicolon/ai-kit add django --tools claude-code,cursor
```

### `list`

Show available or installed packs.

```bash
npx @smicolon/ai-kit list              # available packs
npx @smicolon/ai-kit list --installed   # installed packs
```

### `remove <pack>`

Remove a pack and all its installed files.

```bash
npx @smicolon/ai-kit remove django
```

### `update [pack]`

Update installed packs to latest versions.

```bash
npx @smicolon/ai-kit update          # update all
npx @smicolon/ai-kit update django   # update one
```

## Supported AI Tools

| Tool | Skills | Agents | Commands | Rules | Hooks |
|------|:------:|:------:|:--------:|:-----:|:-----:|
| Claude Code | yes | yes | yes | yes | yes |
| Cursor | yes | - | - | yes (.mdc) | - |
| Windsurf | yes | - | - | yes | - |
| GitHub Copilot | yes | yes | - | - | - |
| Codex | yes | yes | - | - | - |
| Cline | yes | - | - | yes | - |
| Continue | yes | - | - | yes | - |
| Gemini | yes | yes | - | - | - |
| Junie | yes | - | - | yes | - |
| Kiro | yes | - | - | yes | - |
| Amp | yes | yes | - | - | - |
| Antigravity | yes | - | - | yes | - |
| Augment | yes | - | - | yes | - |
| Roo Code | yes | - | - | yes | - |
| Amazon Q | yes | - | - | yes | - |

## Available Packs

| Pack | Agents | Skills | Commands | Rules |
|------|:------:|:------:|:--------:|:-----:|
| django | 5 | 8 | 3 | 6 |
| nestjs | 3 | 2 | 1 | 4 |
| nextjs | 4 | 3 | 1 | 3 |
| nuxtjs | 3 | 3 | 1 | 3 |
| hono | 4 | 4 | 4 | - |
| tanstack-router | 3 | 11 | 4 | - |
| better-auth | 1 | 2 | 2 | - |
| flutter | 3 | 3 | 5 | - |
| architect | 1 | - | 1 | - |
| dev-loop | - | 1 | 3 | - |
| failure-log | - | 1 | 2 | - |
| worktree | - | 1 | 1 | - |
| onboard | 1 | 1 | 1 | - |

## How It Works

Skills use a **canonical + symlink** strategy:

```
your-project/
├── .agents/skills/          # canonical copies
│   ├── import-convention-enforcer/
│   └── model-entity-validator/
├── .claude/skills/          # symlinks → .agents/skills/*
├── .cursor/skills/          # symlinks → .agents/skills/*
├── .claude/agents/          # copied .md files
├── .claude/commands/        # copied .md files
├── .claude/rules/           # copied .md files
├── .cursor/rules/           # converted .mdc files
├── .ai-kit.json             # tracks installed packs + files
└── .gitignore               # auto-updated
```

Config is stored in `.ai-kit.json` which tracks installed packs and all created files for clean removal.

## Monorepo Support

Use `--cwd` to target a sub-package. Both the sub-package and root `.gitignore` are updated.

```bash
npx @smicolon/ai-kit init --cwd apps/web
npx @smicolon/ai-kit add django --cwd apps/web
```

## License

MIT
