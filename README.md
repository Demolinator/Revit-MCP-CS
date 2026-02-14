# Revit MCP - Design Buildings Using Natural Language

Connect **Claude Code/Cowork** (AI) to **Autodesk Revit 2026** via the Model Context Protocol (MCP). Tell the AI what you want in plain English, and it creates walls, floors, grids, beams, and more directly in Revit.

> Built by **Talal Ahmed** | Mentored by **Sir Zia Khan**

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

## MCP Configuration

Add the Revit MCP server to your Claude Code/Cowork MCP settings:

```json
{
  "mcpServers": {
    "revit-mcp": {
      "command": "node",
      "args": ["path/to/revit-mcp/build/index.js"],
      "env": {
        "REVIT_HOST": "localhost",
        "REVIT_PORT": "8080"
      }
    }
  }
}
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
- Sir Zia Khan - Mentorship and vision

---

*Designing buildings using natural language — the future of construction in Pakistan.*
