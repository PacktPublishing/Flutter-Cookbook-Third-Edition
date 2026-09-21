/**
 * Generate-config command - Generate MCP config for a client
 */

import { Command } from 'commander';
import { ConfigManager } from '../../core/config-manager.js';
import { getClientAdapter } from '../../core/client-adapter.js';

export function generateConfigCommand(program: Command) {
  program
    .command('generate-config')
    .description('Generate MCP config file for a given client')
    .requiredOption('--client <clientId>', 'Client id (e.g. claude-desktop)')
    .action(async (options) => {
      try {
        const configManager = new ConfigManager();

        if (!(await configManager.exists())) {
          console.log('MCP Launcher not initialized. Run: mcp-launcher init');
          process.exit(1);
        }

        const clientId = options.client;

        // Get client info
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

        // Get servers bound to this client
        const bindings = await configManager.getClientBindings(clientId);
        const serverIds = bindings.map(b => b.serverId);

        const servers = [];
        for (const serverId of serverIds) {
          const server = await configManager.getServer(serverId);
          if (server) {
            servers.push(server);
          }
        }

        // Generate and write config
        const adapter = getClientAdapter(clientId, client.configPath);
        const mcpConfig = adapter.generateConfig(servers);
        await adapter.write(mcpConfig);

        console.log(`✔ Generated MCP config for client "${client.displayName}"`);
        console.log(`Path: ${client.configPath}`);

        if (servers.length > 0) {
          console.log('\nServers enabled:');
          for (const server of servers) {
            console.log(`  - ${server.id}`);
          }
        } else {
          console.log('\nNo servers bound to this client.');
        }
      } catch (error: any) {
        console.error('Error:', error.message);
        process.exit(1);
      }
    });
}
