# Revit MCP - Design Buildings Using Natural Language

Connect **Claude Code** (AI) to **Autodesk Revit 2026** via the Model Context Protocol (MCP). Tell the AI what you want in plain English, and it creates walls, floors, grids, beams, and more directly in Revit.

> Built by **Talal Ahmed** | Mentored by **Sir Zia Khan**

---

## Quick Start (One Command)

```bash
# In WSL2 terminal:
git clone https://github.com/YOUR_USERNAME/revit-mcp-setup.git
cd revit-mcp-setup
chmod +x setup.sh
./setup.sh
```

Then: Open Revit 2026 > Add-Ins > Click **"Revit MCP Switch"** > Open Claude Code > Start talking!

---

## Prerequisites

| Tool | Where | Install |
|------|-------|---------|
| **Windows 10/11 + WSL2** | Host OS | `wsl --install` |
| **Autodesk Revit 2026** | Windows | [Free Trial](https://www.autodesk.com/products/revit/free-trial) |
| **.NET 8.0 SDK** | Windows | [Download](https://dotnet.microsoft.com/download/dotnet/8.0) |
| **Node.js 18+** | WSL2 | `curl -fsSL https://deb.nodesource.com/setup_18.x \| sudo bash - && sudo apt install nodejs` |
| **Git** | WSL2 | `sudo apt install git` |
| **Claude Code** | WSL2 | `npm install -g @anthropic-ai/claude-code` |

## How It Works

```
You (English) --> Claude Code (AI) --stdio--> MCP Server (Node.js) --TCP:8080--> Revit Plugin (C#) --> Revit API
                  [WSL2/Linux]                [WSL2/Linux]                        [Windows]            [Windows]
```

The MCP Server translates Claude's tool calls into TCP messages sent across the WSL2-Windows boundary to a C# plugin running inside Revit. The plugin uses Revit's `ExternalEvent` pattern to execute commands on the UI thread.

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

## Manual Setup (If Quick Start Doesn't Work)

<details>
<summary>Click to expand step-by-step instructions</summary>

### 1. Clone the three repositories

```bash
git clone https://github.com/mcp-servers-for-revit/revit-mcp.git
git clone https://github.com/mcp-servers-for-revit/revit-mcp-plugin.git
git clone https://github.com/mcp-servers-for-revit/revit-mcp-commandset.git
```

### 2. Build MCP Server (in WSL2)

```bash
cd revit-mcp && npm install && npm run build && cd ..
```

### 3. Build C# projects (in Windows CMD or PowerShell)

> Close Revit first! DLLs get locked while Revit is running.

```batch
cd revit-mcp-plugin
dotnet restore revit-mcp-plugin.sln
dotnet build revit-mcp-plugin.sln -c "Debug R26"

cd ..\revit-mcp-commandset
dotnet restore revit-mcp-commandset.sln
dotnet build revit-mcp-commandset.sln -c "Debug R26"
```

The Debug build auto-deploys DLLs to `%APPDATA%\Autodesk\Revit\Addins\2026\`.

### 4. Install command registry

Copy `commandRegistry.json` from this repo to:
```
%APPDATA%\Autodesk\Revit\Addins\2026\revit_mcp_plugin\Commands\commandRegistry.json
```

### 5. Allow port 8080 through Windows Firewall

```powershell
# Run as Administrator:
New-NetFirewallRule -DisplayName "Revit MCP (WSL2)" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow
```

### 6. Register MCP with Claude Code

```bash
# Find your WSL2 gateway IP:
GATEWAY_IP=$(ip route show default | awk '{print $3}')

claude mcp add-json revit-mcp "{
  \"type\": \"stdio\",
  \"command\": \"node\",
  \"args\": [\"$(pwd)/revit-mcp/build/index.js\"],
  \"env\": {
    \"REVIT_HOST\": \"$GATEWAY_IP\",
    \"REVIT_PORT\": \"8080\"
  }
}"
```

</details>

## Usage

1. Open **Revit 2026** with a project (a project MUST be open)
2. Go to **Add-Ins** tab > Click **"Revit MCP Switch"** (shows "Open Server")
3. Open **Claude Code**: `claude`
4. Start talking:

```
> Get the current view info from Revit
> Create a grid system with 5 columns at 6m spacing and 4 rows at 5m spacing
> Create curtain walls around the perimeter
> Add a concrete floor slab
> What are the model statistics?
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "connect to revit client failed" | Check Revit is open with a project, MCP Switch is ON, and firewall allows port 8080 |
| "Method not found" | commandRegistry.json may be empty or missing. Copy ours and toggle MCP Switch OFF/ON |
| Commands timeout | A project must be open (not just start screen). Toggle MCP Switch OFF/ON |
| No "MCP Switch" button | Check `.addin` file exists at `%APPDATA%\Autodesk\Revit\Addins\2026\revit-mcp.addin` |
| WSL2 can't reach Windows | Run: `New-NetFirewallRule -DisplayName "Revit MCP" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow` |

## Project Structure

```
Revit-MCP/
├── setup.sh                    # One-click WSL2 setup script
├── setup-windows.bat           # Windows C# build + deployment
├── commandRegistry.json        # Pre-configured 19 commands
├── revit-mcp/                  # MCP Server (TypeScript/Node.js)
├── revit-mcp-plugin/           # Revit Plugin (C# .NET 8.0)
├── revit-mcp-commandset/       # Command Set (C# .NET 8.0)
└── presentation/               # Presentation slides
```

## Presentation

The presentation is at `presentation/Revit-MCP-Presentation.pptx` and covers:
- Problem: Why natural language building design matters
- Solution: How Claude Code + MCP + Revit works together
- BIM: What is Building Information Modeling
- Parametric Modeling: How Revit's smart objects work
- Architecture: How the TCP bridge connects WSL2 to Windows
- MCP: Model Context Protocol explained
- Demo Results: "The Prism" — A 3-story neo-futuristic building
- Setup: One-command installation
- Future Vision: Digital twins and AI-assisted design

**Note:** Before presenting, add your phone number by editing the presentation slides 1 and 10 (replace "[Add Your Phone Here]")

## Credits

- [mcp-servers-for-revit](https://github.com/mcp-servers-for-revit) - MCP Server, Plugin, and CommandSet
- Talal Ahmed - Revit 2026 compatibility fixes, setup automation
- Sir Zia Khan - Mentorship and vision

---

*Designing buildings using natural language - the future of construction in Pakistan.*
