---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
  - "**/*.py"
  - "**/*.go"
  - "**/*.rb"
  - "**/*.dart"
  - "**/*.kt"
  - "**/*.swift"
  - "**/*.rs"
---

# Pre-Implementation Clarification

When the developer is about to start implementing a non-trivial task and there is **no matching execution context** at `.claude/clarifications/<slug>.local.md`, suggest running `/clarify` (or `@clarifier` in non-Claude-Code tools) **before** writing code.

This is a soft nudge, not a block. If the developer says "I know what I'm doing" or has already discussed the design, proceed without re-prompting.

## When to Suggest

Suggest `/clarify` when **all** of the following are true:

- The current task description uses vague verbs (send, notify, sync, handle, process, integrate).
- The repo contains multiple plausible interpretations (multiple entities like User and Tenant, multiple notification channels, multiple auth surfaces).
- No file at `.claude/clarifications/<slug>.local.md` matches the current task slug.
- The developer has not already explained the chosen flow in the current conversation.

## What to Say

Keep it one line:

> Before writing code, want to run `/clarify "<task>"` first? It'll detect whether this has one clear flow or several and produce an execution-context artifact under `.claude/clarifications/`.

If the developer declines, drop it. Do not re-prompt for the same task.

## When NOT to Suggest

- Trivial changes: typos, formatting, renames, adding a missing import.
- Bug fixes where the failing test already pins down the flow.
- The developer just ran `/clarify` and the artifact exists at `.claude/clarifications/<slug>.local.md` — read it instead and use it as the implementation contract.
- The developer has explicitly said "skip clarification" or similar.

## Reading an Existing Artifact

If `.claude/clarifications/<slug>.local.md` exists for the current task, read it before suggesting any implementation step. The artifact is the contract; implementation should match it. If the task seems to have drifted from the artifact's scope, surface that to the developer instead of silently expanding scope.
