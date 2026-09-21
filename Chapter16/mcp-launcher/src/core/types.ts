/**
 * Core data model for MCP Launcher
 */

export type TransportType = 'stdio' | 'sse';
export type IsolationMode = 'isolated' | 'shared';
export type InstanceStatus = 'running' | 'stopped' | 'error';

/**
 * Credential configuration reference (not raw values)
 */
export interface CredentialConfig {
  env: Record<string, string>; // env var names, not values
}

/**
 * UI resource metadata for MCP Apps
 */
export interface UIResource {
  uri: string;
  name: string;
  description?: string;
}

/**
 * MCP Server definition
 */
export interface McpServerDefinition {
  id: string;
  name: string;
  description?: string;
  transport: TransportType;

  // For stdio servers
  command?: string;
  args?: string[];

  // For SSE servers
  url?: string;

  // Credentials (by reference)
  credentials?: CredentialConfig;

  // UI support (optional)
  supportsUI?: boolean;
  uiResources?: UIResource[];
}

/**
 * Client configuration info
 */
export interface ClientConfigInfo {
  id: string;
  displayName: string;
  configPath: string;
  type: 'json';
}

/**
 * Binding between server and client
 */
export interface Binding {
  serverId: string;
  clientId: string;
  enabled: boolean;
}

/**
 * Launcher preferences
 */
export interface LauncherPreferences {
  defaultIsolationMode: IsolationMode;
}

/**
 * Main launcher configuration
 */
export interface LauncherConfig {
  version: number;
  servers: Record<string, McpServerDefinition>;
  clients: Record<string, ClientConfigInfo>;
  bindings: Binding[];
  preferences?: LauncherPreferences;
}

/**
 * Runtime instance details for a specific client
 */
export interface InstanceDetails {
  pid: number;
  url?: string;
  status: InstanceStatus;
  startedAt: Date;
}

/**
 * Shared instance details
 */
export interface SharedInstanceDetails {
  pid: number;
  url?: string;
  attachedClients: string[];
  status: InstanceStatus;
  startedAt: Date;
}

/**
 * Runtime server instance information (managed by daemon)
 */
export interface ServerInstanceInfo {
  serverId: string;
  mode: IsolationMode;
  byClient?: Record<string, InstanceDetails>;
  shared?: SharedInstanceDetails;
}

/**
 * Known MCP clients and their default config paths
 */
export const KNOWN_CLIENTS: Record<string, Omit<ClientConfigInfo, 'configPath'>> = {
  'claude-desktop': {
    id: 'claude-desktop',
    displayName: 'Claude Desktop',
    type: 'json'
  },
  'cursor': {
    id: 'cursor',
    displayName: 'Cursor IDE',
    type: 'json'
  },
  'gemini-vscode': {
    id: 'gemini-vscode',
    displayName: 'Gemini VS Code',
    type: 'json'
  },
  'windsurf': {
    id: 'windsurf',
    displayName: 'Windsurf',
    type: 'json'
  }
};

/**
 * Default config paths by platform
 */
export function getDefaultConfigPath(clientId: string, platform: NodeJS.Platform = process.platform): string | null {
  const homeDir = process.env.HOME || process.env.USERPROFILE || '';

  switch (clientId) {
    case 'claude-desktop':
      if (platform === 'darwin') {
        return `${homeDir}/Library/Application Support/Claude/claude_desktop_config.json`;
      } else if (platform === 'linux') {
        return `${homeDir}/.config/Claude/claude_desktop_config.json`;
      } else if (platform === 'win32') {
        return `${homeDir}\\AppData\\Roaming\\Claude\\claude_desktop_config.json`;
      }
      return null;

    case 'cursor':
      if (platform === 'darwin') {
        return `${homeDir}/.cursor/mcp.json`;
      } else if (platform === 'linux') {
        return `${homeDir}/.cursor/mcp.json`;
      } else if (platform === 'win32') {
        return `${homeDir}\\.cursor\\mcp.json`;
      }
      return null;

    case 'gemini-vscode':
      // Gemini typically uses VS Code settings
      if (platform === 'darwin') {
        return `${homeDir}/Library/Application Support/Code/User/settings.json`;
      } else if (platform === 'linux') {
        return `${homeDir}/.config/Code/User/settings.json`;
      } else if (platform === 'win32') {
        return `${homeDir}\\AppData\\Roaming\\Code\\User\\settings.json`;
      }
      return null;

    case 'windsurf':
      if (platform === 'darwin') {
        return `${homeDir}/.windsurf/mcp.json`;
      } else if (platform === 'linux') {
        return `${homeDir}/.windsurf/mcp.json`;
      } else if (platform === 'win32') {
        return `${homeDir}\\.windsurf\\mcp.json`;
      }
      return null;

    default:
      return null;
  }
}
