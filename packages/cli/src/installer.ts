import fs from 'node:fs'
import path from 'node:path'
import type { ComponentType, InstallOptions, InstallResult, ToolId } from './types.js'
import { TOOL_REGISTRY, CANONICAL_SKILLS_DIR } from './tools.js'

function ensureDir(dir: string): void {
  fs.mkdirSync(dir, { recursive: true })
}

function copyFile(src: string, dest: string): void {
  ensureDir(path.dirname(dest))
  fs.copyFileSync(src, dest)
}

function copyDir(src: string, dest: string): void {
  ensureDir(dest)
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    const srcPath = path.join(src, entry.name)
    const destPath = path.join(dest, entry.name)
    if (entry.isDirectory()) {
      copyDir(srcPath, destPath)
    } else {
      fs.copyFileSync(srcPath, destPath)
    }
  }
}

/**
 * Create a symlink, using junction type on Windows for directory links.
 */
function createSymlink(target: string, linkPath: string): void {
  ensureDir(path.dirname(linkPath))
  if (fs.existsSync(linkPath)) {
    const stat = fs.lstatSync(linkPath)
    if (stat.isSymbolicLink()) fs.unlinkSync(linkPath)
    else return // Real file/dir exists, don't overwrite
  }
  const type = process.platform === 'win32' ? 'junction' : undefined
  fs.symlinkSync(target, linkPath, type)
}

/**
 * Install skills using canonical + symlink strategy.
 * First tool gets files copied to canonical dir.
 * Additional tools get symlinks from their skillsDir to canonical.
 */
function installSkills(
  skillDirs: string[],
  tools: ToolId[],
  projectDir: string,
): number {
  if (skillDirs.length === 0 || tools.length === 0) return 0

  // Determine which tools support skills
  const skillTools = tools.filter(t => TOOL_REGISTRY[t].components.skills)
  if (skillTools.length === 0) return 0

  const canonicalBase = path.join(projectDir, CANONICAL_SKILLS_DIR)
  let count = 0

  // Copy each skill directory to canonical location
  for (const skillDir of skillDirs) {
    const skillName = path.basename(skillDir)
    const canonicalDest = path.join(canonicalBase, skillName)

    if (!fs.existsSync(canonicalDest)) {
      copyDir(skillDir, canonicalDest)
      count++
    }
  }

  // Create symlinks for each tool's skill directory
  for (const toolId of skillTools) {
    const toolSkillsDir = path.join(projectDir, TOOL_REGISTRY[toolId].skillsDir)

    // If this tool's skillsDir IS the canonical dir, skip symlinks
    if (path.resolve(toolSkillsDir) === path.resolve(canonicalBase)) continue

    ensureDir(toolSkillsDir)

    for (const skillDir of skillDirs) {
      const skillName = path.basename(skillDir)
      const canonicalDest = path.join(canonicalBase, skillName)
      const linkPath = path.join(toolSkillsDir, skillName)
      const relTarget = path.relative(path.dirname(linkPath), canonicalDest)
      createSymlink(relTarget, linkPath)
    }
  }

  return count
}

/**
 * Install .md files (agents, commands, rules) to each tool's target directory.
 */
function installMdFiles(
  files: string[],
  componentType: ComponentType,
  tools: ToolId[],
  projectDir: string,
): number {
  if (files.length === 0) return 0

  let count = 0
  for (const toolId of tools) {
    const targetDir = TOOL_REGISTRY[toolId].components[componentType]
    if (!targetDir) continue

    const dest = path.join(projectDir, targetDir)
    ensureDir(dest)

    for (const file of files) {
      copyFile(file, path.join(dest, path.basename(file)))
      count++
    }
  }

  return files.length // Return unique file count, not per-tool duplicates
}

interface HooksJson {
  hooks: Record<string, unknown[]>
  [key: string]: unknown
}

/**
 * Install hooks for Claude Code.
 * Reads hooks.json from pack, rewrites paths, copies scripts,
 * and merges into .claude/hooks.json.
 */
