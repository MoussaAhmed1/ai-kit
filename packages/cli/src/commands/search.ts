import { Command } from 'commander'
import pc from 'picocolors'
import { discoverPacks } from '../discovery.js'
import { getRegistryOptions } from '../global-opts.js'

export const searchCommand = new Command('search')
  .description('Search available packs by name or keyword')
  .argument('<query>', 'Search term (matches name, description, keywords)')
  .action(async (query: string) => {
    let packs
    try {
      packs = await discoverPacks(getRegistryOptions())
    } catch {
      console.error(pc.red('Could not find marketplace.json.'))
      process.exit(1)
    }

    const q = query.toLowerCase()

    const matches = packs.filter(pack => {
      const haystack = [
        pack.name,
        pack.description,
        pack.category,
        ...pack.keywords,
      ].join(' ').toLowerCase()

      return haystack.includes(q)
    })

    if (matches.length === 0) {
      console.log(pc.dim(`No packs matching "${query}".`))
      console.log(pc.dim(`\nAll packs: ${packs.map(p => p.name).join(', ')}`))
      return
    }

    console.log(pc.bold(`Found ${matches.length} pack(s):\n`))

    for (const pack of matches) {
      const counts: string[] = []
      if (pack.agents.length) counts.push(`${pack.agents.length} agents`)
      if (pack.skills.length) counts.push(`${pack.skills.length} skills`)
      if (pack.commands.length) counts.push(`${pack.commands.length} commands`)
      if (pack.rules.length) counts.push(`${pack.rules.length} rules`)

      console.log(
        `  ${pc.cyan(pack.name)} ${pc.dim(`v${pack.version}`)}\n` +
        `    ${pack.description}\n` +
        `    ${pc.dim(counts.join(', '))}\n` +
        `    ${pc.dim(`Install: npx @smicolon/ai-kit@latest add ${pack.name}`)}\n`,
      )
    }
  })
