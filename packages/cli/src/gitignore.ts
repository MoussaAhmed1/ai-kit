import fs from 'node:fs'
import path from 'node:path'

const MANAGED_COMMENT = '# AI coding tools (managed by @smicolon/ai-kit)'

/**
 * Find the git root by walking up looking for .git directory.
 * Returns null if not in a git repo.
 */
function findGitRoot(startDir: string): string | null {
  let dir = startDir
  while (true) {
    if (fs.existsSync(path.join(dir, '.git'))) return dir
    const parent = path.dirname(dir)
    if (parent === dir) return null
    dir = parent
  }
}

/**
 * Append entries to a specific .gitignore file. Idempotent.
 */
function appendToGitignore(gitignorePath: string, entries: string[]): void {
  const existing = fs.existsSync(gitignorePath)
    ? fs.readFileSync(gitignorePath, 'utf-8')
    : ''

  const lines = existing.split('\n')
  const newEntries = entries.filter(
    entry => !lines.some(
      line => line.trim() === entry.replace(/\/$/, '') || line.trim() === entry,
    ),
  )

  if (newEntries.length === 0) return

  const hasBlock = lines.includes(MANAGED_COMMENT)
  let updated: string

  if (hasBlock) {
    const blockIdx = lines.indexOf(MANAGED_COMMENT)
    let endIdx = blockIdx + 1
    while (endIdx < lines.length && lines[endIdx].trim() !== '' && !lines[endIdx].startsWith('#')) {
      endIdx++
    }
    lines.splice(endIdx, 0, ...newEntries)
    updated = lines.join('\n')
  } else {
    const block = `\n${MANAGED_COMMENT}\n${newEntries.join('\n')}\n`
    updated = existing.endsWith('\n') ? existing + block : existing + '\n' + block
  }

  fs.writeFileSync(gitignorePath, updated)
}

/**
 * Ensure directories written during install are in .gitignore.
 * Supports monorepos: updates both project-level and git-root .gitignore.
 *
 * In a monorepo where projectDir != gitRoot:
 * - Project .gitignore gets the entries directly (e.g., `.claude/`)
 * - Git root .gitignore gets prefixed entries (e.g., `packages/app/.claude/`)
 *   only if there's no project-level .gitignore already covering them
 */
export function updateGitignore(projectDir: string, dirs: string[]): void {
  if (dirs.length === 0) return

  const entries = dirs.map(d => (d.endsWith('/') ? d : `${d}/`))

  // Always update .gitignore in the project directory
  const projectGitignore = path.join(projectDir, '.gitignore')
  appendToGitignore(projectGitignore, entries)

  // If we're in a monorepo (projectDir != gitRoot), also update root .gitignore
  const gitRoot = findGitRoot(projectDir)
  if (gitRoot && path.resolve(gitRoot) !== path.resolve(projectDir)) {
    const relFromRoot = path.relative(gitRoot, projectDir)
    const rootEntries = entries.map(e => `${relFromRoot}/${e}`)
    appendToGitignore(path.join(gitRoot, '.gitignore'), rootEntries)
  }
}
