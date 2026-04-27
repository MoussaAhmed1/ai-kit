---
name: clarify
description: Resolve ambiguity in a task before implementation. Detects whether the task has a single clear flow (explains and proceeds) or multiple flows (lists them and asks the user to pick one). Produces a structured execution context (Markdown + JSON) under .claude/clarifications/.
argument-hint: '["<task description or ticket ref>"] [--quick]'
allowed-tools: ["Read", "Write", "Glob", "Grep", "Bash", "AskUserQuestion"]
---

# Pre-Implementation Clarification

Run a structured pre-implementation clarification on the task in `$ARGUMENTS`.

The tool **never jumps straight into questioning**. It always begins with flow analysis. Only when multiple distinct flows are plausible does it ask a single question to disambiguate.

---

## Behavioral Contract (do not deviate)

1. **Always** run flow analysis first.
2. If exactly one flow is detected → explain it briefly and generate the artifact. **No `AskUserQuestion`.**
3. If two or more flows are detected → list them, then issue **one** `AskUserQuestion` with each flow as an option.
4. Never ask cluster-by-cluster questions (entity, trigger, channel, recipient, etc.). Each flow already encodes those answers; the user picks the whole flow, not its parts.

Violating this contract is a behavioral regression — preserve it during any future edit.

---

## Steps

### 1. Parse Arguments

From `$ARGUMENTS`:
- **Free text** (`/clarify "Send message on sign-in"`) → use as the task description directly.
- **Ticket ref** matching `^[A-Z]+-\d+$` (e.g. `ENG-123`):
  - If a Linear or GitHub MCP server is available, fetch the ticket title + description and use as the task.
  - If no MCP is connected, ask the user to paste the ticket description as free text. Do not error.
- **No argument** → prompt: "Describe the task you'd like to clarify (paste the title and any context you have):"
- **`--quick`** → reserved flag; v1 ignores it. Kept for forward compatibility.

### 2. Flow Analysis (always first, no questions yet)

Invoke the **`flow-detector`** skill with the task description. It will:
- Scan the repo for relevant entities (User, Tenant, Org, Account…), services, auth surfaces, notification channels.
- Emit an ordered list of 1+ candidate flows. Each candidate is a fully-formed proposed execution context (entity, trigger, action, recipient, failure handling) — not a question.

The output schema is `[{ id, title, one_line_diff, full_context }, …]`, ordered by repo-evidence strength.

### 3. Branch on the candidate count

#### Single candidate (the common case for unambiguous tasks)

Print a 2–4 line explanation, then proceed straight to step 4. **Do not invoke `AskUserQuestion`.**

Example:
```
This task has a single clear flow:
User sign-in → post-auth message sent to the user (in-app notification).
Proceeding to execution context generation.
```

#### Two or more candidates (the ambiguous case)

Invoke the **`flow-selector`** skill. It will:
- Print all candidates as a numbered list with one-line differentiators.
- Issue **one** `AskUserQuestion` with each candidate's title as an option. The "Other" escape hatch is added automatically; if the user picks it, prompt for free text and treat the answer as a synthesized candidate.

Example output before the question:
```
This task has multiple possible flows:
1. User sign-in flow → message sent to the user after authentication
2. Tenant notification flow → message sent to tenant owner when a user signs in

Which flow would you like to proceed with?
```

After the user picks, continue to step 4 with the chosen `full_context`.

### 4. Synthesize the Execution Context

Invoke the **`execution-context-builder`** skill with the chosen (or only) `full_context`. It will:
- Slug the task title to kebab-case, max 60 chars (e.g. `Send message on sign-in` → `send-message-on-sign-in`). If the title yields no usable slug, fall back to `clarification-YYYYMMDD-HHMMSS`.
- Read the templates at `references/execution-context.md` and `references/execution-context.json`.
- Write `.claude/clarifications/<slug>.local.md` and `.claude/clarifications/<slug>.local.json`.
- Validate the JSON parses before writing. Refuse to overwrite an existing file unless the user explicitly opts in.

### 5. Print Summary

Output:
```
✓ Execution context written:
  .claude/clarifications/<slug>.local.md
  .claude/clarifications/<slug>.local.json

Downstream packs (if installed) can consume this:
  - dev-loop: pre-populates plan goal + out-of-scope
  - failure-log: tracks resolved assumptions
```

---

## Tips

- Run `/clarify` **before** writing any code on a non-trivial task. The output is a contract, not a checklist.
- Commit `.claude/clarifications/*.local.md` to share intent with reviewers, or leave it gitignored as personal scratch — both are valid.
- For a re-clarification, delete the existing file or re-run with a different task title.
