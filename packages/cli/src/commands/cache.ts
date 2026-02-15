import { Command } from 'commander'
import pc from 'picocolors'
import { clearCache } from '../registry.js'

export const cacheCommand = new Command('cache')
  .description('Manage cached packs')

cacheCommand
  .command('clear')
  .description('Clear cached packs (forces re-download on next run)')
  .action(() => {
    clearCache()
    console.log(pc.green('Cache cleared.') + ' Packs will be re-downloaded on next run.')
  })
