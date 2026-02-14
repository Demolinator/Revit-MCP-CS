# Revit MCP - Natural Language Building Design with Claude Code

Design buildings using natural language through **Claude Code** connected to **Autodesk Revit 2026** via the Model Context Protocol (MCP).

> Built by **Talal Ahmed** under the mentorship of **Sir Zia Khan**
> Targeting Pakistan's largest industry: Construction & Design

---

## What This Does

This project connects Claude Code (Anthropic's AI CLI) directly to Autodesk Revit, allowing you to:

- **Create building elements** (walls, floors, roofs, beams, grids) using natural language
- **Query model data** (view info, element properties, room data, material quantities)
- **Analyze models** (element counts, statistics, structural systems)
- **Design buildings** by describing what you want in plain English

## Architecture

```
Claude Code (AI) ──stdio──> MCP Server (TypeScript/Node.js) ──TCP:8080──> Revit Plugin (C#) ──> Revit API
     (WSL2)                    (WSL2)                                      (Windows)              (Windows)
```

**Three-layer architecture:**

| Layer | Technology | Role |
|-------|-----------|------|
| **MCP Server** | TypeScript + Node.js | Translates Claude's tool calls into JSON-RPC messages |
| **Revit Plugin** | C# (.NET 8.0) | Receives TCP commands, manages ExternalEvents for UI thread |
| **Command Set** | C# (.NET 8.0) | Actual Revit API operations (create walls, query elements, etc.) |

## Prerequisites

- **Windows 10/11** with WSL2 enabled
- **Autodesk Revit 2026** (free trial: https://www.autodesk.com/products/revit/free-trial)
- **Node.js 18+** (in WSL2)
- **.NET 8.0 SDK** (on Windows): https://dotnet.microsoft.com/download/dotnet/8.0
- **Claude Code** CLI installed: `npm install -g @anthropic-ai/claude-code`

## Installation

### Step 1: Clone the Repositories

```bash
cd /mnt/d/Talal/Work/CLAUDE/Revit-MCP  # or your preferred directory
git clone https://github.com/mcp-servers-for-revit/revit-mcp.git
git clone https://github.com/mcp-servers-for-revit/revit-mcp-plugin.git
git clone https://github.com/mcp-servers-for-revit/revit-mcp-commandset.git
```

### Step 2: Build the MCP Server

```bash
cd revit-mcp
npm install
npm run build
```

### Step 3: Build the Revit Plugin (on Windows)

> **Important:** Close Revit before building.

Create a file `build-plugin.bat`:
```batch
@echo off
cd /d "D:\Talal\Work\CLAUDE\Revit-MCP\revit-mcp-plugin"
dotnet restore revit-mcp-plugin.sln
dotnet build revit-mcp-plugin.sln -c "Debug R26"
```

Run it: `cmd.exe /c "D:\Talal\Work\CLAUDE\Revit-MCP\build-plugin.bat"`

### Step 4: Build the Command Set

Create a file `build-commandset.bat`:
```batch
@echo off
cd /d "D:\Talal\Work\CLAUDE\Revit-MCP\revit-mcp-commandset"
dotnet restore revit-mcp-commandset.sln
dotnet build revit-mcp-commandset.sln -c "Debug R26"
```

Run it: `cmd.exe /c "D:\Talal\Work\CLAUDE\Revit-MCP\build-commandset.bat"`

Both builds will auto-install to:
`C:\Users\<USERNAME>\AppData\Roaming\Autodesk\Revit\Addins\2026\`

### Step 5: Register Commands

The command registry file starts empty. You must populate it.

Edit this file:
`C:\Users\<USERNAME>\AppData\Roaming\Autodesk\Revit\Addins\2026\revit_mcp_plugin\Commands\commandRegistry.json`

Replace its contents with:
```json
{
  "commands": [
    {
      "commandName": "get_current_view_info",
      "assemblyPath": "RevitMCPCommandSet\\2026\\RevitMCPCommandSet.dll",
      "enabled": true
    },
    {
      "commandName": "get_current_view_elements",
      "assemblyPath": "RevitMCPCommandSet\\2026\\RevitMCPCommandSet.dll",
      "enabled": true
    },
    {
      "commandName": "get_available_family_types",
      "assemblyPath": "RevitMCPCommandSet\\2026\\RevitMCPCommandSet.dll",
      "enabled": true
    },
    {
      "commandName": "create_line_based_element",
      "assemblyPath": "RevitMCPCommandSet\\2026\\RevitMCPCommandSet.dll",
      "enabled": true
    },
    {
      "commandName": "create_surface_based_element",
      "assemblyPath": "RevitMCPCommandSet\\2026\\RevitMCPCommandSet.dll",
      "enabled": true
    },
    {
      "commandName": "create_point_based_element",
      "assemblyPath": "RevitMCPCommandSet\\2026\\RevitMCPCommandSet.dll",
      "enabled": true
    },
    {
      "commandName": "create_grid",
      "assemblyPath": "RevitMCPCommandSet\\2026\\RevitMCPCommandSet.dll",
      "enabled": true
    },
    {
      "commandName": "create_structural_framing_system",
      "assemblyPath": "RevitMCPCommandSet\\2026\\RevitMCPCommandSet.dll",
      "enabled": true
    },
    {
      "commandName": "delete_element",
      "assemblyPath": "RevitMCPCommandSet\\2026\\RevitMCPCommandSet.dll",
      "enabled": true
    },
    {
      "commandName": "tag_all_walls",
      "assemblyPath": "RevitMCPCommandSet\\2026\\RevitMCPCommandSet.dll",
      "enabled": true
    },
    {
      "commandName": "ai_element_filter",
      "assemblyPath": "RevitMCPCommandSet\\2026\\RevitMCPCommandSet.dll",
      "enabled": true
    },
    {
      "commandName": "export_room_data",
      "assemblyPath": "RevitMCPCommandSet\\2026\\RevitMCPCommandSet.dll",
      "enabled": true
    },
    {
      "commandName": "get_material_quantities",
      "assemblyPath": "RevitMCPCommandSet\\2026\\RevitMCPCommandSet.dll",
      "enabled": true
    },
    {
      "commandName": "analyze_model_statistics",
      "assemblyPath": "RevitMCPCommandSet\\2026\\RevitMCPCommandSet.dll",
      "enabled": true
    },
    {
      "commandName": "get_selected_elements",
      "assemblyPath": "RevitMCPCommandSet\\2026\\RevitMCPCommandSet.dll",
      "enabled": true
    },
    {
      "commandName": "send_code_to_revit",
      "assemblyPath": "RevitMCPCommandSet\\2026\\RevitMCPCommandSet.dll",
      "enabled": true
    },
    {
      "commandName": "color_splash",
      "assemblyPath": "RevitMCPCommandSet\\2026\\RevitMCPCommandSet.dll",
      "enabled": true
    },
    {
      "commandName": "create_dimensions",
      "assemblyPath": "RevitMCPCommandSet\\2026\\RevitMCPCommandSet.dll",
      "enabled": true
    },
    {
      "commandName": "operate_element",
      "assemblyPath": "RevitMCPCommandSet\\2026\\RevitMCPCommandSet.dll",
      "enabled": true
    }
  ]
}
```

### Step 6: Configure Claude Code MCP

Find your WSL2 gateway IP:
```bash
ip route show default | awk '{print $3}'
# Example output: 172.24.16.1
```

Add the MCP server to Claude Code:
```bash
claude mcp add-json revit-mcp '{
  "type": "stdio",
  "command": "node",
  "args": ["/mnt/d/Talal/Work/CLAUDE/Revit-MCP/revit-mcp/build/index.js"],
  "env": {
    "REVIT_HOST": "172.24.16.1",
    "REVIT_PORT": "8080"
  }
}'
```

> **Note:** Replace the IP with your actual gateway IP. Replace the path with your actual project path.

## Usage

### Starting the Connection

1. **Open Revit 2026** and create/open a project (a project MUST be open)
2. Go to **Add-Ins** tab in the ribbon
3. Click **"Revit MCP Switch"** once (you'll see "Open Server" dialog)
4. **Open Claude Code** in your project directory

### Example Commands

Once connected, just talk to Claude naturally:

```
> Get the current view info from Revit

> Create a 10-meter wall from point (0,0,0) to (10,0,0)

> Show me all the element types available in this project

> Create a grid system with 5 columns spaced 6 meters apart

> What are the material quantities in this model?

> Analyze the model statistics

> Export all room data with areas and volumes
```

### Available Tools

| Tool | Description |
|------|-------------|
| `get_current_view_info` | Get info about the active view |
| `get_current_view_elements` | List elements in the current view |
| `get_available_family_types` | List available family types |
| `get_selected_elements` | Get currently selected elements |
| `create_line_based_element` | Create walls, ducts, and other line-based elements |
| `create_surface_based_element` | Create floors, roofs, and other surface elements |
| `create_point_based_element` | Place family instances at points |
| `create_grid` | Create grid systems with smart spacing |
| `create_structural_framing_system` | Create beam framing systems |
| `create_dimensions` | Create dimension annotations |
| `delete_element` | Delete elements by ID |
| `tag_all_walls` | Tag all walls in the model |
| `ai_element_filter` | Smart element filtering and querying |
| `export_room_data` | Extract room data (area, volume, parameters) |
| `get_material_quantities` | Calculate material takeoffs |
| `analyze_model_statistics` | Analyze model complexity |
| `color_splash` | Color elements by category/parameter |
| `operate_element` | Modify element properties |
| `send_code_to_revit` | Execute arbitrary C# code in Revit (advanced) |

## Troubleshooting

### "connect to revit client failed"
- Make sure Revit is open with a project loaded
- Make sure "Revit MCP Switch" is toggled ON (shows "Open Server" dialog)
- Check port 8080 is listening: `cmd.exe /c "netstat -aon" | grep 8080`
- Verify WSL2 gateway IP is correct: `ip route show default | awk '{print $3}'`

### "Method not found" errors
- The `commandRegistry.json` may be empty - re-populate it (see Step 5)
- Toggle MCP Switch OFF then ON to reload commands

### Commands timeout ("获取信息超时")
- A project must be open in Revit (not just the start screen)
- Make sure Revit isn't showing a modal dialog
- Try toggling the MCP Switch OFF then ON

### Plugin DLL locked during build
- Close Revit before building
- The DLL at `Addins\2026\revit_mcp_plugin\revit-mcp-plugin.dll` gets locked by Revit

### "Revit MCP Switch" not visible
- Look under the **Add-Ins** tab (may need to open a project first to see all ribbon tabs)
- Verify the `.addin` file exists at: `C:\Users\<USERNAME>\AppData\Roaming\Autodesk\Revit\Addins\2026\revit-mcp.addin`

## Revit 2026 Compatibility Notes

This project required the following fixes for Revit 2026:

1. **`ElementId.IntegerValue` removed** - Replaced with `.Value` (returns `long` instead of `int`)
2. **`long` to `int` casting** - Added explicit `(int)` casts where the data model uses `int` for element IDs
3. **Target framework** - Uses `net8.0-windows10.0.19041.0` for Revit 2026
4. **NuGet packages** - `Nice3point.Revit.Api.RevitAPI` 2026.4.0, `RevitMCPSDK` 2026.0.0.5

## Project Structure

```
Revit-MCP/
├── revit-mcp/                  # MCP Server (TypeScript)
│   ├── src/
│   │   ├── index.ts            # Entry point, tool registration
│   │   └── utils/
│   │       ├── ConnectionManager.ts  # Configurable host/port
│   │       └── SocketClient.ts       # TCP client to Revit
│   └── build/                  # Compiled JS
├── revit-mcp-plugin/           # Revit Plugin (C#)
│   └── revit-mcp-plugin/
│       ├── Core/
│       │   ├── Application.cs         # Plugin entry, ribbon buttons
│       │   ├── MCPServiceConnection.cs # Toggle switch logic
│       │   ├── SocketService.cs       # TCP server on port 8080
│       │   ├── CommandManager.cs      # Loads command DLLs
│       │   └── ExternalEventManager.cs # UI thread marshaling
│       └── Configuration/
├── revit-mcp-commandset/       # Command Set (C#)
│   └── revit-mcp-commandset/
│       ├── Commands/
│       │   ├── Access/         # Read-only queries
│       │   ├── DataExtraction/ # Room data, materials, statistics
│       │   └── ...             # Creation, annotation, etc.
│       └── Services/           # ExternalEvent handlers
├── build-plugin.bat            # Build script for plugin
├── build-commandset.bat        # Build script for command set
├── PROJECT_ROADMAP.md          # Development roadmap
└── README.md                   # This file
```

## Credits

- **MCP Server & Plugin**: [mcp-servers-for-revit](https://github.com/mcp-servers-for-revit) (community-driven)
- **Revit 2026 Compatibility**: Talal Ahmed
- **Mentorship**: Sir Zia Khan

## Contact

- **Talal Ahmed** - Developer
- **Sir Zia Khan** - Mentor

---

*Designing buildings using natural language - the future of construction in Pakistan.*
