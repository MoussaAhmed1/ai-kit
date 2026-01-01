---
description: "Start dev loop for iterative development"
argument-hint: '"Your prompt here" [--from-plan] [--max-iterations N] [--promise TEXT]'
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup-dev-loop.sh:*)"]
hide-from-slash-command-tool: "true"
---

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-dev-loop.sh" $ARGUMENTS
```

# Dev Loop Started

You are now in a development loop. The loop will continue until you output `<promise>DONE</promise>` or reach the maximum iterations (default: 50).

## How It Works

1. **You receive a prompt** - Work on the task iteratively
2. **Complete work** - When done, output `<promise>DONE</promise>`
3. **Loop continues** - If you don't output the promise, you'll get the prompt again
4. **Max safety** - After 50 iterations, the loop stops automatically

## Completion

When your work is complete, output:

```
<promise>DONE</promise>
```

This ends the loop successfully.

## Flags

```bash
# Use existing plan from /dev-plan command
/dev-loop --from-plan

# Override max iterations (default: 50)
/dev-loop "Build feature X" --max-iterations 30

# Custom completion promise (default: DONE)
/dev-loop "Refactor module Y" --promise "REFACTOR_COMPLETE"
```

## Recommended Workflow

For best results, use the planning phase first:

```bash
# 1. Generate structured TDD plan
/dev-plan "Build user authentication"

# 2. Review and edit .claude/dev-plan.local.md if needed

# 3. Execute with structured plan
/dev-loop --from-plan
```

This creates a plan with:
- TDD phases (Red-Green-Refactor)
- Clear verification commands
- Self-correction rules
- Stuck handling

## Tips

- Use `/dev-plan` first for complex tasks
- Break complex tasks into smaller steps
- Test your work before declaring completion
- Use `<promise>DONE</promise>` only when truly finished
- If stuck, the loop will eventually timeout at max iterations
