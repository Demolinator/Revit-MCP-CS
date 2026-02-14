#!/bin/bash
# ============================================================
# Revit MCP - One-Click Setup (WSL2 Side)
# Run this from WSL2 terminal
# ============================================================
set -e

echo "============================================"
echo "  Revit MCP - Automated Setup"
echo "  Connecting Claude Code to Autodesk Revit"
echo "============================================"
echo ""

# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# ---- Step 1: Clone repos if not present ----
echo "[1/5] Checking repositories..."
if [ ! -d "revit-mcp" ]; then
    echo "  Cloning MCP Server..."
    git clone https://github.com/mcp-servers-for-revit/revit-mcp.git
else
    echo "  revit-mcp/ already exists"
fi

if [ ! -d "revit-mcp-plugin" ]; then
    echo "  Cloning Revit Plugin..."
    git clone https://github.com/mcp-servers-for-revit/revit-mcp-plugin.git
else
    echo "  revit-mcp-plugin/ already exists"
fi

if [ ! -d "revit-mcp-commandset" ]; then
    echo "  Cloning Command Set..."
    git clone https://github.com/mcp-servers-for-revit/revit-mcp-commandset.git
else
    echo "  revit-mcp-commandset/ already exists"
fi
echo "  Done."
echo ""

# ---- Step 2: Build MCP Server ----
echo "[2/5] Building MCP Server (TypeScript)..."
cd "$SCRIPT_DIR/revit-mcp"
if [ ! -d "node_modules" ]; then
    npm install 2>&1 | tail -1
fi
npm run build 2>&1 | tail -1
cd "$SCRIPT_DIR"
echo "  Done."
echo ""

# ---- Step 3: Detect WSL2 Gateway IP ----
echo "[3/5] Detecting WSL2 Gateway IP..."
GATEWAY_IP=$(ip route show default | awk '{print $3}')
echo "  Gateway IP: $GATEWAY_IP"
echo ""

# ---- Step 4: Build C# projects on Windows ----
echo "[4/5] Building Revit Plugin & Command Set (Windows/.NET)..."
echo "  This calls setup-windows.bat via cmd.exe..."

# Convert WSL path to Windows path for the bat file
WIN_DIR=$(wslpath -w "$SCRIPT_DIR")
cmd.exe /c "$WIN_DIR\\setup-windows.bat" 2>&1 | tail -20

echo "  Done."
echo ""

# ---- Step 5: Register MCP with Claude Code ----
echo "[5/5] Registering MCP Server with Claude Code..."
MCP_SERVER_PATH="$SCRIPT_DIR/revit-mcp/build/index.js"

# Remove existing revit-mcp config if present
claude mcp remove revit-mcp 2>/dev/null || true

# Add fresh config with correct gateway IP
claude mcp add-json revit-mcp "{
  \"type\": \"stdio\",
  \"command\": \"node\",
  \"args\": [\"$MCP_SERVER_PATH\"],
  \"env\": {
    \"REVIT_HOST\": \"$GATEWAY_IP\",
    \"REVIT_PORT\": \"8080\"
  }
}"

echo "  Registered with REVIT_HOST=$GATEWAY_IP"
echo ""

# ---- Done ----
echo "============================================"
echo "  SETUP COMPLETE!"
echo "============================================"
echo ""
echo "  Next steps:"
echo "  1. Open Revit 2026 and open/create a project"
echo "  2. Go to Add-Ins tab > Click 'Revit MCP Switch'"
echo "  3. Open Claude Code: claude"
echo "  4. Start talking: 'Get the current view info from Revit'"
echo ""
echo "  Gateway IP: $GATEWAY_IP"
echo "  MCP Server: $MCP_SERVER_PATH"
echo "============================================"
