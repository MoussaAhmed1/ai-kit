# Changelog

All notable changes to the smi-tanstack-router plugin will be documented in this file.

## [Unreleased]

### Changed
- Renamed from `smi-tanstack-router` to `tanstack-router` as part of ai-kit migration
- Moved from `plugins/smi-tanstack-router/` to `packs/tanstack-router/`

## [0.1.0] - 2025-01-02

### Added
- Initial release (experimental)
- 3 agents: tanstack-architect, tanstack-builder, tanstack-tester
- 4 commands: route-create, query-create, form-create, table-create
- 11 skills for TanStack ecosystem:
  - `router-patterns` - File-based routing
  - `query-patterns` - Data fetching with factory keys
  - `form-patterns` - TanStack Form + Zod
  - `table-patterns` - Headless tables
  - `virtual-patterns` - List virtualization
  - `store-patterns` - State management (alpha)
  - `db-patterns` - Client-first database (beta)
  - `ai-patterns` - AI/LLM integration (alpha)
  - `pacer-patterns` - Rate limiting (beta)
  - `devtools-patterns` - Developer tools
  - `tanstack-conventions` - Project conventions
- Bun as package manager and runtime
- Feature-based project structure
