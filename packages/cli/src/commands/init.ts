import { Command } from 'commander'
import * as p from '@clack/prompts'
import pc from 'picocolors'
import path from 'node:path'
import { TOOL_REGISTRY, TOOL_IDS } from '../tools.js'
import { discoverPacks } from '../discovery.js'
import { readConfig, writeConfig, createDefaultConfig, mergeInstall } from '../config.js'
import { updateGitignore } from '../gitignore.js'
import { installPack } from '../installer.js'
import { getGlobalTools, saveGlobalTools } from '../global-config.js'
import type { ToolId, ComponentType } from '../types.js'

export const initCommand = new Command('init')
  .description('Interactive first-time setup')
  .option('--cwd <dir>', 'Project directory (for monorepo sub-packages)')
  .action(async (opts: { cwd?: string }) => {
    p.intro(pc.bgCyan(pc.black(' ai-kit ')))

    const projectDir = opts.cwd ? path.resolve(opts.cwd) : process.cwd()
    const existing = readConfig(projectDir)

    if (existing) {
      const action = await p.select({
        message: 'ai-kit is already configured. What would you like to do?',
        options: [
          { value: 'reconfigure', label: 'Reconfigure from scratch' },
          { value: 'add', label: 'Add more packs' },
          { value: 'cancel', label: 'Cancel' },
        ],
      })

      if (p.isCancel(action) || action === 'cancel') {
        p.outro('Cancelled.')
        return
      }

      if (action === 'add') {
        p.outro(`Run ${pc.cyan('ai-kit add <pack>')} to add packs.`)
        return
      }
    }

    // Step 1: Select AI coding tools (pre-select from global config)
    const savedTools = getGlobalTools()

    const toolSelection = await p.autocompleteMultiselect({
      message: 'Which AI coding tools do you use? (type to filter)',
      options: TOOL_IDS.map(id => ({
        value: id,
        label: TOOL_REGISTRY[id].label,
        hint: TOOL_REGISTRY[id].hint,
      })),
      initialValues: savedTools ?? [],
      required: true,
    })

    if (p.isCancel(toolSelection)) {
      p.outro('Cancelled.')
      return
    }

    const selectedTools = toolSelection as ToolId[]

    // Save tools globally for future use
    saveGlobalTools(selectedTools)

    // Step 2: Discover and select packs
    let packs
    try {
      packs = discoverPacks()
    } catch {
      p.log.error('Could not find marketplace.json. Is ai-kit installed correctly?')
      p.outro('Setup failed.')
      return
    }

    const packSelection = await p.autocompleteMultiselect({
      message: 'Which packs do you want to install? (type to filter)',
      options: packs.map(pack => ({
        value: pack.name,
        label: pack.name,
        hint: pack.description,
      })),
      required: true,
    })

    if (p.isCancel(packSelection)) {
      p.outro('Cancelled.')
      return
    }

    const selectedPackNames = packSelection as string[]

    // Step 3: Component filter
    const componentChoice = await p.select({
      message: 'What components should be installed?',
      options: [
        { value: 'all', label: 'Everything', hint: 'agents, skills, commands, rules, hooks' },
        { value: 'skills', label: 'Skills only', hint: 'auto-enforcing convention skills' },
        { value: 'pick', label: 'Let me pick' },
      ],
    })

    if (p.isCancel(componentChoice)) {
      p.outro('Cancelled.')
      return
    }

    let filter: ComponentType[] | undefined
    if (componentChoice === 'skills') {
      filter = ['skills']
    } else if (componentChoice === 'pick') {
      const components = await p.multiselect({
        message: 'Select component types:',
        options: [
          { value: 'agents', label: 'Agents', hint: 'specialized AI agents' },
          { value: 'skills', label: 'Skills', hint: 'auto-enforcing conventions' },
          { value: 'commands', label: 'Commands', hint: 'slash commands' },
          { value: 'rules', label: 'Rules', hint: 'path-specific rules' },
          { value: 'hooks', label: 'Hooks', hint: 'lifecycle hooks (Claude Code only)' },
        ],
        required: true,
      })

      if (p.isCancel(components)) {
        p.outro('Cancelled.')
        return
      }
      filter = components as ComponentType[]
    }

    // Step 4: Install
    const s = p.spinner()
    s.start('Installing packs...')

    let config = createDefaultConfig(selectedTools)
    const selectedPacks = packs.filter(p => selectedPackNames.includes(p.name))
    for (const pack of selectedPacks) {
      const result = installPack({
        pack,
        tools: selectedTools,
        filter,
        projectDir,
      })

      config = mergeInstall(config, result)
    }

    // Step 5: Write config + gitignore
    writeConfig(projectDir, config)
    updateGitignore(projectDir)

    s.stop('Done!')

    // Summary
    p.log.success(`Installed ${selectedPacks.length} pack(s) for ${selectedTools.length} tool(s):`)
    for (const pack of selectedPacks) {
      p.log.message(`  ${pc.green('+')} ${pack.name} ${pc.dim(`v${pack.version}`)}`)
    }

    p.outro(pc.dim('Run ai-kit add <pack> to add more packs anytime.'))
  })
