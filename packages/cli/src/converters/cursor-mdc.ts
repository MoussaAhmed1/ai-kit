import fs from 'node:fs'

/**
 * Convert a rule .md file (with YAML frontmatter) to Cursor .mdc format.
 * Extracts paths from frontmatter → globs, first heading → description.
 */
export function convertToMdc(mdFilePath: string, packName: string): string {
  const content = fs.readFileSync(mdFilePath, 'utf-8')
  const { frontmatter, body } = parseFrontmatter(content)

  // Extract globs from paths
  const paths = frontmatter.paths as string[] | undefined
  const globs = paths && paths.length > 0
    ? (paths.length === 1 ? paths[0] : paths.join(', '))
    : ''

  // Extract description from first heading or fallback
  const headingMatch = body.match(/^#\s+(.+)$/m)
  const description = headingMatch
    ? headingMatch[1].trim()
    : `${packName} rule`

  // Build .mdc content
  const mdcFrontmatter = [
    '---',
    `description: ${description}`,
    ...(globs ? [`globs: ${globs}`] : []),
    '---',
  ].join('\n')

  return `${mdcFrontmatter}\n${body}`
}

function parseFrontmatter(content: string): { frontmatter: Record<string, unknown>; body: string } {
  const match = content.match(/^---\n([\s\S]*?)\n---\n?([\s\S]*)$/)
  if (!match) {
    return { frontmatter: {}, body: content }
  }

  const yamlStr = match[1]
  const body = match[2]

  // Simple YAML parser for our use case (paths array)
  const frontmatter: Record<string, unknown> = {}
  let currentKey = ''
  const currentArray: string[] = []

  for (const line of yamlStr.split('\n')) {
    const keyMatch = line.match(/^(\w+):(.*)$/)
    if (keyMatch) {
      if (currentKey && currentArray.length > 0) {
        frontmatter[currentKey] = [...currentArray]
        currentArray.length = 0
      }
      currentKey = keyMatch[1]
      const value = keyMatch[2].trim()
      if (value) {
        frontmatter[currentKey] = value
        currentKey = ''
      }
    } else {
      const itemMatch = line.match(/^\s+-\s+"?(.+?)"?\s*$/)
      if (itemMatch) {
        currentArray.push(itemMatch[1])
      }
    }
  }

  if (currentKey && currentArray.length > 0) {
    frontmatter[currentKey] = [...currentArray]
  }

  return { frontmatter, body }
}
