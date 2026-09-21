# MCP Launcher

> The MCP control center for your local machine

A local CLI and daemon that discovers, configures, isolates, and monitors MCP servers across multiple clients (Claude, Cursor, Gemini, etc.), with explicit sharing controls and strong token-safety guarantees.

## Overview

MCP Launcher is a system-level orchestrator for all MCP servers on your machine. Think of it as "Docker Desktop for MCP servers" - it provides:

- **Unified visibility**: See all MCP servers and which clients use them
- **Centralized management**: Bind/unbind servers to clients from one place
- **Runtime control**: Start/stop server instances with isolation or sharing
- **Config synchronization**: Automatically generate client configs based on bindings
- **Token safety**: Track credential usage across clients

## Installation

```bash
npm install -g mcp-launcher
```

## Quick Start

```bash
# 1. Initialize MCP Launcher
mcp-launcher init

# 2. List all servers and clients
mcp-launcher list

# 3. Bind a server to a client
mcp-launcher bind github --client claude-desktop

# 4. Generate client config
mcp-launcher generate-config --client claude-desktop

# 5. Start the daemon
mcp-launcher daemon start -d

# 6. Start a server instance
mcp-launcher start github --client claude-desktop
```

## Commands

### `init`
Initialize MCP Launcher and register MCP clients.

```bash
mcp-launcher init \
  --claude-config-path "/path/to/claude/mcp.json" \
  --cursor-config-path "/path/to/cursor/mcp.json"
```

### `list`
List servers, clients, and bindings.

```bash
# List all servers with their clients
mcp-launcher list

# List all servers
mcp-launcher list servers

# List all clients
mcp-launcher list clients

# List all bindings
mcp-launcher list bindings

# Filter by client
mcp-launcher list servers --client claude-desktop

# Filter by server
mcp-launcher list clients --server github
```

### `bind`
Bind a server to one or more clients.

```bash
mcp-launcher bind <serverId> --client <clientId...>

# Examples
mcp-launcher bind github --client claude-desktop
mcp-launcher bind expedia --client claude-desktop cursor
```

### `unbind`
Unbind a server from one or more clients.

```bash
mcp-launcher unbind <serverId> --client <clientId...>

# Example
mcp-launcher unbind github --client claude-desktop
```

### `delete`
Delete a server (partial or full).

```bash
# Delete from one client only
mcp-launcher delete <serverId> --client <clientId>

# Delete from all clients (global)
mcp-launcher delete <serverId>

# Skip confirmation
mcp-launcher delete <serverId> --force
```

### `generate-config`
Generate MCP config file for a client.

```bash
mcp-launcher generate-config --client <clientId>

# Example
mcp-launcher generate-config --client claude-desktop
```

### `daemon`
Manage the daemon process.

```bash
# Start daemon in background
mcp-launcher daemon start -d

# Start daemon in foreground
mcp-launcher daemon start

# Check daemon status
mcp-launcher daemon status

# Stop daemon
mcp-launcher daemon stop
```

### `start`
Start MCP server instances.

```bash
mcp-launcher start <serverId> --client <clientId...>

# Start isolated instances (default)
mcp-launcher start github --client claude-desktop

# Start shared SSE instance
mcp-launcher start browser --shared --client claude-desktop cursor
```

### `stop`
Stop MCP server instances.

```bash
# Stop specific client instance
mcp-launcher stop <serverId> --client <clientId>

# Stop all instances
mcp-launcher stop <serverId>
```

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     MCP Launcher                         │
│                                                           │
│  ┌──────────────┐         ┌─────────────────┐          │
│  │     CLI      │◄────────┤ Config Manager  │          │
│  └──────┬───────┘         └─────────────────┘          │
│         │                                                │
│         │                                                │
│  ┌──────▼──────────────────────────────────────┐       │
│  │            Daemon (API)                      │       │
│  │  ┌──────────────────────────────────────┐   │       │
│  │  │     Instance Manager                 │   │       │
│  │  │  • Start/Stop servers                │   │       │
│  │  │  • Track instances                   │   │       │
│  │  │  • Isolation/Sharing                 │   │       │
│  │  └──────────────────────────────────────┘   │       │
│  └──────────────────┬───────────────────────────┘       │
│                     │                                    │
└─────────────────────┼────────────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        │             │             │
   ┌────▼────┐   ┌────▼────┐   ┌───▼──────┐
   │ Claude  │   │ Cursor  │   │  Gemini  │
   │ Desktop │   │   IDE   │   │  VS Code │
   └────┬────┘   └────┬────┘   └────┬─────┘
        │             │              │
        └─────────────┼──────────────┘
                      │
              ┌───────▼────────┐
              │  MCP Servers   │
              │  • GitHub      │
              │  • Browser     │
              │  • Expedia     │
              └────────────────┘
```

## Core Concepts

### Server Definition
A logical MCP server with:
- Transport type (stdio or sse)
- Command/args or URL
- Credentials (by reference, not raw values)

### Client
A consumer of MCP servers:
- claude-desktop, cursor, gemini-vscode, windsurf, etc.
- Each has a known config file location

### Binding
A relationship: "Server X is enabled for Client Y"
- Controls which servers a client can see
- Removing a binding updates the client's config

### Instance
A running MCP server process:
- **Isolated** (default): One per client, no cross-client token usage
- **Shared** (opt-in): One instance attached to multiple clients

### Token Safety
- No client is ever implicitly attached to a server
- All credential usage is visible
- Launcher warns when multiple clients share credentials

## Configuration

Launcher config is stored at `~/.mcp-launcher/config.json`:

```json
{
  "version": 1,
  "servers": {
    "github": {
      "id": "github",
      "name": "GitHub MCP",
      "transport": "stdio",
      "command": "npx",
      "args": ["mcp-github"],
      "credentials": {
        "env": { "GITHUB_TOKEN": "..." }
      }
    }
  },
  "clients": {
    "claude-desktop": {
      "id": "claude-desktop",
      "displayName": "Claude Desktop",
      "configPath": "/Users/you/Library/Application Support/Claude/claude_desktop_config.json",
      "type": "json"
    }
  },
  "bindings": [
    {
      "serverId": "github",
      "clientId": "claude-desktop",
      "enabled": true
    }
  ],
  "preferences": {
    "defaultIsolationMode": "isolated"
  }
}
```

## Development

```bash
# Install dependencies
npm install

# Build
npm run build

# Development mode
npm run dev -- <command>

# Watch mode
npm run watch
```

## Roadmap

### v0.1 (Current)
- ✅ Core data models
- ✅ Config management
- ✅ Client adapters (Claude, Cursor, Gemini)
- ✅ CLI: init, list, bind, unbind, delete
- ✅ Config generation
- ✅ Daemon for runtime management
- ✅ Start/stop commands

### v0.2 (Next)
- [ ] Auto-discover servers (npm/pip/PATH)
- [ ] Improved logging and error handling
- [ ] Health checks for running instances
- [ ] Import/export configs

### v0.3
- [ ] Profiles/workspaces
- [ ] Bulk bind operations
- [ ] Server templates

### v1.0
- [ ] Desktop GUI (Tauri/Electron)
- [ ] MCP Apps UI integration
- [ ] Registry integration
- [ ] Advanced monitoring

## License

MIT

## Contributing

Contributions welcome! Please open an issue or PR.
