/**
 * Bind command - Bind server to client(s)
 */

import { Command } from 'commander';
import { ConfigManager } from '../../core/config-manager.js';

export function bindCommand(program: Command) {
  program
    .command('bind <serverId>')
    .description('Bind a server to one or more clients')
    .requiredOption('--client <clientId...>', 'One or more client ids')
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

        const clientIds: string[] = options.client;

        // Verify all clients exist
        for (const clientId of clientIds) {
          const client = await configManager.getClient(clientId);
          if (!client) {
            console.error(`Error: Client "${clientId}" not found`);
            console.log('\nRegistered clients:');
            const clients = await configManager.getClients();
            for (const c of clients) {
              console.log(`  - ${c.id} (${c.displayName})`);
            }
            process.exit(1);
          }
        }

        // Add bindings
        for (const clientId of clientIds) {
          await configManager.addBinding(serverId, clientId);
        }

        console.log(`✔ Bound server "${serverId}" to clients: ${clientIds.join(', ')}`);
        console.log('\nRemember to regenerate configs:');
        for (const clientId of clientIds) {
          console.log(`  mcp-launcher generate-config --client ${clientId}`);
        }
      } catch (error: any) {
        console.error('Error:', error.message);
        process.exit(1);
      }
    });
}
