# Revit MCP Presentation

Professional 10-slide PowerPoint presentation for Talal Ahmed's Revit MCP project.

## Files Created

- **Revit-MCP-Presentation.pptx** - Final presentation (660KB)
- **slides/** - 10 HTML slides (slide1.html - slide10.html)
- **assets/** - Gradient backgrounds and accent graphics
- **generate-slides.js** - Node.js generation script

## Presentation Content

### Slide 1: Title
- "Design Buildings Using Natural Language"
- Connecting Claude Code AI to Autodesk Revit 2026 via MCP
- Talal Ahmed | Mentored by Sir Zia Khan

### Slide 2: The Problem
- Why this matters
- Construction is Pakistan's biggest industry
- Revit takes months/years to learn
- Natural language as the solution

### Slide 3: The Solution
- Natural Language Building Design
- Talk to Claude Code in plain English
- Create walls, floors, grids, beams instantly

### Slide 4: Architecture Diagram
- Visual flow: Claude → MCP → Revit Plugin → Revit API
- Shows WSL2/Linux and Windows sides

### Slide 5: What is MCP?
- Model Context Protocol
- Open standard by Anthropic
- Like a USB port for AI

### Slide 6: Available Tools (19 Commands)
- CREATE: Walls, Floors, Grids, Beams, Dimensions, Point elements
- QUERY: View info, Family types, Selected elements, Room data, Material quantities, Model statistics

### Slide 7: Live Demo Results
- "The Prism" - 3-story neo-futuristic building
- Glass curtain wall facade
- Cantilevered second floor
- All created through natural language

### Slide 8: Setup
- One-command setup
- Easy installation steps

### Slide 9: Future Vision
- Digital twins from natural language
- AI-assisted architectural design for Pakistan
- Making construction design accessible

### Slide 10: Thank You
- Contact information
- GitHub and phone placeholders

## Design Specifications

- **Theme**: Futuristic tech
- **Colors**:
  - Background: #0D1117 (dark)
  - Accent: #00D4FF (cyan)
  - Text: #FFFFFF (white), #c9d1d9 (light gray)
- **Font**: Arial (web-safe)
- **Aspect Ratio**: 16:9 (720pt × 405pt)
- **Special Effects**: Gradient backgrounds created with Sharp

## Customization

To update contact information, edit the placeholders:
- `[Your Phone Number]` on slides 1 and 10
- `[Your GitHub]` on slide 10

To regenerate the presentation:
```bash
cd /mnt/d/Talal/Work/CLAUDE/Revit-MCP/presentation
node generate-slides.js
```

## Notes

- All backgrounds use PNG gradients (not CSS) for PowerPoint compatibility
- Cyan accent lines created with Sharp SVG rasterization
- Architecture diagram simplified for clarity
- Professional spacing and typography throughout
