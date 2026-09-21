# MCP Launcher - Quick Start Guide

## What You Just Built

You now have a complete v1 of MCP Launcher with:

✅ **Core functionality**
- Config management for servers, clients, and bindings
- Client adapters for Claude, Cursor, Gemini, and Windsurf
- Centralized launcher config at `~/.mcp-launcher/config.json`

✅ **CLI Commands**
- `init` - Initialize and register clients
- `list` - View servers, clients, bindings (with filters)
- `bind/unbind` - Manage server-client relationships
- `delete` - Remove servers (partial or full)
- `generate-config` - Sync client configs
- `start/stop` - Control server instances
- `daemon` - Manage the runtime daemon

✅ **Runtime Management**
- Daemon API for instance control
- Isolated vs. shared instance modes
- Process management for stdio and SSE servers

## Testing the CLI

### 1. Try the CLI
```bash
# See all commands
node dist/cli/index.js --help

# Get help for specific command
node dist/cli/index.js list --help
node dist/cli/index.js bind --help
```

### 2. Initialize (Dry Run)
```bash
# This will create ~/.mcp-launcher/config.json
# It will auto-detect Claude/Cursor configs if they exist
node dist/cli/index.js init
```

### 3. List Everything
```bash
# List all servers and clients
node dist/cli/index.js list

# List just servers
node dist/cli/index.js list servers

# List just clients
node dist/cli/index.js list clients

# List bindings
node dist/cli/index.js list bindings
```

## Next Steps

### Install Globally (Optional)
```bash
npm link
# Now you can use: mcp-launcher instead of node dist/cli/index.js
```

### Add Your First Server Manually

Since we haven't implemented the `add` command yet (it's in the roadmap), you can manually add a server to `~/.mcp-launcher/config.json`:

```json
{
  "version": 1,
  "servers": {
    "github": {
      "id": "github",
      "name": "GitHub MCP",
      "description": "GitHub API integration",
      "transport": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "credentials": {
        "env": {
          "GITHUB_TOKEN": "your-token-here"
        }
      }
    },
    "filesystem": {
      "id": "filesystem",
      "name": "Filesystem MCP",
      "transport": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/allowed/dir"]
    }
  },
  "clients": {},
  "bindings": [],
  "preferences": {
    "defaultIsolationMode": "isolated"
  }
}
```

### Try the Workflow

1. **Initialize**
   ```bash
   mcp-launcher init --claude-config-path "/path/to/claude/config.json"
   ```

2. **Bind a server**
   ```bash
   mcp-launcher bind github --client claude-desktop
   ```

3. **Generate config**
   ```bash
   mcp-launcher generate-config --client claude-desktop
   ```

4. **Start daemon**
   ```bash
   mcp-launcher daemon start -d
   ```

5. **Start server**
   ```bash
   mcp-launcher start github --client claude-desktop
   ```

6. **Check status**
   ```bash
   mcp-launcher daemon status
   ```

7. **Stop server**
   ```bash
   mcp-launcher stop github --client claude-desktop
   ```

## Project Structure

```
mcp-launcher/
├── src/
│   ├── core/              # Core library
│   │   ├── types.ts       # Type definitions
│   │   ├── config-manager.ts  # Config read/write
│   │   ├── client-adapter.ts  # Client adapters
│   │   └── index.ts
│   ├── daemon/            # Runtime management
│   │   ├── instance-manager.ts  # Process management
│   │   └── index.ts       # Daemon API server
│   └── cli/               # CLI commands
│       ├── commands/      # Command implementations
│       ├── daemon-client.ts  # API client
│       └── index.ts       # CLI entry point
├── dist/                  # Compiled JS (after build)
├── package.json
├── tsconfig.json
├── README.md
└── QUICKSTART.md
```

## Development Workflow

### Watch mode
```bash
npm run watch
```

### Run in dev mode
```bash
npm run dev -- init
npm run dev -- list
npm run dev -- bind github --client claude-desktop
```

### Build
```bash
npm run build
```

### Clean
```bash
npm run clean
```

## What's Next?

### Short-term improvements:
1. **Add command** - Implement `mcp-launcher add` to create server definitions via CLI
2. **Better error messages** - Add more helpful error messages and validation
3. **Auto-discovery** - Scan for installed MCP servers (npm/pip packages)
4. **Logs** - Add logging for daemon and instances
5. **Health checks** - Ping running instances to verify they're responding

### Medium-term features:
1. **Profiles** - Save/load different binding configurations
2. **Templates** - Pre-configured server templates for common servers
3. **Import/Export** - Share configs between machines
4. **Better SSE support** - Auto-detect SSE server URLs from stdout

### Long-term vision:
1. **Desktop GUI** - Visual interface using Tauri or Electron
2. **MCP Apps integration** - Deep integration with MCP Apps UI
3. **Registry** - Connect to an MCP server registry
4. **Monitoring** - Advanced metrics and observability

## Troubleshooting

### "Daemon is not running"
```bash
# Start the daemon first
mcp-launcher daemon start -d

# Check status
mcp-launcher daemon status
```

### "Server not found"
```bash
# List all servers
mcp-launcher list servers

# Make sure server is added to config.json
```

### "Client not found"
```bash
# List registered clients
mcp-launcher list clients

# Re-run init with correct path
mcp-launcher init --claude-config-path "/correct/path"
```

### Build errors
```bash
# Clean and rebuild
npm run clean
npm run build
```

## Contributing

The codebase is well-structured and ready for contributions:

1. **Core logic** is in `src/core/`
2. **Runtime management** is in `src/daemon/`
3. **CLI commands** are in `src/cli/commands/`

Each command is self-contained and follows the same pattern. Adding new commands is straightforward!

## Feedback

This is v0.1! Your feedback is valuable:
- What commands are confusing?
- What features are missing?
- What errors need better messages?
- What would make this more useful for your workflow?

Happy launching! 🚀
