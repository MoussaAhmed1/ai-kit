# Versioning Strategy

This document defines how versions are managed across the Smicolon marketplace and its plugins.

## Overview

We use **independent versioning** - each plugin has its own semantic version that reflects its maturity and changes. The marketplace version tracks the overall release.

## Version Meanings

### Plugin Versions

| Version Range | Meaning | Expectations |
|---------------|---------|--------------|
| **0.x.x** | New/Experimental | May have breaking changes, needs real-world testing, API not finalized |
| **1.0.0** | Stable | Production-ready, API stable, breaking changes only in major bumps |
| **2.x.x+** | Mature | Battle-tested, well-documented, widely used |

### When to Use Each

**Start at 0.1.0** when:
- Plugin is newly created
- Not yet tested in real projects
- API/conventions may change based on feedback

**Promote to 1.0.0** when:
- Used successfully in 2-3 real projects
- No major issues reported
- Conventions are finalized
- Documentation is complete

**Increment to 2.0.0+** when:
- Major redesign or breaking changes
- Significant new capabilities
- After extended production use

## Semantic Versioning Rules

### PATCH (x.x.+1)
Backward-compatible bug fixes and minor improvements.

**Examples:**
- Fixed typo in agent prompt
- Corrected example code in skill
- Updated documentation
- Fixed edge case in command

**When to use:** No behavior change, purely fixes.

### MINOR (x.+1.0)
Backward-compatible new features.

**Examples:**
- Added new skill
- Added new command
- Enhanced agent with new capabilities
- New optional configuration option

**When to use:** New features that don't break existing usage.

### MAJOR (+1.0.0)
Breaking changes that require user action.

**Examples:**
- Renamed agent (e.g., `@django-dev` → `@django-builder`)
- Changed command arguments
- Removed deprecated features
- Changed required conventions
- Major restructure of plugin

**When to use:** Existing users need to update their usage.

## Marketplace Version

The root marketplace version in `.claude-plugin/marketplace.json` tracks:
- Overall release coordination
- Major milestones (e.g., "11 plugins now available")
- Compatibility baselines

Bump marketplace version when:
- Adding new plugins
- Major feature releases
- Significant changes across multiple plugins

## Changelog Requirements

Each plugin MUST maintain a `CHANGELOG.md` file:

```
plugins/smi-django/CHANGELOG.md
plugins/smi-nestjs/CHANGELOG.md
...
```

### Changelog Format

```markdown
# Changelog

All notable changes to this plugin will be documented in this file.

## [Unreleased]
### Added
- New feature in development

## [1.0.0] - 2025-01-15
### Changed
- BREAKING: Renamed `@django-dev` to `@django-builder`

### Added
- New `security-first-validator` skill

## [0.2.0] - 2025-01-10
### Added
- New `/api-endpoint` command

### Fixed
- Typo in architect agent prompt

## [0.1.0] - 2025-01-01
### Added
- Initial release
- 5 agents: architect, builder, feature-based, tester, reviewer
- 3 commands: model-create, api-endpoint, test-generate
- 8 skills for convention enforcement
```

## Version Bump Checklist

Before committing changes to a plugin:

- [ ] Updated version in `.claude-plugin/marketplace.json`
- [ ] Added entry to `plugins/{name}/CHANGELOG.md`
- [ ] Used correct bump type (patch/minor/major)
- [ ] Updated marketplace version if adding new plugin

## Current Plugin Status

| Plugin | Version | Status | Notes |
|--------|---------|--------|-------|
| smi-django | 2.1.0 | Mature | Production-tested |
| smi-nestjs | 2.1.0 | Mature | Production-tested |
| smi-nextjs | 2.1.0 | Mature | Production-tested |
| smi-nuxtjs | 2.1.0 | Mature | Production-tested |
| smi-dev-loop | 1.1.0 | Stable | TDD automation |
| smi-architect | 1.0.0 | Stable | Diagram generation |
| smi-failure-log | 1.0.0 | Stable | Failure memory |
| smi-hono | 0.1.0 | New | Needs testing |
| smi-flutter | 0.1.0 | New | Needs testing |
| smi-tanstack-router | 0.1.0 | New | Needs testing |
| smi-better-auth | 0.1.0 | New | Needs testing |

## Promotion Criteria

To promote a plugin from 0.x to 1.0.0:

1. **Usage** - Used in at least 2 real projects
2. **Stability** - No major bugs or breaking changes in last 30 days
3. **Documentation** - README and all skills fully documented
4. **Completeness** - Core use cases covered
5. **Feedback** - Addressed initial user feedback
