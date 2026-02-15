# Changelog

All notable changes to the smi-nextjs plugin will be documented in this file.

## [Unreleased]

### Changed
- Renamed from `smi-nextjs` to `nextjs` as part of ai-kit migration
- Moved from `plugins/smi-nextjs/` to `packs/nextjs/`

## [2.1.0] - 2025-01-02

### Added
- 3 auto-enforcing skills
  - `accessibility-validator` - WCAG 2.1 AA compliance
  - `react-form-validator` - React Hook Form + Zod
  - `import-convention-enforcer` - @/ path alias

### Added
- `@frontend-visual` agent for Playwright + Figma MCP integration

## [2.0.0] - 2024-12-01

### Changed
- BREAKING: Standardized on TanStack Query for data fetching
- Updated component patterns for App Router

### Added
- `@nextjs-modular` agent for large-scale architecture

## [1.0.0] - 2024-10-01

### Added
- Initial stable release
- 4 agents: architect, modular, visual, tester
- 1 command: component-create
