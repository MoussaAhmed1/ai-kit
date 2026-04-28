# Changelog

All notable changes to the `clarify` pack will be documented in this file.

## [0.1.0] - 2026-04-27

### Added
- `/clarify` command for pre-implementation clarification with flow-analysis-first behavior
- `@clarifier` agent for non-Claude-Code tools (Cursor, Copilot, Codex, Gemini, Amp)
- `flow-detector` skill — emits 1+ candidate flows grounded in repo evidence
- `flow-selector` skill — issues exactly one `AskUserQuestion` when 2+ candidates exist
- `execution-context-builder` skill — writes Markdown + JSON artifacts under `.claude/clarifications/`
- `pre-implementation` rule — soft nudge to run `/clarify` before non-trivial implementation
- Strict execution-context JSON schema (`execution-context-v1.json`)
- Templates at `skills/execution-context-builder/references/` for both Markdown and JSON outputs
- Optional cross-pack hook into `failure-log` (silent when absent)
