# clarify

Pre-implementation clarification for vague tasks. Detects whether a task has one clear flow or several plausible ones, and produces a structured execution context the developer can implement against — before any code is written.

## The Problem

Engineers pick up Linear/Jira/GitHub tickets and start coding before the scope is locked down. Implicit assumptions about which entity, trigger, channel, or recipient the task refers to surface only after the PR is up and reviewers point them out. The cost is wasted implementation time, inconsistent decisions across the team, and rework.

There is no lightweight, AI-tool-agnostic way to force the clarification step before code is written.

## The Solution

One command: `/clarify`.

- Always runs **flow analysis first**.
- If the task has a single clear flow, it explains the flow in 2–4 lines and writes the artifact. **No questions asked.**
- If the task has multiple plausible flows, it lists them with one-line differentiators and asks **one** question (`AskUserQuestion`) to disambiguate. Each option is a whole flow, not a single dimension.
- The output is a Markdown + JSON pair under `.claude/clarifications/`, ready for human review and downstream agent consumption.

The pack does **not** ask cluster-by-cluster questions about entity, trigger, channel, recipient, or failure handling. Those are encoded in each candidate flow.

## Installation

```bash
/plugin install clarify
```

Or via the ai-kit CLI:

```bash
ai-kit add clarify
```

The pack ships to all 15 supported AI tools (Claude Code, Cursor, Windsurf, Copilot, Codex, Cline, Continue, Gemini, Junie, Kiro, Amp, Antigravity, Augment, Roo Code, Amazon Q).

## Usage

### Single-flow case (no question asked)

```
/clarify "Add a 'Forgot password' link to the login form"
```

Output:
```
This task has a single clear flow:
User → click 'Forgot password' on existing /login page → existing /forgot-password handler.
Proceeding to execution context generation.

✓ Execution context written:
  .claude/clarifications/add-a-forgot-password-link-to-the-login-form.local.md
  .claude/clarifications/add-a-forgot-password-link-to-the-login-form.local.json
```

The flow was unambiguous — there's only one auth surface and the handler already exists — so `/clarify` proceeds straight to artifact generation without asking anything.

### Multi-flow case (one question asked)

```
/clarify "Send message on sign-in"
```

Output:
```
This task has multiple possible flows:

1. User sign-in flow — in-app message to the signing-in user
   Recipient is the user who signed in; channel is in-app

2. Tenant audit flow — email to the tenant owner when a member signs in
   Recipient is the tenant owner; channel is email

Which flow would you like to proceed with?
```

`AskUserQuestion` then renders the two options as selectable. The user picks one and `/clarify` writes the artifact for that flow. **No follow-up questions** — the chosen candidate already encodes entity, trigger, channel, recipient, and failure handling.

### Non-Claude-Code tools

In Cursor / Copilot / Codex / Gemini / Amp, invoke the agent instead:

```
@clarifier "Send message on sign-in"
```

Same behavior, same artifact path.

### From a ticket reference

```
/clarify ENG-123
```

If a Linear or GitHub MCP server is connected, the ticket title and description are fetched automatically. Without an MCP, `/clarify` falls back to asking for the description as free text — never errors.

## Generated Artifacts

All saved to `.claude/clarifications/` (local; gitignore or commit, your choice):

| File | Purpose |
|------|---------|
| `<slug>.local.md` | Human-readable execution contract |
| `<slug>.local.json` | Machine-readable, schema-validated context for downstream agents |

Slug rules: kebab-case from the task title, max 60 chars. Falls back to `clarification-YYYYMMDD-HHMMSS` if the title yields no usable slug.

## Components

| Component | Type | Purpose |
|-----------|------|---------|
| `/clarify` | Command | Slash command entry point (Claude Code) |
| `@clarifier` | Agent | Manual entry point for non-slash-command tools |
| `flow-detector` | Skill | Emits 1+ candidate flows grounded in repo evidence |
| `flow-selector` | Skill | Issues exactly one question when 2+ candidates exist |
| `execution-context-builder` | Skill | Writes the Markdown + JSON artifacts |
| `pre-implementation` | Rule | Soft nudge to run `/clarify` before non-trivial implementation |

## How Flow Detection Stays Grounded

`flow-detector` does not invent infrastructure. Before generating candidates it scans the repo for:

- **Entities**: User, Tenant, Org, Account, Workspace, Team, Member.
- **Auth surfaces**: sign-in, login, signup, register, authenticate routes.
- **Notification channels**: email senders (SendGrid, SES, Resend), push (FCM, APNs), in-app, SMS (Twilio).
- **Async infrastructure**: queues (BullMQ, Celery, Sidekiq), background jobs.
- **Failure infrastructure**: retry libs, dead-letter queues, error reporters.

A candidate that mentions a service the repo doesn't have is either reframed as "build new X" or dropped. The user is never asked to fill in missing infrastructure — the candidates do that work.

Cap: max 4 candidates per task. If more are plausible, the top 4 by repo-evidence strength are kept.

## Optional Cross-Pack Integrations

- **`failure-log`**: if `.claude/failure-log.local.md` exists, `/clarify` appends a one-liner under "Pattern Mistakes" recording the resolved assumption. Silent if the file is absent.
- **`dev-loop`**: a TDD plan generated within 24h of a clarification artifact reads the JSON sidecar and pre-populates the plan's Goal and Out-of-scope sections. Optional; activated by the dev-loop pack reading the clarification path.

## Out of Scope (deferred to future versions)

| Feature | Phase |
|---------|-------|
| Linear/Jira/GitHub MCP integration for direct ticket fetching | 2 |
| Auto-posting clarification summary back to the ticket | 2 |
| Stack-specific question templates (NestJS-aware, Django-aware) | 3 |
| Telemetry on most-asked-about flow types | 3 |
| Hooks-based proactive nudge (auto-run `/clarify` on session start) | 1.1 |

## Versioning

This pack is at `0.1.0` (experimental). The execution-context JSON schema is versioned at `https://smicolon.com/schemas/clarify/execution-context-v1.json` — breaking changes to the schema bump the major version.

## License

MIT
