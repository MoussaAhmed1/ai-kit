# Changelog

All notable changes to the smi-architect plugin will be documented in this file.

## [Unreleased]

### Changed
- Renamed from `smi-architect` to `architect` as part of ai-kit migration
- Moved from `plugins/smi-architect/` to `packs/architect/`

## [1.1.0] - 2026-05-08

### Added
- New command `/explain-code` — explains code with an analogy, ASCII diagram, execution walkthrough, architecture context, gotchas, perf/security notes, and a tiny example
- Optional argument support: `/explain-code <file path | symbol | concept>` to scope the explanation; bare invocation explains the most recently discussed code

## [1.0.0] - 2024-12-01

### Added
- Initial stable release
- 1 agent: system-architect (Eraser.io diagram-as-code)
- 1 command: diagram-create
- Support for ERD, flowcharts, cloud architecture, sequence diagrams, BPMN
