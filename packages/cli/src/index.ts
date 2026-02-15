import { Command } from 'commander'
import { initCommand } from './commands/init.js'
import { addCommand } from './commands/add.js'
import { listCommand } from './commands/list.js'
import { removeCommand } from './commands/remove.js'
import { updateCommand } from './commands/update.js'
import { searchCommand } from './commands/search.js'

const program = new Command()
  .name('ai-kit')
  .description('AI coding tool pack manager')
  .version('0.0.1')

program.addCommand(initCommand)
program.addCommand(addCommand)
program.addCommand(listCommand)
program.addCommand(removeCommand)
program.addCommand(updateCommand)
program.addCommand(searchCommand)
program.parse()
