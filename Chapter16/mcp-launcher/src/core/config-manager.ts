/**
 * Config manager for reading/writing launcher configuration
 */

import * as fs from 'fs/promises';
import * as path from 'path';
import { LauncherConfig, Binding, McpServerDefinition, ClientConfigInfo } from './types.js';

export class ConfigManager {
  private configPath: string;
  private config: LauncherConfig | null = null;

  constructor(configPath?: string) {
    const homeDir = process.env.HOME || process.env.USERPROFILE || '';
    this.configPath = configPath || path.join(homeDir, '.mcp-launcher', 'config.json');
  }

  /**
   * Initialize a new launcher config file
   */
  async init(): Promise<void> {
    const configDir = path.dirname(this.configPath);
    await fs.mkdir(configDir, { recursive: true });

    const initialConfig: LauncherConfig = {
      version: 1,
      servers: {},
      clients: {},
      bindings: [],
      preferences: {
        defaultIsolationMode: 'isolated'
      }
    };

    await fs.writeFile(this.configPath, JSON.stringify(initialConfig, null, 2), 'utf-8');
    this.config = initialConfig;
  }

  /**
   * Check if config file exists
   */
  async exists(): Promise<boolean> {
    try {
      await fs.access(this.configPath);
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Load config from disk
   */
  async load(): Promise<LauncherConfig> {
    const content = await fs.readFile(this.configPath, 'utf-8');
    this.config = JSON.parse(content);
    return this.config!;
  }

  /**
   * Save config to disk
   */
  async save(config: LauncherConfig): Promise<void> {
    await fs.writeFile(this.configPath, JSON.stringify(config, null, 2), 'utf-8');
    this.config = config;
  }

  /**
   * Get current config (loads if not already loaded)
   */
  async getConfig(): Promise<LauncherConfig> {
    if (!this.config) {
      await this.load();
    }
    return this.config!;
  }

  /**
   * Register a client
   */
  async registerClient(client: ClientConfigInfo): Promise<void> {
    const config = await this.getConfig();
    config.clients[client.id] = client;
    await this.save(config);
  }

  /**
   * Get all clients
   */
  async getClients(): Promise<ClientConfigInfo[]> {
    const config = await this.getConfig();
    return Object.values(config.clients);
  }

  /**
   * Get a specific client
   */
  async getClient(clientId: string): Promise<ClientConfigInfo | undefined> {
    const config = await this.getConfig();
    return config.clients[clientId];
  }

  /**
   * Add a server definition
   */
  async addServer(server: McpServerDefinition): Promise<void> {
    const config = await this.getConfig();
    config.servers[server.id] = server;
    await this.save(config);
  }

  /**
   * Get all servers
   */
  async getServers(): Promise<McpServerDefinition[]> {
    const config = await this.getConfig();
    return Object.values(config.servers);
  }

  /**
   * Get a specific server
   */
  async getServer(serverId: string): Promise<McpServerDefinition | undefined> {
    const config = await this.getConfig();
    return config.servers[serverId];
  }

  /**
   * Delete a server
   */
  async deleteServer(serverId: string): Promise<void> {
    const config = await this.getConfig();
    delete config.servers[serverId];
    // Also remove all bindings for this server
    config.bindings = config.bindings.filter(b => b.serverId !== serverId);
    await this.save(config);
  }

  /**
   * Add a binding
   */
  async addBinding(serverId: string, clientId: string): Promise<void> {
    const config = await this.getConfig();

    // Check if binding already exists
    const existingIndex = config.bindings.findIndex(
      b => b.serverId === serverId && b.clientId === clientId
    );

    if (existingIndex >= 0) {
      config.bindings[existingIndex].enabled = true;
    } else {
      config.bindings.push({
        serverId,
        clientId,
        enabled: true
      });
    }

    await this.save(config);
  }

  /**
   * Remove a binding
   */
  async removeBinding(serverId: string, clientId: string): Promise<void> {
    const config = await this.getConfig();
    config.bindings = config.bindings.filter(
      b => !(b.serverId === serverId && b.clientId === clientId)
    );
    await this.save(config);
  }

  /**
   * Get all bindings
   */
  async getBindings(): Promise<Binding[]> {
    const config = await this.getConfig();
    return config.bindings.filter(b => b.enabled);
  }

  /**
   * Get bindings for a specific server
   */
  async getServerBindings(serverId: string): Promise<Binding[]> {
    const config = await this.getConfig();
    return config.bindings.filter(b => b.serverId === serverId && b.enabled);
  }

  /**
   * Get bindings for a specific client
   */
  async getClientBindings(clientId: string): Promise<Binding[]> {
    const config = await this.getConfig();
    return config.bindings.filter(b => b.clientId === clientId && b.enabled);
  }

  /**
   * Get clients using a specific server
   */
  async getClientsForServer(serverId: string): Promise<string[]> {
    const bindings = await this.getServerBindings(serverId);
    return bindings.map(b => b.clientId);
  }

  /**
   * Get servers used by a specific client
   */
  async getServersForClient(clientId: string): Promise<string[]> {
    const bindings = await this.getClientBindings(clientId);
    return bindings.map(b => b.serverId);
  }

  /**
   * Get config file path
   */
  getConfigPath(): string {
    return this.configPath;
  }
}
