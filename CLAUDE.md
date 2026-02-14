# Revit MCP - Project Instructions

## Project Overview

Natural-language building design system connecting **Claude Code/Cowork** to **Autodesk Revit 2026** via the **Model Context Protocol (MCP)**. Architects describe what they want in plain English, and AI creates BIM elements in Revit automatically.

**Author:** Talal Ahmed | **Mentor:** Sir Zia Khan
**Focus:** Cowork with Plugins for architects — no coding knowledge required.

## Architecture

```
Claude Code/Cowork (AI) → MCP Protocol → MCP Server (Node.js Plugin) → TCP :8080 → Revit Plugin (C# Add-In) → Revit API
```

All components run on **Windows**. The MCP server acts as a plugin that bridges AI to Revit.

### Key Components

| Component | Path | Language | Purpose |
|-----------|------|----------|---------|
| MCP Server | `revit-mcp/` | TypeScript/Node.js | Translates MCP tool calls to TCP commands for Revit |
| Revit Plugin | `revit-mcp-plugin/` | C# (.NET 8.0) | Receives TCP commands, executes via Revit API |
| Command Set | `revit-mcp-commandset/` | C# (.NET 8.0) | 19 individual Revit command implementations |
| Command Registry | `commandRegistry.json` | JSON | Maps command names to DLL assemblies |
| Presentation | `presentation/` | HTML → PPTX | Project presentation (15 slides, dark theme) |

## Critical Constraints

- **Revit API is single-threaded** — All commands must be marshaled to the UI thread via `ExternalEvent`
- **Revit runs on Windows only** — All components are Windows-native
- **A Revit project must be open** — Commands require `ActiveUIDocument`
- **Revit 2026 breaking change:** `ElementId.IntegerValue` is now `.Value` (returns `long` not `int`)
- **Plugin DLL is locked while Revit is running** — Close Revit before rebuilding
- **MCP Switch is a toggle** — Click once to enable, once to disable (don't double-click)

## Available MCP Tools (19 Commands)

### CREATE (6)
- `create_line_based_element` — Walls, beams, and other line-based elements
- `create_surface_based_element` — Floors, roofs, and surface elements
- `create_point_based_element` — Columns, fixtures, point-based families
- `create_grid` — Column grids and levels
- `create_structural_framing_system` — Structural beam systems
- `create_dimensions` — Automatic dimensioning

### QUERY (11)
- `get_current_view_info` — Active viewport data
- `get_current_view_elements` — Elements in current view
- `get_available_family_types` — Available component types
- `get_selected_elements` — Currently selected elements
- `ai_element_filter` — AI-powered element filtering
- `export_room_data` — Room areas and volumes
- `get_material_quantities` — Material takeoff data
- `analyze_model_statistics` — Element counts and model stats

### MODIFY (3)
- `operate_element` — Change element properties
- `delete_element` — Remove elements
- `tag_all_walls` — Auto-tag walls
- `color_splash` — Color elements by category

### ADVANCED (1)
- `send_code_to_revit` — Execute arbitrary C# code in Revit context (escape hatch)

## Building Design Sequence

When designing a building, follow this order:
1. **Levels** — Define floor heights first
2. **Grids** — Establish column grid layout
3. **Structural system** — Columns and beams at grid intersections
4. **Exterior walls** — Building envelope
5. **Interior walls** — Room partitions
6. **Openings** — Doors and windows on walls
7. **Floors/Slabs** — Floor plates at each level
8. **Roof** — Top enclosure
9. **Rooms** — Define room boundaries
10. **Documentation** — Dimensions, tags, schedules

## Unit Handling

- Revit internal units are in **feet**
- User-facing units should be in **millimeters** or **meters**
- Conversion: 1 foot = 304.8 mm
- Always convert mm → feet before sending to Revit API

## Presentation

The presentation is at `presentation/Revit-MCP-Presentation.pptx` (15 slides).

### Build Process
```bash
cd presentation
node build-presentation.js
```

### Slide HTML files are in `presentation/slides/`
- Each slide is a self-contained HTML file (720pt x 405pt)
- Theme: Dark navy (#0a0e27) background, cyan (#00d4ff) accent, white text
- Converted to PPTX via the `html2pptx` library

### Key Presentation Rules
- Always use `box-sizing: border-box` on body elements
- Never use `flex-wrap` — use explicit row divs instead
- Font: Arial only (web-safe)
- Always refer to "Claude Code/Cowork" (not just "Claude Code")
- Do not mention WSL2 — architecture is Windows-native

## Development Setup

### Prerequisites
- Windows 10/11
- Autodesk Revit 2026
- Node.js 18+
- .NET 8.0 SDK (for C# builds)
- Claude Code/Cowork

### Quick Start
```bash
git clone https://github.com/Demolinator/Revit-MCP-CS.git
cd Revit-MCP-CS
npm install && npm run setup
```

Then: Open Revit 2026 → Add-Ins → MCP Switch → Open Claude Code/Cowork → Start designing!

## Future Direction

- **Cowork Plugin for Architects** — Build a dedicated Cowork plugin so architects can design buildings without any terminal or coding knowledge
- **Digital Twins** — Export BIM models as real-time digital twins with IoT sensor integration
- **Pakistan Building Code** — Encode PBC 2021 compliance rules for automatic validation
- **Team Expansion** — Collaborate with architects and Revit experts

## GitHub

Repository: https://github.com/Demolinator/Revit-MCP-CS
