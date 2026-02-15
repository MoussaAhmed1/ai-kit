# Changelog

All notable changes to smi-onboard will be documented in this file.

## [Unreleased]

### Changed
- Renamed from `smi-onboard` to `onboard` as part of ai-kit migration
- Moved from `plugins/smi-onboard/` to `packs/onboard/`

## [0.1.0] - 2026-02-02

### Added
- `/onboard` command for interactive engineer onboarding
- `@onboard-guide` agent for ongoing personalized Q&A
- `onboard-context-provider` skill for background-aware assistance
- Auto-detection of project type and tech stack
- Adaptive skill assessment (3 core + conditional follow-ups)
- Knowledge gap analysis with priority levels
- Personalized explanations using analogies to engineer's background
- Generated artifacts: profile, cheatsheet, task plan
- Support for `--quick` and `--task` flags
