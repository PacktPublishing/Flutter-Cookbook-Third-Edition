/**
 * Client adapters for reading/writing MCP config files
 */

import * as fs from 'fs/promises';
import { McpServerDefinition } from './types.js';

/**
 * Generic MCP config format (Claude, Cursor, etc.)
 */
export interface McpClientConfig {
  mcpServers: Record<string, {
    command: string;
    args?: string[];
    env?: Record<string, string>;
  }>;
}

/**
 * Base client adapter interface
 */
export interface ClientAdapter {
  read(): Promise<McpClientConfig>;
  write(config: McpClientConfig): Promise<void>;
  generateConfig(servers: McpServerDefinition[]): McpClientConfig;
}

/**
 * Claude Desktop adapter
 */
export class ClaudeAdapter implements ClientAdapter {
  constructor(private configPath: string) {}

  async read(): Promise<McpClientConfig> {
    try {
      const content = await fs.readFile(this.configPath, 'utf-8');
      return JSON.parse(content);
    } catch (error: any) {
      if (error.code === 'ENOENT') {
        return { mcpServers: {} };
      }
      throw error;
    }
  }

  async write(config: McpClientConfig): Promise<void> {
    await fs.writeFile(this.configPath, JSON.stringify(config, null, 2), 'utf-8');
  }

  generateConfig(servers: McpServerDefinition[]): McpClientConfig {
    const mcpServers: Record<string, any> = {};

    for (const server of servers) {
      if (server.transport === 'stdio' && server.command) {
        mcpServers[server.id] = {
          command: server.command,
          args: server.args || [],
          env: this.getEnvValues(server.credentials?.env || {})
        };
      } else if (server.transport === 'sse' && server.url) {
        // For SSE servers, use a special command format or skip
        // This depends on how Claude handles SSE servers
        mcpServers[server.id] = {
          command: 'mcp-client',
          args: ['connect', server.url],
          env: this.getEnvValues(server.credentials?.env || {})
        };
      }
    }

    return { mcpServers };
  }

  private getEnvValues(envNames: Record<string, string>): Record<string, string> {
    const result: Record<string, string> = {};
    for (const [key, value] of Object.entries(envNames)) {
      // Get actual env var value from process.env
      result[key] = process.env[key] || value;
    }
    return result;
  }
}

/**
 * Cursor adapter
 */
export class CursorAdapter implements ClientAdapter {
  constructor(private configPath: string) {}

  async read(): Promise<McpClientConfig> {
    try {
      const content = await fs.readFile(this.configPath, 'utf-8');
      return JSON.parse(content);
    } catch (error: any) {
      if (error.code === 'ENOENT') {
        return { mcpServers: {} };
      }
      throw error;
    }
  }

  async write(config: McpClientConfig): Promise<void> {
    await fs.writeFile(this.configPath, JSON.stringify(config, null, 2), 'utf-8');
  }

  generateConfig(servers: McpServerDefinition[]): McpClientConfig {
    const mcpServers: Record<string, any> = {};

    for (const server of servers) {
      if (server.transport === 'stdio' && server.command) {
        mcpServers[server.id] = {
          command: server.command,
          args: server.args || [],
          env: this.getEnvValues(server.credentials?.env || {})
        };
      } else if (server.transport === 'sse' && server.url) {
        mcpServers[server.id] = {
          command: 'mcp-client',
          args: ['connect', server.url],
          env: this.getEnvValues(server.credentials?.env || {})
        };
      }
    }

    return { mcpServers };
  }

  private getEnvValues(envNames: Record<string, string>): Record<string, string> {
    const result: Record<string, string> = {};
    for (const [key, value] of Object.entries(envNames)) {
      result[key] = process.env[key] || value;
    }
    return result;
  }
}

/**
 * Gemini VS Code adapter (uses VS Code settings.json)
 */
export class GeminiAdapter implements ClientAdapter {
  constructor(private configPath: string) {}

  async read(): Promise<McpClientConfig> {
    try {
      const content = await fs.readFile(this.configPath, 'utf-8');
      const settings = JSON.parse(content);

      // Gemini MCP config might be under a specific key
      const mcpServers = settings['gemini.mcpServers'] || settings['mcpServers'] || {};

      return { mcpServers };
    } catch (error: any) {
      if (error.code === 'ENOENT') {
        return { mcpServers: {} };
      }
      throw error;
    }
  }

  async write(config: McpClientConfig): Promise<void> {
    let settings: any = {};

    try {
      const content = await fs.readFile(this.configPath, 'utf-8');
      settings = JSON.parse(content);
    } catch {
      // File doesn't exist, start with empty settings
    }

    // Update the MCP servers section
    settings['gemini.mcpServers'] = config.mcpServers;

    await fs.writeFile(this.configPath, JSON.stringify(settings, null, 2), 'utf-8');
  }

  generateConfig(servers: McpServerDefinition[]): McpClientConfig {
    const mcpServers: Record<string, any> = {};

    for (const server of servers) {
      if (server.transport === 'stdio' && server.command) {
        mcpServers[server.id] = {
          command: server.command,
          args: server.args || [],
          env: this.getEnvValues(server.credentials?.env || {})
        };
      } else if (server.transport === 'sse' && server.url) {
        mcpServers[server.id] = {
          command: 'mcp-client',
          args: ['connect', server.url],
          env: this.getEnvValues(server.credentials?.env || {})
        };
      }
    }

    return { mcpServers };
  }

  private getEnvValues(envNames: Record<string, string>): Record<string, string> {
    const result: Record<string, string> = {};
    for (const [key, value] of Object.entries(envNames)) {
      result[key] = process.env[key] || value;
    }
    return result;
  }
}

/**
 * Factory to get the right adapter for a client
 */
export function getClientAdapter(clientId: string, configPath: string): ClientAdapter {
  switch (clientId) {
    case 'claude-desktop':
      return new ClaudeAdapter(configPath);
    case 'cursor':
      return new CursorAdapter(configPath);
    case 'gemini-vscode':
      return new GeminiAdapter(configPath);
    case 'windsurf':
      return new CursorAdapter(configPath); // Windsurf uses similar format to Cursor
    default:
      throw new Error(`Unknown client: ${clientId}`);
  }
}
