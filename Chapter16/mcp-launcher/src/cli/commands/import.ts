/**
 * Import command - Import discovered servers into MCP Launcher
 */

import { Command } from 'commander';
import { ConfigManager } from '../../core/config-manager.js';
import { DiscoveryService } from '../../core/discovery.js';

export function importCommand(program: Command) {
  program
    .command('import [serverId]')
    .description('Import discovered MCP servers into launcher config')
    .option('--from <clientId>', 'Import from specific client')
    .option('--all-from <clientId>', 'Import all servers from a client')
    .option('--bind', 'Also bind the imported server to the source client')
    .action(async (serverId: string | undefined, options) => {
      try {
        const configManager = new ConfigManager();

        if (!(await configManager.exists())) {
          console.log('MCP Launcher not initialized. Run: mcp-launcher init');
          process.exit(1);
        }

        const discoveryService = new DiscoveryService(configManager);

        // Discover from clients
        const discovered = await discoveryService.discoverFromClients();

        if (options.allFrom) {
          // Import all servers from a specific client
          const clientId = options.allFrom;
          const serversFromClient = discovered.filter(
            s => s.source === clientId && !s.alreadyInLauncher
          );

          if (serversFromClient.length === 0) {
            console.log(`No new servers to import from "${clientId}"`);
            return;
          }

          console.log(`Importing ${serversFromClient.length} server(s) from "${clientId}"...\n`);

          for (const server of serversFromClient) {
            const serverDef = discoveryService.toServerDefinition(server);
            await configManager.addServer(serverDef);
            console.log(`✔ Imported "${server.id}"`);

            if (options.bind) {
              await configManager.addBinding(server.id, clientId);
              console.log(`  ↳ Bound to ${clientId}`);
            }
          }

          console.log(`\n✔ Successfully imported ${serversFromClient.length} server(s)`);

          if (options.bind) {
            console.log(`\nNext: mcp-launcher generate-config --client ${clientId}`);
          }

        } else if (serverId) {
          // Import specific server
          if (!options.from) {
            console.error('Error: --from <clientId> is required when importing a specific server');
            console.log('\nExample: mcp-launcher import github --from claude-desktop');
            process.exit(1);
          }

          const clientId = options.from;
          const server = discovered.find(
            s => s.id === serverId && s.source === clientId
          );

          if (!server) {
            console.error(`Error: Server "${serverId}" not found in "${clientId}" config`);
            console.log('\nRun: mcp-launcher discover');
            process.exit(1);
          }

          if (server.alreadyInLauncher) {
            console.log(`Server "${serverId}" is already in MCP Launcher`);
            return;
          }

          // Convert and add to launcher
          const serverDef = discoveryService.toServerDefinition(server);
          await configManager.addServer(serverDef);

          console.log(`✔ Imported server "${serverId}" from "${clientId}"`);

          if (server.command) {
            console.log(`  Command: ${server.command} ${(server.args || []).join(' ')}`);
          }

          if (options.bind) {
            await configManager.addBinding(serverId, clientId);
            console.log(`  ↳ Bound to ${clientId}`);
            console.log(`\nNext: mcp-launcher generate-config --client ${clientId}`);
          } else {
            console.log(`\nBind it to clients with:`);
            console.log(`  mcp-launcher bind ${serverId} --client <clientId>`);
          }

        } else {
          // No serverId or --all-from provided
          console.error('Error: Please specify a server ID or use --all-from');
          console.log('\nUsage:');
          console.log('  mcp-launcher import <serverId> --from <clientId>');
          console.log('  mcp-launcher import --all-from <clientId>');
          console.log('\nRun "mcp-launcher discover" to see available servers');
          process.exit(1);
        }

      } catch (error: any) {
        console.error('Error:', error.message);
        process.exit(1);
      }
    });
}
