/**
 * Stop command - Stop MCP server instances
 */

import { Command } from 'commander';
import { ConfigManager } from '../../core/config-manager.js';
import { DaemonClient } from '../daemon-client.js';

export function stopCommand(program: Command) {
  program
    .command('stop <serverId>')
    .description('Stop MCP server instances managed by the daemon')
    .option('--client <clientId>', 'Stop only this client\'s instance')
    .action(async (serverId: string, options) => {
      try {
        const configManager = new ConfigManager();
        const daemonClient = new DaemonClient();

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

        if (options.client) {
          // Stop specific client instance
          await daemonClient.stopServer(serverId, options.client);
          console.log(`✔ Stopped "${serverId}" for client "${options.client}"`);
        } else {
          // Stop all instances
          const status = await daemonClient.getServerStatus(serverId);

          if (!status.running) {
            console.log(`Server "${serverId}" is not running`);
            return;
          }

          await daemonClient.stopServer(serverId);

          // Get list of stopped instances
          if (status.instance) {
            const { instance } = status;

            if (instance.shared) {
              console.log(`✔ Stopped "${serverId}" (shared instance)`);
              console.log(`Stopped for clients: ${instance.shared.attachedClients.join(', ')}`);
            } else if (instance.byClient) {
              const clientIds = Object.keys(instance.byClient);
              console.log(`✔ Stopped all instances of "${serverId}"`);
              console.log(`Stopped for clients: ${clientIds.join(', ')}`);
            }
          } else {
            console.log(`✔ Stopped "${serverId}"`);
          }
        }

      } catch (error: any) {
        console.error('Error:', error.message);
        process.exit(1);
      }
    });
}
