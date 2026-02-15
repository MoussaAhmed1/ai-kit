# Changelog

All notable changes to the smi-django plugin will be documented in this file.

## [Unreleased]

### Changed
- Renamed from `smi-django` to `django` as part of ai-kit migration
- Moved from `plugins/smi-django/` to `packs/django/`

## [2.1.0] - 2025-01-02

### Added
- 8 auto-enforcing skills for convention compliance
  - `import-convention-enforcer` - Absolute modular imports
  - `model-entity-validator` - UUID, timestamps, soft delete
  - `security-first-validator` - Permissions, authentication
  - `test-coverage-advisor` - 90%+ coverage guidance
  - `performance-optimizer` - N+1 detection
  - `migration-safety-checker` - Safe migrations
  - `test-validity-checker` - Test quality
  - `red-phase-verifier` - TDD red phase

## [2.0.0] - 2024-12-01

### Changed
- BREAKING: Renamed `@django-dev` to `@django-builder`
- Updated import conventions to use module aliases

### Added
- `@django-feature-based` agent for large-scale architecture
- `/api-endpoint` command

## [1.0.0] - 2024-10-01

### Added
- Initial stable release
- 5 agents: architect, builder, feature-based, tester, reviewer
- 3 commands: model-create, api-endpoint, test-generate
