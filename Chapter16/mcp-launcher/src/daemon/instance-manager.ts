/**
 * Instance manager - Manages running MCP server instances
 */

import { spawn, ChildProcess } from 'child_process';
import { McpServerDefinition, ServerInstanceInfo, InstanceDetails, IsolationMode } from '../core/types.js';

export class InstanceManager {
  private instances: Map<string, ServerInstanceInfo> = new Map();

  /**
   * Start a server instance
   */
  async startServer(
    server: McpServerDefinition,
    clientId: string,
    mode: IsolationMode = 'isolated'
  ): Promise<InstanceDetails> {
    const instanceKey = this.getInstanceKey(server.id, mode === 'isolated' ? clientId : undefined);

    // Check if already running
    const existingInstance = this.instances.get(server.id);
    if (existingInstance) {
      if (mode === 'shared' && existingInstance.shared) {
        // Add client to shared instance
        if (!existingInstance.shared.attachedClients.includes(clientId)) {
          existingInstance.shared.attachedClients.push(clientId);
        }
        return {
          pid: existingInstance.shared.pid,
          url: existingInstance.shared.url,
          status: existingInstance.shared.status,
          startedAt: existingInstance.shared.startedAt
        };
      } else if (mode === 'isolated' && existingInstance.byClient?.[clientId]) {
        // Already running for this client
        return existingInstance.byClient[clientId];
      }
    }

    // Start new process
    if (server.transport === 'stdio') {
      return this.startStdioServer(server, clientId);
    } else if (server.transport === 'sse') {
      return this.startSseServer(server, clientId, mode);
    }

    throw new Error(`Unsupported transport: ${server.transport}`);
  }

  /**
   * Start stdio server (always isolated)
   */
  private async startStdioServer(
    server: McpServerDefinition,
    clientId: string
  ): Promise<InstanceDetails> {
    if (!server.command) {
      throw new Error(`Server ${server.id} has no command specified`);
    }

    const env = { ...process.env };
    if (server.credentials?.env) {
      Object.assign(env, server.credentials.env);
    }

    const childProcess = spawn(server.command, server.args || [], {
      env,
      stdio: ['pipe', 'pipe', 'pipe']
    });

    const details: InstanceDetails = {
      pid: childProcess.pid!,
      status: 'running',
      startedAt: new Date()
    };

    // Track instance
    let instanceInfo = this.instances.get(server.id);
    if (!instanceInfo) {
      instanceInfo = {
        serverId: server.id,
        mode: 'isolated',
        byClient: {}
      };
      this.instances.set(server.id, instanceInfo);
    }

    instanceInfo.byClient = instanceInfo.byClient || {};
    instanceInfo.byClient[clientId] = details;

    // Handle process events
    childProcess.on('exit', (code) => {
      if (instanceInfo?.byClient?.[clientId]) {
        instanceInfo.byClient[clientId].status = code === 0 ? 'stopped' : 'error';
      }
    });

    childProcess.on('error', (error) => {
      console.error(`Error starting server ${server.id}:`, error);
      if (instanceInfo?.byClient?.[clientId]) {
        instanceInfo.byClient[clientId].status = 'error';
      }
    });

    return details;
  }

