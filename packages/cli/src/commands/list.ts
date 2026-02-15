import { Command } from 'commander'
import pc from 'picocolors'
import { discoverPacks } from '../discovery.js'
import { readConfig } from '../config.js'
import { getRegistryOptions } from '../global-opts.js'

export const listCommand = new Command('list')
  .description('List available or installed packs')
  .option('--installed', 'Show only installed packs')
  .option('--cwd <dir>', 'Project directory')
  .action(async (opts: { installed?: boolean; cwd?: string }) => {
    const projectDir = opts.cwd ? opts.cwd : process.cwd()

    if (opts.installed) {
      const config = readConfig(projectDir)
      if (!config || Object.keys(config.packs).length === 0) {
        console.log(pc.dim('No packs installed. Run ') + pc.cyan('ai-kit init') + pc.dim(' to get started.'))
        return
      }

      console.log(pc.bold('Installed packs:\n'))
      for (const [name, pack] of Object.entries(config.packs)) {
        const parts = Object.entries(pack.components)
          .filter(([, v]) => v && v.length > 0)
          .map(([type, v]) => `${v![0].replace(' files', '')} ${type}`)
        console.log(`  ${pc.green(name)} ${pc.dim(`v${pack.version}`)}  ${pc.dim(parts.join(', '))}`)
      }

      console.log(`\n${pc.dim(`Tools: ${config.tools.join(', ')}`)}`)
      return
    }

    // Show available packs
    let packs
    try {
      packs = await discoverPacks(getRegistryOptions())
    } catch {
      console.error(pc.red('Could not find marketplace.json.'))
      process.exit(1)
    }

    const config = readConfig(projectDir)
    const installedNames = config ? Object.keys(config.packs) : []

    console.log(pc.bold('Available packs:\n'))
    for (const pack of packs) {
      const installed = installedNames.includes(pack.name)
      const badge = installed ? pc.green(' [installed]') : ''
      const counts: string[] = []
      if (pack.agents.length) counts.push(`${pack.agents.length} agents`)
      if (pack.skills.length) counts.push(`${pack.skills.length} skills`)
      if (pack.commands.length) counts.push(`${pack.commands.length} commands`)
      if (pack.rules.length) counts.push(`${pack.rules.length} rules`)
      if (pack.hooks.length) counts.push(`${pack.hooks.length} hooks`)

      console.log(
        `  ${pc.cyan(pack.name)}${badge} ${pc.dim(`v${pack.version}`)}\n` +
        `    ${pack.description}\n` +
        `    ${pc.dim(counts.join(', '))}`,
      )
    }

    console.log(`\n${pc.dim(`${packs.length} packs available`)}`)
  })
