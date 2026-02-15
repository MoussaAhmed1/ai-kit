# onboard

Intelligent engineer onboarding that cuts ramp-up time by personalizing project guidance based on the engineer's background and first task.

## The Problem

Onboarding a new engineer typically requires:
- 1-2 hours of the project lead's time explaining architecture
- The engineer reading docs that explain things they already know
- Trial and error to find conventions and patterns
- Repeated "where does this go?" questions

## The Solution

One command: `/onboard`

- Asks 3-5 adaptive questions about the engineer's background
- Auto-analyzes the project (tech stack, conventions, patterns)
- Identifies knowledge gaps and explains only what's new
- Generates a personalized cheat sheet and task plan

## Installation

```bash
/plugin install onboard
```

## Usage

### First-Time Onboarding

```bash
/onboard
```

Interactive flow (~3-5 minutes):
1. Background assessment (adaptive — asks more only if gaps detected)
2. Automatic project analysis
3. Knowledge gap identification
4. Task-specific guidance generation

### Quick Mode

```bash
/onboard --quick
```

Skips skill assessment. Assumes mid-level generalist.

### With Pre-specified Task

```bash
/onboard --task "Implement user authentication"
```

Skips the task question, jumps straight to analysis and guidance.

### Ongoing Questions

After onboarding, use the agent for follow-up questions:

```
@onboard-guide "How do I add a new API endpoint?"
@onboard-guide "What's the testing pattern here?"
@onboard-guide "Where should this file go?"
```

Answers are personalized based on your onboarding profile.

## Generated Artifacts

All saved to `.claude/` (local, gitignored):

| File | Purpose |
|------|---------|
| `onboard-profile.local.md` | Your background + knowledge gaps |
| `onboard-cheatsheet.local.md` | Quick reference for commands and conventions |
| `onboard-task-plan.local.md` | Step-by-step plan for your first task |

## How Personalization Works

The plugin maps new concepts to what you already know:

| You Know | Project Uses | You'll See |
|----------|-------------|------------|
| Django views | Next.js Server Components | "Like Django views but in JSX" |
| React state | Django ORM | "Like useState but for database records" |
| REST APIs | GraphQL | "Same data, different query language" |
| JavaScript | TypeScript | "Your JS + type annotations" |

Senior engineers get concise syntax-focused answers. Junior engineers get more context and "why" explanations.

## Components

| Component | Type | Purpose |
|-----------|------|---------|
| `/onboard` | Command | Interactive onboarding flow |
| `@onboard-guide` | Agent | Ongoing personalized Q&A |
| `onboard-context-provider` | Skill | Auto-personalizes explanations |

## Integration

Works with all Smicolon framework plugins. When the project uses `django`, `nextjs`, or others, the onboarding automatically includes framework-specific conventions.
