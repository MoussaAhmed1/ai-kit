import fs from 'node:fs'
import path from 'node:path'
import type { MarketplaceJson, ResolvedPack } from './types.js'

/**
 * Find marketplace.json by walking up from a starting directory.
 * Looks for `.claude-plugin/marketplace.json` in each ancestor.
 */
function findMarketplaceJson(startDir: string): string | null {
  let dir = startDir
  while (true) {
    const candidate = path.join(dir, '.claude-plugin', 'marketplace.json')
    if (fs.existsSync(candidate)) return candidate
    const parent = path.dirname(dir)
    if (parent === dir) return null
    dir = parent
  }
}

/**
 * Resolve a single pack from its marketplace entry.
 * Converts relative paths to absolute, discovers rules from filesystem.
 */
function resolvePack(
  plugin: MarketplaceJson['plugins'][number],
  marketplaceDir: string,
): ResolvedPack {
  const sourceDir = path.resolve(marketplaceDir, plugin.source)

  const resolveFiles = (files: string[] | undefined): string[] =>
    (files ?? []).map(f => path.resolve(sourceDir, f))

  // Discover rules from filesystem (not in marketplace.json)
  let rules: string[] = []
  const rulesDir = path.join(sourceDir, 'rules')
  if (fs.existsSync(rulesDir)) {
    rules = fs.readdirSync(rulesDir)
      .filter(f => f.endsWith('.md'))
      .map(f => path.join(rulesDir, f))
  }

  // For skills, resolve to the parent directory (containing SKILL.md)
  const skills = (plugin.skills ?? []).map(s => {
    const skillMdPath = path.resolve(sourceDir, s)
    return path.dirname(skillMdPath)
  })

  return {
    name: plugin.name,
    version: plugin.version,
    description: plugin.description,
    sourceDir,
    agents: resolveFiles(plugin.agents),
    commands: resolveFiles(plugin.commands),
    skills,
    rules,
    hooks: resolveFiles(plugin.hooks),
    mcpServers: plugin.mcpServers
      ? path.resolve(sourceDir, plugin.mcpServers)
      : undefined,
  }
}

/**
 * Discover all packs from marketplace.json.
 * Walks up from __dirname (or provided start) to find the marketplace root.
 */
export function discoverPacks(startDir?: string): ResolvedPack[] {
  const start = startDir ?? path.dirname(new URL(import.meta.url).pathname)
  const marketplacePath = findMarketplaceJson(start)

  if (!marketplacePath) {
    throw new Error(
      'Could not find .claude-plugin/marketplace.json. ' +
      'Make sure ai-kit is installed correctly.',
    )
  }

  const marketplaceDir = path.dirname(path.dirname(marketplacePath))
  const raw = JSON.parse(fs.readFileSync(marketplacePath, 'utf-8')) as MarketplaceJson

  return raw.plugins
    .map(p => resolvePack(p, marketplaceDir))
    .filter(p => fs.existsSync(p.sourceDir))
}

/**
 * Find a single pack by name.
 */
export function findPack(name: string, startDir?: string): ResolvedPack | undefined {
  return discoverPacks(startDir).find(p => p.name === name)
}
