# Revit MCP: Natural Language Building Design & Digital Twins

## Project Vision

Build an AI-powered system where architects and engineers can **design complete buildings using natural language** through Claude Code connected to Autodesk Revit, and **generate digital twins** of those buildings -- targeting Pakistan's construction and design industry.

---

## Phase 0: Foundation & Learning

**Goal:** Understand Revit, the Revit API, MCP protocol, and the existing ecosystem before writing a single line of code.

### 0.1 Install & Learn Revit Basics
- [ ] Download and install Autodesk Revit 2024 or 2025 (free trial: https://www.autodesk.com/products/revit/free-trial)
- [ ] Complete Revit fundamentals: understand Levels, Grids, Walls, Floors, Roofs, Doors, Windows, Families, Views, Sheets
- [ ] Manually create a simple building (a box with 2 levels, walls, a door, windows, a floor slab, a roof)
- [ ] Understand Revit's data model: Elements, Categories, Parameters, Types vs Instances, BuiltInCategory enum
- [ ] Learn what IFC (Industry Foundation Classes) is and why it matters for interoperability

**Resources:**
- Revit official tutorials (built into Revit)
- YouTube: Autodesk Revit beginner series
- RevitLookup add-in (essential for inspecting the Revit object model): https://github.com/jeremytammik/RevitLookup

### 0.2 Understand the Revit API
- [ ] Read the Revit API overview: how add-ins work, IExternalApplication, IExternalCommand
- [ ] Understand the critical threading constraint: Revit API is single-threaded, must use `ExternalEvent` for off-thread calls
- [ ] Understand Transactions: every model modification must be wrapped in a `Transaction`
- [ ] Understand units: Revit internal units are in **feet**, user-facing units are in mm/m -- conversion factor is 304.8
- [ ] Install and explore RevitLookup to inspect live model objects

**Resources:**
- Revit API docs: https://www.revitapidocs.com/
- Jeremy Tammik's blog (the Revit API guru): https://thebuildingcoder.typepad.com/
- Revit API getting started guide in the SDK (comes with Revit install)

### 0.3 Understand MCP (Model Context Protocol)
- [ ] Read the MCP specification: https://modelcontextprotocol.io/
- [ ] Understand the core concepts: Hosts, Clients, Servers, Tools, Resources, Transports (stdio, SSE)
- [ ] Understand how Claude Code uses MCP: it acts as an MCP client that connects to MCP servers
- [ ] Look at a simple MCP server example (e.g., the filesystem MCP server) to understand the pattern
- [ ] Understand JSON-RPC 2.0 (the wire protocol MCP uses)

### 0.4 Study Existing Revit MCP Implementations
- [ ] Clone and read through `shuotao/revit_mcp_study` -- best educational resource, has both sides
- [ ] Clone and read through `mcp-servers-for-revit/revit-mcp` -- most mature, the production target
- [ ] Clone and read through `mcp-servers-for-revit/revit-mcp-plugin` -- understand the C# Revit-side
- [ ] Understand the universal architecture: LLM -> stdio -> MCP Server -> TCP/WebSocket -> Revit Plugin -> Revit API
- [ ] Document what tools each implementation provides and identify gaps

**Deliverable:** A personal knowledge document summarizing what you learned, key concepts, and architectural decisions.

**Acceptance Criteria:** You can explain the full data flow from "user types a sentence" to "wall appears in Revit" without looking at notes.

---

## Phase 1: Pipeline Setup -- Get Claude Code Talking to Revit

**Goal:** Establish a working end-to-end connection where Claude Code can execute commands in Revit.

### 1.1 Set Up the Revit Plugin
- [ ] Clone `mcp-servers-for-revit/revit-mcp-plugin`
- [ ] Build the C# plugin for your Revit version (2024 or 2025)
  - Open the `.sln` in Visual Studio
  - Select the correct build configuration (R24 or R25)
  - Build the solution
- [ ] Install the plugin into Revit's add-ins folder
  - Copy the built DLL + `.addin` manifest to `%AppData%\Autodesk\Revit\Addins\20XX\`
- [ ] Clone `mcp-servers-for-revit/revit-mcp-commandset`
- [ ] Build the command set DLL and install it per the instructions
- [ ] Launch Revit, verify the "Revit MCP Plugin" ribbon panel appears
- [ ] Click "Revit MCP Switch" to start the TCP server on port 8080
- [ ] Verify the server is listening (test with a simple TCP connection)

### 1.2 Set Up the MCP Server
- [ ] Clone `mcp-servers-for-revit/revit-mcp`
- [ ] Install dependencies: `npm install`
- [ ] Build: `npm run build`
- [ ] Test manually: run the server and verify it can connect to the Revit plugin on port 8080

### 1.3 Connect Claude Code to the MCP Server
- [ ] Configure the MCP server in Claude Code's MCP settings
  - Add to `~/.claude/claude_desktop_config.json` or equivalent:
    ```json
    {
      "mcpServers": {
        "revit-mcp": {
          "command": "node",
          "args": ["path/to/revit-mcp/build/index.js"]
        }
      }
    }
    ```
- [ ] Launch Claude Code and verify it discovers the Revit MCP tools
- [ ] Run the first test: ask Claude Code "What tools do you have for Revit?"

### 1.4 First End-to-End Test
- [ ] Open a new Revit project (use the default architectural template)
- [ ] Start the Revit MCP plugin (click the toggle button)
- [ ] In Claude Code, ask: "Get the current view info from Revit"
- [ ] Verify Claude Code receives real data from the live Revit model
- [ ] Ask Claude Code: "Create a wall from (0,0) to (5000,0) that is 3000mm tall"
- [ ] **Verify the wall appears in Revit**

**Deliverable:** A working pipeline where Claude Code can read from and write to a Revit model.

**Acceptance Criteria:** You can create a wall, a floor, and place a door through natural language in Claude Code, and see them in Revit.

---

## Phase 2: Expand the Tool Surface

**Goal:** Ensure Claude Code has all the tools it needs to design a complete building.

### 2.1 Audit Existing Tools
- [ ] List every tool available in the current MCP server
- [ ] Test each tool against a live Revit model
- [ ] Document which tools work, which have bugs, which are placeholders
- [ ] Identify gaps: what operations does an architect need that are missing?

### 2.2 Priority Tool Gaps to Fill
Based on research of existing implementations, these are commonly needed:

**Structural:**
- [ ] Create columns (structural and architectural)
- [ ] Create beams
- [ ] Create foundations
- [ ] Create structural floors/slabs

**Architecture:**
- [ ] Create rooms and room tags
- [ ] Create stairs and railings
- [ ] Create curtain walls
- [ ] Create roofs (flat, gable, hip)
- [ ] Place doors and windows with specific types

**Documentation:**
- [ ] Create sheets
- [ ] Place views on sheets
- [ ] Create dimensions
- [ ] Create text annotations
- [ ] Create schedules

**MEP (Mechanical, Electrical, Plumbing) -- future:**
- [ ] Create ducts
- [ ] Create pipes
- [ ] Create electrical circuits
- [ ] Place fixtures (sinks, toilets, light fixtures)

**Export:**
- [ ] Export to IFC (critical for digital twins)
- [ ] Export to DWG
- [ ] Export to PDF
- [ ] Export 3D views to image

### 2.3 Implement Missing Tools
For each missing tool:
- [ ] Write the TypeScript tool definition in the MCP server (`src/tools/`)
- [ ] Write the C# command implementation in the command set
- [ ] Test end-to-end through Claude Code
- [ ] Document the tool's parameters and behavior

### 2.4 Leverage the `send_code_to_revit` Escape Hatch
- [ ] Test the `send_code_to_revit` tool -- this lets Claude write and execute arbitrary C# in Revit
- [ ] Document its capabilities and limitations
- [ ] Use it as a fallback for operations that don't have dedicated tools yet
- [ ] Create a library of common C# snippets Claude can use

**Deliverable:** A comprehensive tool surface that covers 80%+ of common architectural operations.

**Acceptance Criteria:** Claude Code can create a multi-story building with walls, floors, doors, windows, a roof, rooms, and basic documentation without hitting "tool not available" errors.

---

## Phase 3: Natural Language Design Intelligence

**Goal:** Teach Claude Code how to be an architect -- this is where the REAL value lives.

### 3.1 Design Workflow Prompts (CLAUDE.md)
Create a `CLAUDE.md` file in the project directory that teaches Claude the design workflow:

- [ ] **Building design sequence:** Levels first -> Grids -> Structural system -> Exterior walls -> Interior walls -> Openings (doors/windows) -> Floors/Slabs -> Roof -> Rooms -> MEP rough-in -> Documentation
- [ ] **Design validation rules:** Check that walls connect, floors are bounded, rooms are enclosed, doors are on walls
- [ ] **Error recovery patterns:** What to do when a wall creation fails, when elements overlap, when parameters are invalid
- [ ] **Unit handling:** Always work in millimeters, convert to feet for Revit API
- [ ] **Naming conventions:** Level naming (Ground Floor, First Floor...), grid naming (A,B,C / 1,2,3), room naming standards

### 3.2 Building Type Templates
Create prompt templates for common building types:

- [ ] **Residential house:** 1-3 stories, bedrooms, bathrooms, kitchen, living room, garage
- [ ] **Apartment building:** Multi-story, repeating floor plans, lobby, elevator core, stairs
- [ ] **Office building:** Open floor plans, meeting rooms, reception, core (elevators + stairs + toilets)
- [ ] **Commercial/retail:** Large open spaces, storefronts, back-of-house
- [ ] **Mosque/community building:** Large prayer hall, ablution area, minaret (culturally relevant for Pakistan)

### 3.3 Parametric Design Patterns
Teach Claude to think parametrically:

- [ ] **Grid-based layouts:** "Create a 5x3 grid at 6000mm spacing" -> generates the entire structural grid
- [ ] **Floor plate multiplication:** "Copy this floor plan to levels 2 through 10" -> repeating floors
- [ ] **Facade patterns:** "Create a window grid on the south wall at 1500mm spacing"
- [ ] **Room sizing standards:** Minimum bedroom = 10sqm, bathroom = 4sqm, kitchen = 8sqm, etc.
- [ ] **Structural rules:** Column spacing, beam spans, load-bearing wall placement

### 3.4 Interactive Design Refinement
Build a conversation flow where Claude:

- [ ] Asks clarifying questions ("How many floors? What's the total footprint? What's the primary use?")
- [ ] Proposes a design concept before executing ("I'll create a 3-story building with X, Y, Z. Should I proceed?")
- [ ] Shows progress ("Level 1 walls complete. Moving to Level 2...")
- [ ] Offers alternatives ("Would you prefer an L-shaped or rectangular footprint?")
- [ ] Validates after each step ("All rooms on Level 1 are enclosed. Moving to openings...")

### 3.5 Design Validation & QA
Implement automated checks:

- [ ] Room enclosure validation (all rooms must be bounded)
- [ ] Structural integrity checks (columns at grid intersections, beams spanning between columns)
- [ ] Code compliance basics (minimum room sizes, corridor widths, door sizes)
- [ ] Clash detection (elements overlapping incorrectly)
- [ ] Parameter completeness (all elements have required parameters filled)

**Deliverable:** A system where you can say "Design a 2-story residential house with 3 bedrooms" and Claude produces a complete Revit model.

**Acceptance Criteria:** Claude can design, from a single sentence, a building that an architect would recognize as a reasonable starting point -- not perfect, but structurally sound and architecturally coherent.

---

## Phase 4: Pakistani Building Context

**Goal:** Add domain knowledge specific to Pakistan's construction industry, making this tool genuinely useful locally.

### 4.1 Pakistani Building Codes
- [ ] Research and encode Pakistan Building Code (PBC) 2021 key requirements:
  - Minimum room sizes for residential
  - Corridor and stairway widths
  - Fire escape requirements
  - Setback rules (front, side, rear)
  - Floor Area Ratio (FAR) / plot coverage limits
  - Parking requirements
- [ ] Encode city-specific bylaws (Karachi, Lahore, Islamabad have different rules)
- [ ] Create a compliance checking workflow (similar to shuotao's fire-rating-check)

### 4.2 Local Construction Practices
- [ ] Standard wall types in Pakistan (9" brick, 4.5" brick, RCC, block)
- [ ] Common floor systems (RCC slab, pre-stressed, waffle slab)
- [ ] Standard room sizes for Pakistani housing (drawing room, TV lounge, servant quarter)
- [ ] Common Revit families for Pakistani construction materials and fixtures
- [ ] Typical structural systems (RCC frame, load-bearing masonry)

### 4.3 Marla/Kanal/Square Feet Support
- [ ] Support Pakistani land measurement units: 1 Marla = 272.25 sq ft, 1 Kanal = 20 Marla
- [ ] Teach Claude to understand: "Design a house on a 10 Marla plot"
- [ ] Common plot sizes: 5 Marla, 7 Marla, 10 Marla, 1 Kanal, 2 Kanal
- [ ] Standard setback calculations per plot size

### 4.4 Local Architecture Styles
- [ ] Pakistani residential patterns: boundary wall, gate, driveway, separate drawing/dining
- [ ] Servant quarters, separate entrances
- [ ] Rooftop considerations (water tanks, washing area)
- [ ] Prayer room / mosque integration
- [ ] Climate-responsive design for Pakistan (hot climate, monsoon considerations)

**Deliverable:** Claude can understand "Design a 10 Marla house in DHA Lahore with 4 bedrooms, servant quarter, and car porch" and produce a code-compliant design.

**Acceptance Criteria:** The generated design would pass a basic review by a Pakistani architect for feasibility and code compliance.

---

## Phase 5: Digital Twin Pipeline

**Goal:** Export Revit models into interactive, web-viewable digital twins.

### 5.1 IFC Export Pipeline
- [ ] Add/verify IFC export MCP tool
- [ ] Test IFC export quality (geometry accuracy, parameter preservation)
- [ ] Automate IFC export as part of the design workflow
- [ ] Validate exported IFC files with IFC validation tools

### 5.2 Web-Based 3D Viewer
- [ ] Evaluate open-source IFC/3D viewers:
  - **IFC.js / That Open Engine** (https://thatopen.com/) -- open source, IFC-native
  - **xeokit** (https://xeokit.io/) -- high-performance BIM viewer
  - **Three.js + IFCLoader** -- flexible, widely used
  - **Autodesk Platform Services (APS) Viewer** -- official, cloud-hosted
- [ ] Set up a basic web viewer that loads an IFC file
- [ ] Add navigation (orbit, pan, zoom), element selection, property display
- [ ] Add floor-by-floor filtering (show/hide levels)
- [ ] Deploy to a simple web server (could be local or cloud)

### 5.3 Model Metadata & Querying
- [ ] Extract all element parameters during export (room areas, wall types, material quantities)
- [ ] Build a searchable database of building elements
- [ ] Enable queries like "Show me all fire-rated walls" or "What's the total floor area?"
- [ ] Display BIM data alongside the 3D view (click an element -> see its properties)

### 5.4 Real-Time Sync (Advanced)
- [ ] Investigate Autodesk Platform Services (APS) for cloud model hosting
- [ ] Set up BIM 360 / ACC (Autodesk Construction Cloud) integration
- [ ] Enable model versioning (design v1, v2, v3...)
- [ ] Webhook notifications when the model changes

### 5.5 IoT & Sensor Integration (Future Vision)
- [ ] Define sensor data schema (temperature, humidity, occupancy, energy usage)
- [ ] Map sensor locations to Revit rooms/spaces
- [ ] Overlay real-time sensor data on the digital twin
- [ ] Basic dashboard: energy consumption, occupancy heatmaps, environmental conditions

**Deliverable:** A web-based digital twin viewer where you can see and interact with the building designed in Revit.

**Acceptance Criteria:** Given a Revit model created through Claude Code, a client can view the building in 3D in their browser, click on rooms to see properties, and navigate floor by floor.

---

## Phase 6: Production Polish & Demo

**Goal:** Package everything into a demonstrable, repeatable workflow.

### 6.1 End-to-End Demo Workflow
- [ ] Script a complete demo: "Design a 3-story office building in Islamabad"
- [ ] Record the process: natural language input -> Claude reasoning -> Revit model appearing -> digital twin view
- [ ] Create a compelling video demo (screen recording + narration)
- [ ] Prepare a live demo capability for presentations

### 6.2 Documentation
- [ ] Installation guide (step-by-step, Windows-focused since Revit is Windows-only)
- [ ] User guide: how to talk to Claude for building design
- [ ] Architecture document: system design, data flow, component responsibilities
- [ ] API reference: all MCP tools with parameters and examples

### 6.3 Error Handling & Robustness
- [ ] Handle Revit crashes gracefully (auto-reconnect)
- [ ] Handle invalid geometry (walls of zero length, overlapping elements)
- [ ] Handle API timeouts (large operations)
- [ ] Add logging throughout the pipeline for debugging
- [ ] Implement undo/rollback for failed operations

### 6.4 Performance
- [ ] Batch operations where possible (create 10 walls in one call, not 10 calls)
- [ ] Minimize round-trips between Claude Code and Revit
- [ ] Cache element type information (don't re-query wall types every time)
- [ ] Profile slow operations and optimize

### 6.5 Security & Safety
- [ ] The `send_code_to_revit` tool is powerful but dangerous -- add guardrails
- [ ] Implement a "preview mode" where Claude describes what it will do before doing it
- [ ] Add confirmation prompts for destructive operations (delete, bulk modify)
- [ ] Ensure no network exposure (all communication on localhost only)

**Deliverable:** A polished, demo-ready system with documentation.

**Acceptance Criteria:** Someone who has never seen the project can follow the docs to install it, and a non-technical stakeholder can watch the demo and understand the value proposition.

---

## Timeline Estimate

| Phase | Duration | Dependencies |
|---|---|---|
| Phase 0: Foundation & Learning | 1-2 weeks | Revit installed |
| Phase 1: Pipeline Setup | 1 week | Phase 0 |
| Phase 2: Expand Tools | 2-3 weeks | Phase 1 |
| Phase 3: Design Intelligence | 3-4 weeks | Phase 2 |
| Phase 4: Pakistani Context | 2-3 weeks | Phase 3 (can overlap) |
| Phase 5: Digital Twins | 3-4 weeks | Phase 2 (can start in parallel) |
| Phase 6: Polish & Demo | 2 weeks | Phase 3, 5 |

**Total: ~14-19 weeks for full vision**

Phases 4 and 5 can run in parallel with Phase 3 once the core pipeline is solid.

---

## Key Risks & Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Revit license expires (trial is 30 days) | Blocks all work | Get educational/startup license from Autodesk, or work with the architect team Sir Zia is assembling |
| Revit API complexity | Slow Phase 2 | Lean on `send_code_to_revit` as escape hatch; study RevitLookup + thebuildingcoder.typepad.com |
| LLM hallucinations in design | Bad geometry | Always validate after creation; implement undo; use structured tool calls not free-form code |
| Performance with large models | Slow interaction | Batch operations; limit query result sizes; work in sections of the building |
| Pakistani building codes not digitized | Phase 4 blocked | Work with the architect team to manually encode key rules |
| Autodesk releases official MCP | Makes our work redundant? | No -- our Pakistani domain knowledge and design intelligence layer is the moat, not the plumbing |

---

## Tech Stack Summary

| Component | Technology | Status |
|---|---|---|
| LLM Client | Claude Code (terminal) | Existing |
| MCP Server | TypeScript / Node.js (`revit-mcp`) | Fork & extend |
| Revit Plugin | C# / .NET (`revit-mcp-plugin`) | Fork & extend |
| Command Set | C# (`revit-mcp-commandset`) | Fork & extend |
| Revit | Autodesk Revit 2024/2025 | Install |
| Digital Twin Viewer | IFC.js / xeokit / Three.js | Build |
| Web Server | Node.js or Python (for viewer) | Build |
| Database | SQLite (built into revit-mcp) | Existing |

---

## Success Metrics

1. **Phase 1 success:** Claude Code creates a wall in Revit in < 30 seconds end-to-end
2. **Phase 3 success:** "Design a 2-story house" produces a complete model in < 10 minutes
3. **Phase 4 success:** "Design a 10 Marla house in Lahore" produces a Pakistan-code-compliant design
4. **Phase 5 success:** The designed building is viewable as a 3D digital twin in a web browser
5. **Overall success:** A non-technical person can describe a building and receive both a Revit model and a digital twin
