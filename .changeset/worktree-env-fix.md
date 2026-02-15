---
"@smicolon/ai-kit": patch
---

Fix wt.sh infinite loop on .env* directories and remove redundant plugin.json files

- Add `-type f` to find command in rewrite_all_env_files() to skip directories matching .env* glob
- Add file guard in rewrite_env_file() to bail early on non-file paths
- Remove per-plugin .claude-plugin/plugin.json files — marketplace.json is the single source of truth for versions
