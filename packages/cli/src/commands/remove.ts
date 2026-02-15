import { Command } from 'commander'
import path from 'node:path'
import pc from 'picocolors'
import { readConfig, writeConfig, removePack as removeFromConfig } from '../config.js'
import { removePack } from '../installer.js'

export const removeCommand = new Command('remove')
  .description('Remove a pack from your project')
  .argument('<pack>', 'Pack name to remove')
  .option('--cwd <dir>', 'Project directory')
  .action((packName: string, opts: { cwd?: string }) => {
    const projectDir = opts.cwd ? path.resolve(opts.cwd) : process.cwd()
    const config = readConfig(projectDir)

    if (!config) {
      console.log(pc.dim('No packs installed.'))
      return
    }

    const packConfig = config.packs[packName]
    if (!packConfig) {
      console.error(
        pc.red(`Pack "${packName}" is not installed.`) +
        '\nInstalled: ' + Object.keys(config.packs).join(', '),
      )
      process.exit(1)
    }

    const files = packConfig.files ?? []
    if (files.length === 0) {
      console.log(pc.yellow(`No tracked files for "${packName}". Removing from config only.`))
    } else {
      const removed = removePack(projectDir, files)
      console.log(pc.green(`Removed ${removed} file(s) for ${packName}`))
    }

    const updated = removeFromConfig(config, packName)
    writeConfig(projectDir, updated)

    console.log(pc.dim('Config updated.'))
  })
