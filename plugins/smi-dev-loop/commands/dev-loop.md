---
description: "Start dev loop for iterative development"
argument-hint: '"Your prompt here"'
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

## Optional Flags

```bash
# Override max iterations (default: 50)
/dev-loop "Build feature X" --max-iterations 30

# Custom completion promise (default: DONE)
/dev-loop "Refactor module Y" --promise "REFACTOR_COMPLETE"
```

## Tips

- Break complex tasks into smaller steps
- Test your work before declaring completion
- Use `<promise>DONE</promise>` only when truly finished
- If stuck, the loop will eventually timeout at max iterations
