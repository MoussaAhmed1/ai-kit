# Changelog

All notable changes to the smi-failure-log plugin will be documented in this file.

## [Unreleased]

### Changed
- Renamed from `smi-failure-log` to `failure-log` as part of ai-kit migration
- Moved from `plugins/smi-failure-log/` to `packs/failure-log/`

## [1.0.0] - 2024-12-20

### Added
- Initial stable release
- 2 commands: failure-add, failure-list
- 1 skill: failure-log-manager
- Automatic context injection of known mistakes
- Semi-automatic failure detection on Write/Edit
- Project-specific storage in `.claude/failure-log.local.md`
- Categories: imports, security, testing, architecture, conventions
