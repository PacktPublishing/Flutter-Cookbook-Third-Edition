/**
 * Init command - Initialize MCP Launcher
 */

import { Command } from 'commander';
import { ConfigManager } from '../../core/config-manager.js';
import { getDefaultConfigPath, KNOWN_CLIENTS } from '../../core/types.js';
import * as fs from 'fs/promises';

export function initCommand(program: Command) {
  program
    .command('init')
    .description('Initialize MCP Launcher and optionally register MCP clients')
    .option('--claude-config-path <path>', 'Path to Claude Desktop MCP config file')
    .option('--cursor-config-path <path>', 'Path to Cursor MCP config file')
    .option('--gemini-config-path <path>', 'Path to Gemini VS Code MCP config file')
    .option('--windsurf-config-path <path>', 'Path to Windsurf MCP config file')
    .action(async (options) => {
      try {
        const configManager = new ConfigManager();

        // Check if config already exists
        if (await configManager.exists()) {
          console.log('⚠️  MCP Launcher is already initialized');
          console.log(`Config file: ${configManager.getConfigPath()}`);
          return;
        }

        // Initialize config
        await configManager.init();
        console.log(`✔ Created MCP Launcher config at: ${configManager.getConfigPath()}\n`);

        // Register clients
        const clientsToRegister = [
          { id: 'claude-desktop', pathOption: options.claudeConfigPath },
          { id: 'cursor', pathOption: options.cursorConfigPath },
          { id: 'gemini-vscode', pathOption: options.geminiConfigPath },
          { id: 'windsurf', pathOption: options.windsurfConfigPath }
        ];

        for (const { id, pathOption } of clientsToRegister) {
          const configPath = pathOption || getDefaultConfigPath(id);

          if (configPath) {
            // Check if config file exists
            try {
              await fs.access(configPath);

              const clientInfo = KNOWN_CLIENTS[id];
              await configManager.registerClient({
                ...clientInfo,
                configPath
              });

              console.log(`✔ Registered client "${clientInfo.displayName}" at ${configPath}`);
            } catch {
              // Config file doesn't exist, skip silently
              if (pathOption) {
                console.log(`⚠️  Config file not found: ${configPath}`);
              }
            }
          }
        }

        console.log('\nYou can now manage MCP servers with:');
        console.log('  mcp-launcher list           List servers and clients');
        console.log('  mcp-launcher bind           Bind server to client(s)');
        console.log('  mcp-launcher unbind         Unbind server from client(s)');
        console.log('  mcp-launcher start          Start server instance(s)');
        console.log('  mcp-launcher stop           Stop server instance(s)');
      } catch (error: any) {
        console.error('Error:', error.message);
        process.exit(1);
      }
    });
}
