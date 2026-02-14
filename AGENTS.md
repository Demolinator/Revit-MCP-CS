# Agents & AI Integration

## Overview

This project uses AI agents (via Claude Code/Cowork) to enable natural-language building design in Autodesk Revit. The AI acts as an intelligent intermediary between the architect and Revit's BIM engine.

## How the AI Agent Works

### The Communication Flow

```
Architect (Natural Language)
    ↓
Claude Code/Cowork (AI Agent)
    ↓  ← Understands intent, plans actions
MCP Protocol (Model Context Protocol)
    ↓  ← Standardized tool calls
MCP Server (Node.js Plugin)
    ↓  ← Translates to TCP commands
Revit Plugin (C# Add-In)
    ↓  ← Marshals to UI thread via ExternalEvent
Autodesk Revit 2026 (BIM Platform)
    ↓  ← Creates actual BIM elements
Building Model (Result)
```

### What Makes This an "Agent"

The AI doesn't just translate commands — it **reasons about building design**:

1. **Intent Understanding** — "Create a 3-story office building" is broken down into levels, grids, walls, floors, structural systems
2. **Tool Selection** — The AI chooses which of the 19 MCP tools to use for each operation
3. **Sequencing** — It knows to create levels before walls, walls before doors, floors before rooms
4. **Error Recovery** — If a wall creation fails, it adjusts parameters and retries
5. **Validation** — It checks that rooms are enclosed, walls connect, and the model is consistent

### MCP: The Agent's Toolkit

The Model Context Protocol (MCP) provides the AI with a structured toolkit:

- **Tool Discovery** — The AI automatically discovers all 19 available Revit commands
- **Bidirectional Communication** — The AI can both create elements AND query the model
- **Real-Time Feedback** — Every command returns results that inform the next action
- **Type Safety** — Each tool has defined parameters, preventing invalid operations

## Agent Capabilities

### Current (Phase 1-2)

| Capability | Description | Status |
|-----------|-------------|--------|
| Element Creation | Walls, floors, grids, beams, columns | Working |
| Model Querying | View info, element properties, statistics | Working |
| Data Export | Room data, material quantities | Working |
| Element Modification | Properties, colors, tags | Working |
| Code Execution | Arbitrary C# via `send_code_to_revit` | Working |

### Planned (Phase 3+)

| Capability | Description | Status |
|-----------|-------------|--------|
| Design Intelligence | Complete building from a single description | Planned |
| Pakistan Building Code | Automatic PBC 2021 compliance checking | Planned |
| Cowork Plugin | Dedicated architect-friendly interface | Planned |
| Digital Twin Export | BIM to real-time 3D web viewer | Planned |
| IoT Integration | Sensor data overlay on digital twins | Planned |

## Cowork Plugin Vision

The future direction is a **Cowork plugin specifically for architects**:

### What Architects Will Experience
- Open Cowork (Anthropic's collaborative AI interface)
- The Revit MCP plugin is pre-installed
- Describe the building in natural language
- Watch it appear in Revit in real-time
- Query, modify, and validate — all through conversation

### Why Cowork (Not Terminal)
- Architects are visual thinkers, not command-line users
- Cowork provides a friendly chat interface with plugin support
- MCP plugins work natively in Cowork
- No WSL2, no terminal, no coding — just conversation

### Plugin Architecture
```
Cowork (UI) → MCP Plugin (Revit) → Revit Plugin (C#) → Revit API
```

All running on Windows. The architect never leaves the Cowork interface.

## Multi-Agent Patterns (Future)

As the system grows, multiple AI agents could collaborate:

1. **Design Agent** — Understands architecture, creates the building
2. **Compliance Agent** — Checks against building codes (PBC 2021)
3. **Cost Estimation Agent** — Calculates quantities and costs from the model
4. **Documentation Agent** — Generates sheets, schedules, and reports
5. **Digital Twin Agent** — Exports and manages the real-time building replica

## Configuration

### MCP Server Settings
The MCP server connects to Revit on `localhost:8080` by default.

Environment variables:
- `REVIT_HOST` — Revit plugin host (default: `localhost`)
- `REVIT_PORT` — Revit plugin port (default: `8080`)

### Command Registry
All 19 commands are registered in `commandRegistry.json`. Each command maps to a C# class in the CommandSet DLL.

## Contributing

To add a new Revit command:
1. Create a C# class implementing `IRevitCommand` in `revit-mcp-commandset/`
2. Add the tool definition in `revit-mcp/src/tools/`
3. Register the command in `commandRegistry.json`
4. Rebuild both the C# DLL and the MCP server
5. Toggle MCP Switch off/on in Revit to reload commands
