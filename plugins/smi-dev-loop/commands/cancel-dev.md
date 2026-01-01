---
description: "Cancel active dev loop"
---

```!
if [ -f ".claude/dev-loop.local.md" ]; then
  rm ".claude/dev-loop.local.md"
  echo "Dev loop cancelled."
else
  echo "No active dev loop to cancel."
fi
```

# Dev Loop Cancelled

The dev loop has been cancelled. You can start a new loop with:

```bash
/dev-loop "Your prompt here"
```
