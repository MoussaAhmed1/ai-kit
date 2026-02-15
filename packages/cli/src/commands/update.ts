import { Command } from 'commander'
import path from 'node:path'
import pc from 'picocolors'
import { findPack } from '../discovery.js'
import { readConfig, writeConfig, mergeInstall } from '../config.js'
import { updateGitignore } from '../gitignore.js'
import { installPack, removePack, getWrittenDirs } from '../installer.js'

export const updateCommand = new Command('update')
  .description('Update installed packs')
  .argument('[pack]', 'Pack name (omit to update all)')
  .option('--cwd <dir>', 'Project directory')
  .action((packName: string | undefined, opts: { cwd?: string }) => {
    const projectDir = opts.cwd ? path.resolve(opts.cwd) : process.cwd()
    const config = readConfig(projectDir)

    if (!config) {
      console.error(pc.red('No .ai-kit.json found. Run ') + pc.cyan('ai-kit init') + pc.red(' first.'))
      process.exit(1)
    }

    const packsToUpdate = packName
      ? [packName]
      : Object.keys(config.packs)

    if (packsToUpdate.length === 0) {
      console.log(pc.dim('No packs installed.'))
      return
    }

    let updated = 0
    let skipped = 0
    let hadSkills = false

    for (const name of packsToUpdate) {
      const installed = config.packs[name]
      if (!installed) {
        console.log(pc.yellow(`"${name}" is not installed, skipping.`))
        skipped++
        continue
      }

      const available = findPack(name)
      if (!available) {
        console.log(pc.yellow(`"${name}" not found in marketplace, skipping.`))
        skipped++
        continue
      }

      if (available.version === installed.version) {
        console.log(pc.dim(`  ${name} v${installed.version} — already up to date`))
        skipped++
        continue
      }

      // Remove old files
      if (installed.files && installed.files.length > 0) {
        removePack(projectDir, installed.files)
      }

      // Reinstall
      const result = installPack({
        pack: available,
        tools: config.tools,
        projectDir,
      })

      const merged = mergeInstall(config, result)
      merged.packs[name].version = available.version
      Object.assign(config, merged)

      if (result.installed.skills > 0) hadSkills = true

      console.log(
        pc.green(`  ${name}`) +
        ` ${pc.dim(installed.version)} → ${pc.cyan(available.version)}`,
      )
      updated++
    }

    writeConfig(projectDir, config)
    updateGitignore(projectDir, getWrittenDirs(config.tools, hadSkills))

    if (updated > 0) {
      console.log(pc.green(`\nUpdated ${updated} pack(s).`))
    }
    if (skipped > 0 && updated === 0) {
      console.log(pc.dim('\nAll packs are up to date.'))
    }
  })
