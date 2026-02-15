# Changelog

All notable changes to the smi-hono plugin will be documented in this file.

## [Unreleased]

### Changed
- Renamed from `smi-hono` to `hono` as part of ai-kit migration
- Moved from `plugins/smi-hono/` to `packs/hono/`

## [0.1.0] - 2025-01-02

### Added
- Initial release (experimental)
- 4 agents: hono-architect, hono-builder, hono-tester, hono-reviewer
- 4 commands: route-create, middleware-create, project-init, rpc-client
- 4 skills: hono-patterns, cloudflare-bindings, zod-validation, rpc-typesafe
- Support for Bun and Cloudflare Workers
- Type-safe RPC client generation
