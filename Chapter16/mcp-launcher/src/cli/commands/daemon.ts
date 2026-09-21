/**
 * Daemon command - Manage daemon process
 */

import { Command } from 'commander';
import { spawn } from 'child_process';
import { DaemonClient } from '../daemon-client.js';
import { DAEMON_PID_FILE } from '../../daemon/index.js';
import * as fs from 'fs/promises';
import * as path from 'path';

export function daemonCommand(program: Command) {
  const daemon = program
    .command('daemon')
    .description('Manage the MCP Launcher daemon process');

  // daemon start
  daemon
    .command('start')
    .description('Start the daemon')
    .option('-d, --detach', 'Run in background (detached mode)')
    .action(async (options) => {
      try {
        const client = new DaemonClient();

        // Check if already running
        try {
          await client.health();
          console.log('Daemon is already running');
          return;
        } catch {
          // Not running, proceed to start
        }

        if (options.detach) {
          // Start daemon in background
          const daemonScript = path.join(
            path.dirname(new URL(import.meta.url).pathname),
            '../../daemon/index.js'
          );

          const child = spawn('node', [daemonScript], {
            detached: true,
            stdio: 'ignore'
          });

          child.unref();

          // Wait a bit for daemon to start
          await new Promise(resolve => setTimeout(resolve, 1000));

          // Verify it started
          try {
            const health = await client.health();
            console.log('✔ Daemon started');
            console.log(`PID: ${health.pid}`);
          } catch {
            console.error('Failed to start daemon');
            process.exit(1);
          }

        } else {
          // Start daemon in foreground
          console.log('Starting daemon in foreground mode...');
          console.log('Press Ctrl+C to stop\n');

          const daemonScript = path.join(
            path.dirname(new URL(import.meta.url).pathname),
            '../../daemon/index.js'
          );

          const child = spawn('node', [daemonScript], {
            stdio: 'inherit'
          });

          child.on('exit', (code) => {
            console.log(`Daemon exited with code ${code}`);
          });
        }

      } catch (error: any) {
        console.error('Error:', error.message);
        process.exit(1);
      }
    });

  // daemon status
  daemon
    .command('status')
    .description('Show daemon status')
    .action(async () => {
      try {
        const client = new DaemonClient();

        const health = await client.health();
        const instances = await client.getInstances();

        console.log('✔ Daemon is running');
        console.log(`PID: ${health.pid}`);
        console.log(`\nManaged servers: ${instances.length}`);

        if (instances.length > 0) {
          console.log('\nRunning instances:');
          for (const instance of instances) {
            console.log(`  - ${instance.serverId} (${instance.mode})`);

            if (instance.shared) {
              console.log(`    PID: ${instance.shared.pid}`);
              console.log(`    Clients: ${instance.shared.attachedClients.join(', ')}`);
            } else if (instance.byClient) {
              const clients = Object.keys(instance.byClient);
              console.log(`    Clients: ${clients.join(', ')}`);
            }
          }
        }

      } catch (error: any) {
        console.error('Error:', error.message);

        if (error.message.includes('not running')) {
          console.log('\nDaemon is not running');
          console.log('Start it with: mcp-launcher daemon start');
        }

        process.exit(1);
      }
    });

  // daemon stop
  daemon
    .command('stop')
    .description('Stop the daemon')
    .action(async () => {
      try {
        // Read PID file
        const pidStr = await fs.readFile(DAEMON_PID_FILE, 'utf-8');
        const pid = parseInt(pidStr.trim(), 10);

        if (isNaN(pid)) {
          console.log('Daemon PID file is invalid');
          return;
        }

        // Send SIGTERM
        try {
          process.kill(pid, 'SIGTERM');
          console.log(`✔ Sent stop signal to daemon (PID ${pid})`);

          // Wait for it to stop
          await new Promise(resolve => setTimeout(resolve, 1000));

          // Verify it stopped
          try {
            process.kill(pid, 0); // Check if still running
            console.log('⚠️  Daemon is still running, you may need to force kill it');
          } catch {
            console.log('✔ Daemon stopped');
          }

        } catch (error: any) {
          if (error.code === 'ESRCH') {
            console.log('Daemon is not running (stale PID file)');
            await fs.unlink(DAEMON_PID_FILE);
          } else {
            throw error;
          }
        }

      } catch (error: any) {
        if (error.code === 'ENOENT') {
          console.log('Daemon is not running');
        } else {
          console.error('Error:', error.message);
          process.exit(1);
        }
      }
    });
}
