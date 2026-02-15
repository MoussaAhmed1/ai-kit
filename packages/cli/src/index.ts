import { Command } from 'commander'
import { initCommand } from './commands/init.js'
import { addCommand } from './commands/add.js'

const program = new Command()
  .name('ai-kit')
  .description('AI coding tool pack manager')
  .version('0.0.1')

program.addCommand(initCommand)
program.addCommand(addCommand)
program.parse()
