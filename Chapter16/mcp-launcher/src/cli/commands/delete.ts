/**
 * Delete command - Delete server (partial or full)
 */

import { Command } from 'commander';
import { ConfigManager } from '../../core/config-manager.js';
import * as readline from 'readline';

async function confirm(message: string): Promise<boolean> {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });

  return new Promise((resolve) => {
    rl.question(`${message} (y/N) `, (answer) => {
      rl.close();
      resolve(answer.toLowerCase() === 'y' || answer.toLowerCase() === 'yes');
    });
  });
}

export function deleteCommand(program: Command) {
  program
    .command('delete <serverId>')
    .description('Delete a server from one client or from all clients')
    .option('--client <clientId>', 'Delete only for this client (equivalent to unbind)')
    .option('--force', 'Skip confirmation prompt')
    .action(async (serverId: string, options) => {
      try {
        const configManager = new ConfigManager();

        if (!(await configManager.exists())) {
          console.log('MCP Launcher not initialized. Run: mcp-launcher init');
          process.exit(1);
        }

        // Verify server exists
        const server = await configManager.getServer(serverId);
        if (!server) {
          console.error(`Error: Server "${serverId}" not found`);
          process.exit(1);
        }

        // Get affected clients
        const affectedClients = await configManager.getClientsForServer(serverId);

        if (options.client) {
          // Partial delete (per-client)
          if (!affectedClients.includes(options.client)) {
            console.log(`Server "${serverId}" is not bound to client "${options.client}"`);
            return;
          }

          if (!options.force) {
            console.log(`You are about to remove server "${serverId}" from client "${options.client}".`);
            console.log(`This will update the client's MCP config so it no longer sees this server.\n`);

            const confirmed = await confirm('Proceed?');
            if (!confirmed) {
              console.log('Cancelled.');
              return;
            }
          }

          await configManager.removeBinding(serverId, options.client);
          console.log(`✔ Removed server "${serverId}" from client "${options.client}"`);
          console.log(`\nNext:\n  mcp-launcher generate-config --client ${options.client}`);

        } else {
          // Full delete (global)
          if (!options.force) {
            console.log(`You are about to delete server "${serverId}" from MCP Launcher.`);
            console.log('This will:');
            console.log('  - Remove it from all clients');
            console.log('  - Regenerate affected MCP configs');
            console.log(`  - Delete the server definition from ${configManager.getConfigPath()}`);
            console.log('\nIt will NOT uninstall any npm/pip packages.');

            if (affectedClients.length > 0) {
              console.log('\nAffected clients:');
              for (const clientId of affectedClients) {
                const client = await configManager.getClient(clientId);
                console.log(`  - ${client?.displayName || clientId}`);
              }
            }

            console.log('');
            const confirmed = await confirm('Proceed?');
            if (!confirmed) {
              console.log('Cancelled.');
              return;
            }
          }

          // Delete server and all bindings
          await configManager.deleteServer(serverId);

          console.log(`✔ Deleted server "${serverId}" from MCP Launcher`);

          if (affectedClients.length > 0) {
            console.log(`✔ Updated configs for: ${affectedClients.join(', ')}`);
            console.log('\nRegenerate configs:');
            for (const clientId of affectedClients) {
              console.log(`  mcp-launcher generate-config --client ${clientId}`);
            }
          }
        }
      } catch (error: any) {
        console.error('Error:', error.message);
        process.exit(1);
      }
    });
}