  /**
   * Start SSE server
   */
  private async startSseServer(
    server: McpServerDefinition,
    clientId: string,
    mode: IsolationMode
  ): Promise<InstanceDetails> {
    if (server.url) {
      // Server is already running externally
      const details: InstanceDetails = {
        pid: -1, // External server
        url: server.url,
        status: 'running',
        startedAt: new Date()
      };

      let instanceInfo = this.instances.get(server.id);
      if (!instanceInfo) {
        instanceInfo = {
          serverId: server.id,
          mode,
          byClient: mode === 'isolated' ? {} : undefined,
          shared: mode === 'shared' ? {
            pid: -1,
            url: server.url,
            attachedClients: [clientId],
            status: 'running',
            startedAt: new Date()
          } : undefined
        };
        this.instances.set(server.id, instanceInfo);
      }

      if (mode === 'isolated' && instanceInfo.byClient) {
        instanceInfo.byClient[clientId] = details;
      }

      return details;
    }

    if (!server.command) {
      throw new Error(`Server ${server.id} has no command or URL specified`);
    }

    const env = { ...process.env };
    if (server.credentials?.env) {
      Object.assign(env, server.credentials.env);
    }

    const childProcess = spawn(server.command, server.args || [], {
      env,
      stdio: ['pipe', 'pipe', 'pipe']
    });

    // For SSE servers, we need to detect the URL from stdout
    // This is a simplified implementation
    const url = `http://127.0.0.1:${8000 + Math.floor(Math.random() * 1000)}/mcp`;

    const details: InstanceDetails = {
      pid: childProcess.pid!,
      url,
      status: 'running',
      startedAt: new Date()
    };

    // Track instance
    let instanceInfo = this.instances.get(server.id);
    if (!instanceInfo) {
      instanceInfo = {
        serverId: server.id,
        mode,
        byClient: mode === 'isolated' ? {} : undefined,
        shared: mode === 'shared' ? {
          pid: childProcess.pid!,
          url,
          attachedClients: [clientId],
          status: 'running',
          startedAt: new Date()
        } : undefined
      };
      this.instances.set(server.id, instanceInfo);
    }

    if (mode === 'isolated' && instanceInfo.byClient) {
      instanceInfo.byClient[clientId] = details;
    } else if (mode === 'shared' && instanceInfo.shared) {
      if (!instanceInfo.shared.attachedClients.includes(clientId)) {
        instanceInfo.shared.attachedClients.push(clientId);
      }
    }

    // Handle process events
    childProcess.on('exit', (code) => {
      if (mode === 'shared' && instanceInfo?.shared) {
        instanceInfo.shared.status = code === 0 ? 'stopped' : 'error';
      } else if (mode === 'isolated' && instanceInfo?.byClient?.[clientId]) {
        instanceInfo.byClient[clientId].status = code === 0 ? 'stopped' : 'error';
      }
    });

    childProcess.on('error', (error) => {
      console.error(`Error starting server ${server.id}:`, error);
      if (mode === 'shared' && instanceInfo?.shared) {
        instanceInfo.shared.status = 'error';
      } else if (mode === 'isolated' && instanceInfo?.byClient?.[clientId]) {
        instanceInfo.byClient[clientId].status = 'error';
      }
    });

    return details;
  }

  /**
   * Stop a server instance
   */
  async stopServer(serverId: string, clientId?: string): Promise<void> {
    const instanceInfo = this.instances.get(serverId);
    if (!instanceInfo) {
      throw new Error(`Server ${serverId} is not running`);
    }

    if (clientId) {
      // Stop specific client instance
      if (instanceInfo.byClient?.[clientId]) {
        const pid = instanceInfo.byClient[clientId].pid;
        if (pid > 0) {
          try {
            process.kill(pid, 'SIGTERM');
          } catch (error) {
            // Process might already be dead
          }
        }
        delete instanceInfo.byClient[clientId];

        if (Object.keys(instanceInfo.byClient).length === 0) {
          this.instances.delete(serverId);
        }
      } else if (instanceInfo.shared) {
        // Remove client from shared instance
        instanceInfo.shared.attachedClients = instanceInfo.shared.attachedClients.filter(
          c => c !== clientId
        );

        if (instanceInfo.shared.attachedClients.length === 0) {
          // No more clients, stop the shared instance
          const pid = instanceInfo.shared.pid;
          if (pid > 0) {
            try {
              process.kill(pid, 'SIGTERM');
            } catch (error) {
              // Process might already be dead
            }
          }
          this.instances.delete(serverId);
        }
      }
    } else {
      // Stop all instances
      if (instanceInfo.shared) {
        const pid = instanceInfo.shared.pid;
        if (pid > 0) {
          try {
            process.kill(pid, 'SIGTERM');
          } catch (error) {
            // Process might already be dead
          }
        }
      }

      if (instanceInfo.byClient) {
        for (const details of Object.values(instanceInfo.byClient)) {
          if (details.pid > 0) {
            try {
              process.kill(details.pid, 'SIGTERM');
            } catch (error) {
              // Process might already be dead
            }
          }
        }
      }

      this.instances.delete(serverId);
    }
  }

  /**
   * Get instance info
   */
  getInstance(serverId: string): ServerInstanceInfo | undefined {
    return this.instances.get(serverId);
  }

  /**
   * Get all instances
   */
  getAllInstances(): ServerInstanceInfo[] {
    return Array.from(this.instances.values());
  }

  /**
   * Check if server is running
   */
  isRunning(serverId: string, clientId?: string): boolean {
    const instanceInfo = this.instances.get(serverId);
    if (!instanceInfo) {
      return false;
    }

    if (clientId) {
      return !!(instanceInfo.byClient?.[clientId]?.status === 'running' ||
        instanceInfo.shared?.attachedClients.includes(clientId));
    }

    return !!(instanceInfo.shared?.status === 'running' ||
      Object.values(instanceInfo.byClient || {}).some(d => d.status === 'running'));
  }

  private getInstanceKey(serverId: string, clientId?: string): string {
    return clientId ? `${serverId}:${clientId}` : serverId;
  }
}