function installHooks(
  hookFiles: string[],
  tools: ToolId[],
  projectDir: string,
): number {
  if (hookFiles.length === 0) return 0
  if (!tools.includes('claude-code')) return 0

  let count = 0
  const targetHooksDir = path.join(projectDir, '.claude', 'hooks')

  for (const hookFile of hookFiles) {
    if (!fs.existsSync(hookFile)) continue

    const raw = JSON.parse(fs.readFileSync(hookFile, 'utf-8')) as HooksJson
    if (!raw.hooks || Object.keys(raw.hooks).length === 0) continue

    const hookSourceDir = path.dirname(hookFile)

    // Copy any script files referenced in the hooks
    const scriptFiles = findScriptFiles(hookSourceDir)
    for (const script of scriptFiles) {
      const relPath = path.relative(hookSourceDir, script)
      const destPath = path.join(targetHooksDir, relPath)
      copyFile(script, destPath)
      // Make scripts executable
      fs.chmodSync(destPath, 0o755)
    }

    // Rewrite ${CLAUDE_PLUGIN_ROOT} paths to point to copied scripts
    const rewritten = JSON.stringify(raw.hooks)
      .replace(/\$\{CLAUDE_PLUGIN_ROOT\}\/hooks/g, '.claude/hooks')

    // Merge into existing .claude/hooks.json
    const projectHooksPath = path.join(projectDir, '.claude', 'hooks.json')
    let existing: Record<string, unknown[]> = {}

    if (fs.existsSync(projectHooksPath)) {
      const parsed = JSON.parse(fs.readFileSync(projectHooksPath, 'utf-8'))
      existing = parsed.hooks ?? parsed
    }

    const newHooks = JSON.parse(rewritten) as Record<string, unknown[]>
    for (const [event, handlers] of Object.entries(newHooks)) {
      if (!existing[event]) existing[event] = []
      existing[event].push(...handlers)
    }

    ensureDir(path.dirname(projectHooksPath))
    fs.writeFileSync(
      projectHooksPath,
      JSON.stringify({ hooks: existing }, null, 2) + '\n',
    )

    count++
  }

  return count
}

/**
 * Find all script files (.sh, .js, .ts) in a directory recursively.
 */
function findScriptFiles(dir: string): string[] {
  const scripts: string[] = []
  if (!fs.existsSync(dir)) return scripts

  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const fullPath = path.join(dir, entry.name)
    if (entry.isDirectory()) {
      scripts.push(...findScriptFiles(fullPath))
    } else if (/\.(sh|js|ts)$/.test(entry.name)) {
      scripts.push(fullPath)
    }
  }
  return scripts
}

/**
 * Core install function. Copies pack components to the correct
 * tool-specific directories in the user's project.
 */
export function installPack(options: InstallOptions): InstallResult {
  const { pack, tools, filter, projectDir } = options
  const installed: Record<ComponentType, number> = {
    agents: 0,
    skills: 0,
    commands: 0,
    rules: 0,
    hooks: 0,
  }

  const should = (type: ComponentType) => !filter || filter.includes(type)

  if (should('agents')) {
    installed.agents = installMdFiles(pack.agents, 'agents', tools, projectDir)
  }

  if (should('commands')) {
    installed.commands = installMdFiles(pack.commands, 'commands', tools, projectDir)
  }

  if (should('rules')) {
    installed.rules = installMdFiles(pack.rules, 'rules', tools, projectDir)
  }

  if (should('skills')) {
    installed.skills = installSkills(pack.skills, tools, projectDir)
  }

  if (should('hooks')) {
    installed.hooks = installHooks(pack.hooks, tools, projectDir)
  }

  return { pack: pack.name, tools, installed }
}

/**
 * Collect all unique directories that were written to during installs.
 * Used by gitignore updater.
 */
export function getWrittenDirs(tools: ToolId[], hadSkills: boolean): string[] {
  const dirs = new Set<string>()

  if (hadSkills) {
    dirs.add(CANONICAL_SKILLS_DIR)
  }

  for (const toolId of tools) {
    const config = TOOL_REGISTRY[toolId]
    for (const dir of Object.values(config.components)) {
      // Add the top-level tool directory (e.g., .claude, .cursor)
      const topLevel = dir.split('/')[0]
      dirs.add(topLevel)
    }
  }

  return [...dirs]
}
