/**
 * Discover command - Find MCP servers from client configs and packages
 */

import { Command } from 'commander';
import { ConfigManager } from '../../core/config-manager.js';
import { DiscoveryService } from '../../core/discovery.js';

export function discoverCommand(program: Command) {
  program
    .command('discover')
    .description('Discover MCP servers from client configs and installed packages')
    .option('--clients-only', 'Only discover from client configs')
    .option('--packages-only', 'Only discover from npm/pip packages')
    .action(async (options) => {
      try {
        const configManager = new ConfigManager();

        if (!(await configManager.exists())) {
          console.log('MCP Launcher not initialized. Run: mcp-launcher init');
          process.exit(1);
        }

        const discoveryService = new DiscoveryService(configManager);

        console.log('Discovering MCP servers...\n');

        if (options.packagesOnly) {
          // Future: discover from npm/pip
          console.log('📦 Package discovery coming soon!');
          return;
        }

        // Discover from client configs
        const fromClients = await discoveryService.discoverFromClients();

        if (fromClients.length === 0) {
          console.log('No servers found in client configs.');
          console.log('\nMake sure you have registered clients with: mcp-launcher init');
          return;
        }

        // Group by status
        const notInLauncher = fromClients.filter(s => !s.alreadyInLauncher);
        const alreadyInLauncher = fromClients.filter(s => s.alreadyInLauncher);

        // Group not-in-launcher by source
        const bySource = new Map<string, typeof notInLauncher>();
        for (const server of notInLauncher) {
          if (!bySource.has(server.source)) {
            bySource.set(server.source, []);
          }
          bySource.get(server.source)!.push(server);
        }

        // Display discovered servers
        console.log('📋 Discovered Servers from Client Configs:\n');

        if (notInLauncher.length > 0) {
          console.log('Not yet in MCP Launcher:');
          for (const [source, servers] of bySource) {
            const clients = await configManager.getClients();
            const client = clients.find(c => c.id === source);
            const clientName = client?.displayName || source;

            console.log(`\n  From ${clientName}:`);
            for (const server of servers) {
              console.log(`    • ${server.id}`);
              if (server.command) {
                console.log(`      Command: ${server.command} ${(server.args || []).join(' ')}`);
              }
            }
          }

          console.log('\n💡 Import servers with:');
          console.log('   mcp-launcher import <serverId> --from <clientId>');
          console.log('   mcp-launcher import --all-from <clientId>');
        }

        if (alreadyInLauncher.length > 0) {
          console.log('\n✓ Already in MCP Launcher:');
          for (const server of alreadyInLauncher) {
            const clients = await configManager.getClients();
            const client = clients.find(c => c.id === server.source);
            const clientName = client?.displayName || server.source;
            console.log(`  • ${server.id} (from ${clientName})`);
          }
        }

        // Show summary
        console.log(`\n📊 Summary:`);
        console.log(`   Total discovered: ${fromClients.length}`);
        console.log(`   Ready to import: ${notInLauncher.length}`);
        console.log(`   Already managed: ${alreadyInLauncher.length}`);

      } catch (error: any) {
        console.error('Error:', error.message);
        process.exit(1);
      }
    });
}
