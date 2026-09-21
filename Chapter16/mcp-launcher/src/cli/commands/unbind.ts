/**
 * Unbind command - Unbind server from client(s)
 */

import { Command } from 'commander';
import { ConfigManager } from '../../core/config-manager.js';

export function unbindCommand(program: Command) {
  program
    .command('unbind <serverId>')
    .description('Unbind a server from one or more clients')
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

        // Remove bindings
        for (const clientId of clientIds) {
          await configManager.removeBinding(serverId, clientId);
        }

        console.log(`✔ Unbound server "${serverId}" from clients: ${clientIds.join(', ')}`);
        console.log('\nNext:');
        for (const clientId of clientIds) {
          console.log(`  mcp-launcher generate-config --client ${clientId}`);
        }
      } catch (error: any) {
        console.error('Error:', error.message);
        process.exit(1);
      }
    });
}
