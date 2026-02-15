---
"@smicolon/ai-kit": patch
---

Fix plugin hooks not being detected on install (showing "Hooks: 0")

- Remove explicit hooks declarations from marketplace.json — Claude Code auto-discovers hooks/hooks.json by convention
- Remove empty hono hooks directory
