# Changelog

All notable changes to the smi-dev-loop plugin will be documented in this file.

## [1.2.0] - 2026-01-02

### Added
- Quality checklist enforcement for plan generation
- Required file tables: "Files to Modify" and "New Files to Create"
- Code snippets in implementation phases
- Acceptance criteria section with Given/When/Then format
- Framework-specific stuck handling (not generic)
- `references/good-example.md` - High-quality Flutter migration example
- Anti-patterns documentation to avoid vague plans
- **17+ framework auto-detection**: Flutter, React Native, Django, FastAPI, Flask, NestJS, Next.js, Nuxt.js, Hono, Express, TanStack, Go, Rust, Rails, Laravel
- **Custom framework support**: `--test-cmd` and `--lint-cmd` flags for any stack
- Test patterns for Go, Rust, Rails, Laravel, FastAPI, Hono, Flutter

### Changed
- Enhanced `dev-plan.md` command with deep codebase analysis step
- Improved `plan-template.md` with all required sections
- Updated `SKILL.md` with specificity requirements
- Tasks now require file paths and implementation details
- Framework detection now works with any tech stack
- **Package manager auto-detection**: bun (default) > pnpm > yarn > npm based on lockfile

### Fixed
- Plans now consistently include measurable success criteria
- Self-correction rules are phase-specific instead of generic

## [1.1.0] - 2025-01-02

### Added
- `/dev-plan` command for TDD planning phase
- `tdd-planner` skill for structured development plans

### Fixed
- Stop hook transcript parsing
- Progress tracking improvements

## [1.0.0] - 2024-12-15

### Added
- Initial stable release
- 3 commands: dev-loop, dev-plan, cancel-dev
- Autonomous development loop with Red-Green-Refactor
- Stop hook for continuation logic
