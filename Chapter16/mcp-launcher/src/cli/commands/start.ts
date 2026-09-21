/**
 * Start command - Start MCP server instance
 */

import { Command } from 'commander';
import { ConfigManager } from '../../core/config-manager.js';
import { DaemonClient } from '../daemon-client.js';

export function startCommand(program: Command) {
  program
    .command('start <serverId>')
    .description('Start an MCP server instance for one or more clients')
    .requiredOption('--client <clientId...>', 'One or more client ids')
    .option('--shared', 'Start a shared instance (SSE only)')
    .option('--isolated', 'Force isolated instances per client (default)')
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

        const clientIds: string[] = options.client;
        const mode = options.shared ? 'shared' : 'isolated';

        // Verify all clients exist
        for (const clientId of clientIds) {
          const client = await configManager.getClient(clientId);
          if (!client) {
            console.error(`Error: Client "${clientId}" not found`);
            process.exit(1);
          }
        }

        // Check if server is bound to clients
        for (const clientId of clientIds) {
          const bindings = await configManager.getClientBindings(clientId);
          const isBound = bindings.some(b => b.serverId === serverId);
          if (!isBound) {
            console.error(`Error: Server "${serverId}" is not bound to client "${clientId}"`);
            console.log(`Run: mcp-launcher bind ${serverId} --client ${clientId}`);
            process.exit(1);
          }
        }

        // Start instances
        if (mode === 'shared' && server.transport === 'sse') {
          // Start shared SSE instance
          console.log(`Starting "${serverId}" as a shared SSE server for: ${clientIds.join(', ')}...`);

          const result = await daemonClient.startServer(serverId, clientIds[0], 'shared');

          // Attach other clients
          for (let i = 1; i < clientIds.length; i++) {
            await daemonClient.startServer(serverId, clientIds[i], 'shared');
          }

          console.log(`✔ Started "${serverId}" (sse) in shared mode`);
          console.log(`PID: ${result.details.pid}`);
          console.log(`URL: ${result.details.url}`);
          console.log(`Attached clients: ${clientIds.join(', ')}`);

        } else {
          // Start isolated instances
          for (const clientId of clientIds) {
            console.log(`Starting "${serverId}" for client "${clientId}"...`);

            const result = await daemonClient.startServer(serverId, clientId, 'isolated');

            console.log(`✔ Started "${serverId}" (${server.transport}) for ${clientId}`);
            console.log(`PID: ${result.details.pid}`);
            if (result.details.url) {
              console.log(`URL: ${result.details.url}`);
            }
            console.log(`Mode: isolated\n`);
          }
        }

      } catch (error: any) {
        console.error('Error:', error.message);
        process.exit(1);
      }
    });
}
