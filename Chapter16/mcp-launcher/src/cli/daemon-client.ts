/**
 * Daemon client - Communicates with the daemon API
 */

import * as http from 'http';
import { PORT } from '../daemon/index.js';

export class DaemonClient {
  private baseUrl = `http://localhost:${PORT}`;

  async request(method: string, path: string, body?: any): Promise<any> {
    return new Promise((resolve, reject) => {
      const url = new URL(path, this.baseUrl);
      const options = {
        hostname: url.hostname,
        port: url.port,
        path: url.pathname + url.search,
        method,
        headers: {
          'Content-Type': 'application/json'
        }
      };

      const req = http.request(options, (res) => {
        let data = '';

        res.on('data', (chunk) => {
          data += chunk;
        });

        res.on('end', () => {
          try {
            const json = JSON.parse(data);
            if (res.statusCode && res.statusCode >= 200 && res.statusCode < 300) {
              resolve(json);
            } else {
              reject(new Error(json.error || `HTTP ${res.statusCode}`));
            }
          } catch (error) {
            reject(new Error('Failed to parse response'));
          }
        });
      });

      req.on('error', (error: any) => {
        if (error.code === 'ECONNREFUSED') {
          reject(new Error('Daemon is not running. Start it with: mcp-launcher daemon start'));
        } else {
          reject(error);
        }
      });

      if (body) {
        req.write(JSON.stringify(body));
      }

      req.end();
    });
  }

  async health(): Promise<any> {
    return this.request('GET', '/health');
  }

  async getServers(): Promise<any[]> {
    return this.request('GET', '/servers');
  }

  async startServer(serverId: string, clientId: string, mode: 'isolated' | 'shared' = 'isolated'): Promise<any> {
    return this.request('POST', `/servers/${serverId}/start`, { clientId, mode });
  }

  async stopServer(serverId: string, clientId?: string): Promise<any> {
    return this.request('POST', `/servers/${serverId}/stop`, { clientId });
  }

  async getServerStatus(serverId: string): Promise<any> {
    return this.request('GET', `/servers/${serverId}/status`);
  }

  async getInstances(): Promise<any[]> {
    return this.request('GET', '/instances');
  }
}
