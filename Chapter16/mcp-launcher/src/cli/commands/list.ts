/**
 * List command - List servers, clients, and bindings
 */

import { Command } from 'commander';
import { ConfigManager } from '../../core/config-manager.js';
import { getClientAdapter } from '../../core/client-adapter.js';

export function listCommand(program: Command) {
  const list = program
    .command('list')
    .description('Inspect MCP servers and clients based on existing client configs');

  // list (default - show all)
  list
    .command('all', { isDefault: true })
    .description('List servers with the clients that use them')
    .option('--client <clientId>', 'Filter by client')
    .option('--server <serverId>', 'Filter by server')
    .action(async (options) => {
      try {
        const configManager = new ConfigManager();

        if (!(await configManager.exists())) {
          console.log('MCP Launcher not initialized. Run: mcp-launcher init');
          process.exit(1);
        }

        const config = await configManager.getConfig();
        const bindings = await configManager.getBindings();

        console.log('Servers and clients:\n');

        // Get all servers (or filter by server)
        const servers = Object.values(config.servers);
        const filteredServers = options.server
          ? servers.filter(s => s.id === options.server)
          : servers;

        if (filteredServers.length === 0) {
          console.log('No servers found.');
          return;
        }

        for (const server of filteredServers) {
          // Get clients for this server
          let clients = bindings
            .filter(b => b.serverId === server.id)
            .map(b => b.clientId);

          // Filter by client if specified
          if (options.client) {
            clients = clients.filter(c => c === options.client);
          }

          console.log(`${server.id}`);

          if (clients.length > 0) {
            const clientNames = clients
              .map(cId => config.clients[cId]?.displayName || cId)
              .join(', ');
            console.log(`  Used by: ${clientNames}`);
          } else {
            console.log(`  Used by: (none)`);
          }

          console.log('');
        }
      } catch (error: any) {
        console.error('Error:', error.message);
        process.exit(1);
      }
    });

  // list servers
  list
    .command('servers')
    .description('List all MCP servers')
    .option('--client <clientId>', 'Filter by client')
    .action(async (options) => {
      try {
        const configManager = new ConfigManager();

        if (!(await configManager.exists())) {
          console.log('MCP Launcher not initialized. Run: mcp-launcher init');
          process.exit(1);
        }

        const config = await configManager.getConfig();
        const bindings = await configManager.getBindings();

        console.log('Servers:\n');

        // Get all servers
        let servers = Object.values(config.servers);

        // Filter by client if specified
        if (options.client) {
          const clientBindings = bindings.filter(b => b.clientId === options.client);
          const serverIds = new Set(clientBindings.map(b => b.serverId));
          servers = servers.filter(s => serverIds.has(s.id));

          console.log(`Servers used by "${options.client}":\n`);
        }

        if (servers.length === 0) {
          console.log('No servers found.');
          return;
        }

        for (const server of servers) {
          console.log(`${server.id}`);
          console.log(`  Transport: ${server.transport}`);

          // Get clients for this server
          const clients = bindings
            .filter(b => b.serverId === server.id)
            .map(b => b.clientId);

          if (clients.length > 0) {
            const clientNames = clients
              .map(cId => config.clients[cId]?.displayName || cId)
              .join(', ');
            console.log(`  Used by: ${clientNames}`);
          } else {
            console.log(`  Used by: (none)`);
          }

          console.log('');
        }
      } catch (error: any) {
        console.error('Error:', error.message);
        process.exit(1);
      }
    });

  // list clients
  list
    .command('clients')
    .description('List all MCP clients and their servers')
    .option('--server <serverId>', 'Filter by server')
    .action(async (options) => {
      try {
        const configManager = new ConfigManager();

        if (!(await configManager.exists())) {
          console.log('MCP Launcher not initialized. Run: mcp-launcher init');
          process.exit(1);
        }

        const config = await configManager.getConfig();
        const bindings = await configManager.getBindings();

        console.log('Clients:\n');

        // Get all clients
        let clients = Object.values(config.clients);

        // Filter by server if specified
        if (options.server) {
          const serverBindings = bindings.filter(b => b.serverId === options.server);
          const clientIds = new Set(serverBindings.map(b => b.clientId));
          clients = clients.filter(c => clientIds.has(c.id));

          console.log(`Clients using "${options.server}":\n`);
        }

        if (clients.length === 0) {
          console.log('No clients found.');
          return;
        }

        for (const client of clients) {
          console.log(`${client.displayName}`);
          console.log(`  Config: ${client.configPath}`);

          // Get servers for this client
          const servers = bindings
            .filter(b => b.clientId === client.id)
            .map(b => b.serverId);

          if (servers.length > 0) {
            console.log(`  Servers: ${servers.join(', ')}`);
          } else {
            console.log(`  Servers: (none)`);
          }

          console.log('');
        }
      } catch (error: any) {
        console.error('Error:', error.message);
        process.exit(1);
      }
    });

  // list bindings
  list
    .command('bindings')
    .description('List all client ↔ server relationships')
    .option('--client <clientId>', 'Filter by client')
    .option('--server <serverId>', 'Filter by server')
    .action(async (options) => {
      try {
        const configManager = new ConfigManager();

        if (!(await configManager.exists())) {
          console.log('MCP Launcher not initialized. Run: mcp-launcher init');
          process.exit(1);
        }

        const config = await configManager.getConfig();
        let bindings = await configManager.getBindings();

        // Apply filters
        if (options.client) {
          bindings = bindings.filter(b => b.clientId === options.client);
        }
        if (options.server) {
          bindings = bindings.filter(b => b.serverId === options.server);
        }

        console.log('Bindings (client ↔ server):\n');

        if (bindings.length === 0) {
          console.log('No bindings found.');
          return;
        }

        for (const binding of bindings) {
          const clientName = config.clients[binding.clientId]?.displayName || binding.clientId;
          console.log(`${clientName} ↔ ${binding.serverId}`);
        }
      } catch (error: any) {
        console.error('Error:', error.message);
        process.exit(1);
      }
    });
}
