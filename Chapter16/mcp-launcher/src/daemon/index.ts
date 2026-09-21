/**
 * MCP Launcher Daemon
 * Manages running MCP server instances and provides API for CLI
 */

import express from 'express';
import { InstanceManager } from './instance-manager.js';
import { ConfigManager } from '../core/config-manager.js';
import * as fs from 'fs/promises';
import * as path from 'path';

const PORT = 8765;
const DAEMON_PID_FILE = path.join(
  process.env.HOME || process.env.USERPROFILE || '',
  '.mcp-launcher',
  'daemon.pid'
);

export class Daemon {
  private app: express.Application;
  private instanceManager: InstanceManager;
  private configManager: ConfigManager;

  constructor() {
    this.app = express();
    this.instanceManager = new InstanceManager();
    this.configManager = new ConfigManager();

    this.setupRoutes();
  }

  private setupRoutes() {
    this.app.use(express.json());

    // Health check
    this.app.get('/health', (req, res) => {
      res.json({ status: 'ok', pid: process.pid });
    });

    // Get all servers
    this.app.get('/servers', async (req, res) => {
      try {
        const servers = await this.configManager.getServers();
        const instances = this.instanceManager.getAllInstances();

        const result = servers.map(server => {
          const instance = instances.find(i => i.serverId === server.id);
          return {
            ...server,
            instance: instance || null
          };
        });

        res.json(result);
      } catch (error: any) {
        res.status(500).json({ error: error.message });
      }
    });

    // Start server
    this.app.post('/servers/:id/start', async (req, res) => {
      try {
        const { id } = req.params;
        const { clientId, mode = 'isolated' } = req.body;

        if (!clientId) {
          return res.status(400).json({ error: 'clientId is required' });
        }

        const server = await this.configManager.getServer(id);
        if (!server) {
          return res.status(404).json({ error: `Server ${id} not found` });
        }

        const details = await this.instanceManager.startServer(server, clientId, mode);

        res.json({
          success: true,
          serverId: id,
          clientId,
          mode,
          details
        });
      } catch (error: any) {
        res.status(500).json({ error: error.message });
      }
    });

    // Stop server
    this.app.post('/servers/:id/stop', async (req, res) => {
      try {
        const { id } = req.params;
        const { clientId } = req.body;

        await this.instanceManager.stopServer(id, clientId);

        res.json({
          success: true,
          serverId: id,
          clientId: clientId || 'all'
        });
      } catch (error: any) {
        res.status(500).json({ error: error.message });
      }
    });

    // Get server instance status
    this.app.get('/servers/:id/status', (req, res) => {
      try {
        const { id } = req.params;
        const instance = this.instanceManager.getInstance(id);

        res.json({
          serverId: id,
          running: !!instance,
          instance: instance || null
        });
      } catch (error: any) {
        res.status(500).json({ error: error.message });
      }
    });

    // Get all instances
    this.app.get('/instances', (req, res) => {
      try {
        const instances = this.instanceManager.getAllInstances();
        res.json(instances);
      } catch (error: any) {
        res.status(500).json({ error: error.message });
      }
    });
  }

  async start() {
    // Write PID file
    await fs.mkdir(path.dirname(DAEMON_PID_FILE), { recursive: true });
    await fs.writeFile(DAEMON_PID_FILE, process.pid.toString(), 'utf-8');

    return new Promise<void>((resolve, reject) => {
      this.app.listen(PORT, () => {
        console.log(`MCP Launcher daemon started on port ${PORT}`);
        console.log(`PID: ${process.pid}`);
        resolve();
      }).on('error', reject);
    });
  }

  async stop() {
    // Clean up PID file
    try {
      await fs.unlink(DAEMON_PID_FILE);
    } catch {
      // Ignore if file doesn't exist
    }

    // Stop all instances
    const instances = this.instanceManager.getAllInstances();
    for (const instance of instances) {
      await this.instanceManager.stopServer(instance.serverId);
    }

    process.exit(0);
  }
}

// Start daemon if this is the main module
if (import.meta.url === `file://${process.argv[1]}`) {
  const daemon = new Daemon();

  daemon.start().catch((error) => {
    console.error('Failed to start daemon:', error);
    process.exit(1);
  });

  // Handle shutdown
  process.on('SIGTERM', () => {
    console.log('Received SIGTERM, shutting down...');
    daemon.stop();
  });

  process.on('SIGINT', () => {
    console.log('Received SIGINT, shutting down...');
    daemon.stop();
  });
}

export { DAEMON_PID_FILE, PORT };
