#!/usr/bin/env node

/**
 * MCP Launcher CLI
 */

import { Command } from 'commander';
import { initCommand } from './commands/init.js';
import { listCommand } from './commands/list.js';
import { discoverCommand } from './commands/discover.js';
import { importCommand } from './commands/import.js';
import { bindCommand } from './commands/bind.js';
import { unbindCommand } from './commands/unbind.js';
import { deleteCommand } from './commands/delete.js';
import { generateConfigCommand } from './commands/generate-config.js';
import { startCommand } from './commands/start.js';
import { stopCommand } from './commands/stop.js';
import { daemonCommand } from './commands/daemon.js';

const program = new Command();

program
  .name('mcp-launcher')
  .description('The MCP control center for your local machine')
  .version('0.1.0');

// Register commands
initCommand(program);
listCommand(program);
discoverCommand(program);
importCommand(program);
bindCommand(program);
unbindCommand(program);
deleteCommand(program);
generateConfigCommand(program);
startCommand(program);
stopCommand(program);
daemonCommand(program);

program.parse();
