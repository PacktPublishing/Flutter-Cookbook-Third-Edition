/**
 * Discovery service - Find MCP servers from various sources
 */

import { ConfigManager } from './config-manager.js';
import { getClientAdapter } from './client-adapter.js';
import { McpServerDefinition } from './types.js';

export interface DiscoveredServer {
  id: string;
  name: string;
  source: string; // e.g., "claude-desktop", "cursor"
  transport: 'stdio' | 'sse';
  command?: string;
  args?: string[];
  url?: string;
  env?: Record<string, string>;
  alreadyInLauncher: boolean;
}

export class DiscoveryService {
  constructor(private configManager: ConfigManager) {}

  /**
   * Discover servers from all registered client configs
   */
  async discoverFromClients(): Promise<DiscoveredServer[]> {
    const clients = await this.configManager.getClients();
    const launcherServers = await this.configManager.getServers();
    const launcherServerIds = new Set(launcherServers.map(s => s.id));

    const discovered: DiscoveredServer[] = [];

    for (const client of clients) {
      try {
        const adapter = getClientAdapter(client.id, client.configPath);
        const clientConfig = await adapter.read();

        // Parse each server in the client config
        for (const [serverId, serverConfig] of Object.entries(clientConfig.mcpServers)) {
          const isInLauncher = launcherServerIds.has(serverId);

          discovered.push({
            id: serverId,
            name: serverId, // Use ID as name if not specified
            source: client.id,
            transport: 'stdio', // Most servers are stdio
            command: serverConfig.command,
            args: serverConfig.args,
            env: serverConfig.env,
            alreadyInLauncher: isInLauncher
          });
        }
      } catch (error) {
        // Skip clients that have errors reading config
        console.warn(`Warning: Could not read config for ${client.id}`);
      }
    }

    return discovered;
  }

  /**
   * Discover servers from npm packages (future implementation)
   */
  async discoverFromNpm(): Promise<DiscoveredServer[]> {
    // TODO: Scan for installed npm packages matching MCP patterns
    // - @modelcontextprotocol/server-*
    // - mcp-server-*
    // - *-mcp-server
    return [];
  }

  /**
   * Discover servers from pip packages (future implementation)
   */
  async discoverFromPip(): Promise<DiscoveredServer[]> {
    // TODO: Scan for installed pip packages
    return [];
  }

  /**
   * Discover from all sources
   */
  async discoverAll(): Promise<{
    fromClients: DiscoveredServer[];
    fromNpm: DiscoveredServer[];
    fromPip: DiscoveredServer[];
  }> {
    const [fromClients, fromNpm, fromPip] = await Promise.all([
      this.discoverFromClients(),
      this.discoverFromNpm(),
      this.discoverFromPip()
    ]);

    return { fromClients, fromNpm, fromPip };
  }

  /**
   * Convert discovered server to launcher server definition
   */
  toServerDefinition(discovered: DiscoveredServer): McpServerDefinition {
    return {
      id: discovered.id,
      name: discovered.name,
      transport: discovered.transport,
      command: discovered.command,
      args: discovered.args,
      url: discovered.url,
      credentials: discovered.env ? { env: discovered.env } : undefined
    };
  }
}
