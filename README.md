# Revit MCP - Design Buildings Using Natural Language

Connect **Claude Code/Cowork** (AI) to **Autodesk Revit 2026** via the Model Context Protocol (MCP). Tell the AI what you want in plain English, and it creates walls, floors, grids, beams, and more directly in Revit.

> Built by **Talal Ahmed**

---

## Quick Start

```bash
git clone https://github.com/Demolinator/Revit-MCP-CS.git
cd Revit-MCP-CS
npm install && npm run setup
```

Then: Open Revit 2026 > Add-Ins > Click **"Revit MCP Switch"** > Open Claude Code/Cowork > Start designing!

---

## Prerequisites

| Tool | Install |
|------|---------|
| **Windows 10/11** | Host OS |
| **Autodesk Revit 2026** | [Free Trial](https://www.autodesk.com/products/revit/free-trial) |
| **Node.js 18+** | [Download](https://nodejs.org/) |
| **.NET 8.0 SDK** | [Download](https://dotnet.microsoft.com/download/dotnet/8.0) |
| **Claude Code/Cowork** | Anthropic's AI interface |

## How It Works

```
Architect (English) → Claude Code/Cowork (AI) → MCP Server (Plugin) → Revit Plugin (C#) → Revit API
```

The MCP Server translates Claude's tool calls into TCP commands sent to a C# plugin running inside Revit. The plugin uses Revit's `ExternalEvent` pattern to execute commands on the UI thread.

**All components run on Windows** — designed for architects, no coding needed.

## What You Can Do

**Create elements** - walls, floors, grids, structural beams, dimensions, family instances
**Query the model** - view info, element properties, selected elements, family types
**Extract data** - room areas/volumes, material quantities, model statistics
**Modify elements** - change properties, color by category, tag walls
**Advanced** - execute arbitrary C# code inside Revit context

### 19 Available Commands

| Category | Commands |
|----------|----------|
| **Create** | `create_line_based_element`, `create_surface_based_element`, `create_point_based_element`, `create_grid`, `create_structural_framing_system`, `create_dimensions` |
| **Query** | `get_current_view_info`, `get_current_view_elements`, `get_available_family_types`, `get_selected_elements`, `ai_element_filter` |
| **Data** | `export_room_data`, `get_material_quantities`, `analyze_model_statistics` |
| **Modify** | `operate_element`, `delete_element`, `tag_all_walls`, `color_splash` |
| **Advanced** | `send_code_to_revit` |

## Usage

1. Open **Revit 2026** with a project (a project MUST be open)
2. Go to **Add-Ins** tab > Click **"Revit MCP Switch"** (shows "Open Server")
3. Open **Claude Code/Cowork**
4. Start talking:

```
> Get the current view info from Revit
> Create a grid system with 5 columns at 6m spacing and 4 rows at 5m spacing
> Create curtain walls around the perimeter
> Add a concrete floor slab
> What are the model statistics?
```

## Setup Guide

### Step 1: Clone and Build

```bash
git clone https://github.com/Demolinator/Revit-MCP-CS.git
cd Revit-MCP-CS
```

**Build the MCP Server (Node.js):**
```bash
cd revit-mcp
npm install
npm run build
cd ..
```

**Build the Revit Plugin and Command Set (Windows — PowerShell or CMD):**

> Close Revit before building. DLLs are locked while Revit is running.

```powershell
cd revit-mcp-plugin
dotnet restore revit-mcp-plugin.sln
dotnet build revit-mcp-plugin.sln -c "Debug R26"

cd ..\revit-mcp-commandset
dotnet restore revit-mcp-commandset.sln
dotnet build revit-mcp-commandset.sln -c "Debug R26"
```

The Debug build automatically deploys DLLs to `%APPDATA%\Autodesk\Revit\Addins\2026\`.

**Install Command Registry:**

Copy `commandRegistry.json` to:
```
%APPDATA%\Autodesk\Revit\Addins\2026\revit_mcp_plugin\Commands\commandRegistry.json
```

### Step 2: Connect Your AI Interface

Choose whichever AI interface you prefer — they all connect to the same MCP server and Revit plugin.

---

#### Option A: Claude Desktop (Recommended for Architects)

Claude Desktop is the easiest option — a visual chat interface that runs natively on Windows.

1. **Install Claude Desktop** from [claude.ai/download](https://claude.ai/download)
2. Open Claude Desktop **Settings** → **Developer** → **Edit Config**
3. This opens `claude_desktop_config.json`. Add the Revit MCP server:

```json
{
  "mcpServers": {
    "revit-mcp": {
      "command": "node",
      "args": ["C:\\path\\to\\Revit-MCP-CS\\revit-mcp\\build\\index.js"],
      "env": {
        "REVIT_HOST": "localhost",
        "REVIT_PORT": "8080"
      }
    }
  }
}
```

> **Important:** Replace `C:\\path\\to\\` with the actual path where you cloned the repo. Use double backslashes `\\` in the path.

4. **Restart Claude Desktop** to load the MCP server
5. You should see the Revit MCP tools (hammer icon) in the chat input area

**Config file location:** `%APPDATA%\Claude\claude_desktop_config.json`

---

#### Option B: Cowork (Collaborative AI for Teams)

Cowork is Anthropic's collaborative AI workspace with native MCP plugin support — ideal for architect teams.

1. **Open Cowork** at [cowork.ai](https://cowork.ai) or the desktop app
2. Go to **Settings** → **MCP Plugins**
3. Add a new plugin with the Revit MCP server configuration:

```json
{
  "revit-mcp": {
    "command": "node",
    "args": ["C:\\path\\to\\Revit-MCP-CS\\revit-mcp\\build\\index.js"],
    "env": {
      "REVIT_HOST": "localhost",
      "REVIT_PORT": "8080"
    }
  }
}
```

4. The Revit tools will appear automatically in your Cowork workspace
5. All team members can share the same Revit MCP connection

---

#### Option C: Claude Code (CLI — for Developers)

Claude Code is the terminal-based interface for developers.

```bash
# Register the MCP server with Claude Code
claude mcp add-json revit-mcp '{
  "type": "stdio",
  "command": "node",
  "args": ["C:/path/to/Revit-MCP-CS/revit-mcp/build/index.js"],
  "env": {
    "REVIT_HOST": "localhost",
    "REVIT_PORT": "8080"
  }
}'
```

> If running Claude Code from WSL2, replace `localhost` with your WSL2 gateway IP:
> ```bash
> GATEWAY_IP=$(ip route show default | awk '{print $3}')
> ```

---

### Step 3: Start Designing

1. **Open Revit 2026** and create or open a project
2. Go to **Add-Ins** tab → Click **"Revit MCP Switch"** (click once to turn ON)
3. Open your AI interface (Claude Desktop, Cowork, or Claude Code)
4. Start talking in natural language!

### Step 4: Allow Firewall (if needed)

If the MCP server can't connect to Revit, allow port 8080 through Windows Firewall:

```powershell
# Run as Administrator in PowerShell:
New-NetFirewallRule -DisplayName "Revit MCP" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "connect to revit client failed" | Check Revit is open with a project, MCP Switch is ON, and firewall allows port 8080 |
| "Method not found" | commandRegistry.json may be empty or missing. Copy ours and toggle MCP Switch OFF/ON |
| Commands timeout | A project must be open (not just start screen). Toggle MCP Switch OFF/ON |
| No "MCP Switch" button | Check `.addin` file exists at `%APPDATA%\Autodesk\Revit\Addins\2026\revit-mcp.addin` |

## Project Structure

```
Revit-MCP/
├── CLAUDE.md                   # Project instructions for AI
├── AGENTS.md                   # AI agent architecture docs
├── commandRegistry.json        # Pre-configured 19 commands
├── revit-mcp/                  # MCP Server (TypeScript/Node.js)
├── revit-mcp-plugin/           # Revit Plugin (C# .NET 8.0)
├── revit-mcp-commandset/       # Command Set (C# .NET 8.0)
└── presentation/               # Presentation slides (15 slides)
```

## Future Vision

- **Cowork Plugin for Architects** — A dedicated plugin so architects can design buildings through conversation, no coding needed
- **Digital Twins** — Export BIM models as real-time digital twins with IoT sensor integration
- **Pakistan Building Code** — Automatic PBC 2021 compliance checking
- **AI-Assisted Design** — Complete buildings from a single natural language description

## Credits

- [mcp-servers-for-revit](https://github.com/mcp-servers-for-revit) - MCP Server, Plugin, and CommandSet
- Talal Ahmed - Revit 2026 compatibility fixes, setup automation, Cowork integration

---

*Designing buildings using natural language — the future of construction in Pakistan.*
