#!/bin/bash
# ============================================================
# Revit MCP - One-Click Setup (WSL2 Side)
# Connects Claude Code AI to Autodesk Revit 2026
# Run this from WSL2 terminal inside the project directory
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

# ---- Step 0: Check Prerequisites ----
echo "[0/6] Checking prerequisites..."
MISSING=""

if ! command -v git &>/dev/null; then
    MISSING="$MISSING  - git (https://git-scm.com/)\n"
fi
if ! command -v node &>/dev/null; then
    MISSING="$MISSING  - node (https://nodejs.org/ - v18+ required)\n"
fi
if ! command -v npm &>/dev/null; then
    MISSING="$MISSING  - npm (comes with Node.js)\n"
fi
if ! command -v claude &>/dev/null; then
    MISSING="$MISSING  - claude (npm install -g @anthropic-ai/claude-code)\n"
fi

# Check if dotnet is available on Windows side
if ! cmd.exe /c "where dotnet" &>/dev/null 2>&1; then
    MISSING="$MISSING  - .NET 8.0 SDK on Windows (https://dotnet.microsoft.com/download/dotnet/8.0)\n"
fi

if [ -n "$MISSING" ]; then
    echo "  ERROR: Missing required tools:"
    echo -e "$MISSING"
    echo "  Please install the missing tools and run this script again."
    exit 1
fi
echo "  All prerequisites found."
echo ""

# ---- Step 1: Clone repos if not present ----
echo "[1/6] Checking repositories..."
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
echo "[2/6] Building MCP Server (TypeScript)..."
cd "$SCRIPT_DIR/revit-mcp"
if [ ! -d "node_modules" ]; then
    echo "  Installing dependencies..."
    npm install 2>&1 | tail -3
fi
echo "  Compiling TypeScript..."
npm run build 2>&1 | tail -3
if [ ! -f "build/index.js" ]; then
    echo "  ERROR: MCP Server build failed - build/index.js not found"
    exit 1
fi
cd "$SCRIPT_DIR"
echo "  Done."
echo ""

# ---- Step 3: Detect WSL2 Gateway IP ----
echo "[3/6] Detecting WSL2 Gateway IP..."
GATEWAY_IP=$(ip route show default | awk '{print $3}')
if [ -z "$GATEWAY_IP" ]; then
    echo "  ERROR: Could not detect WSL2 gateway IP."
    echo "  Are you running this in WSL2?"
    exit 1
fi
echo "  Gateway IP: $GATEWAY_IP"
echo ""

# ---- Step 4: Build C# projects on Windows ----
echo "[4/6] Building Revit Plugin & Command Set (Windows/.NET)..."
echo "  This calls setup-windows.bat via cmd.exe..."
echo ""

# Convert WSL path to Windows path for the bat file
WIN_DIR=$(wslpath -w "$SCRIPT_DIR")
# Run the bat file and show output (don't suppress errors)
cmd.exe /c "$WIN_DIR\\setup-windows.bat" 2>&1
BUILD_EXIT=$?

if [ $BUILD_EXIT -ne 0 ]; then
    echo ""
    echo "  WARNING: Windows build may have had issues (exit code $BUILD_EXIT)"
    echo "  Check the output above for errors."
fi
echo ""

# ---- Step 5: Configure Windows Firewall for WSL2 ----
echo "[5/6] Configuring Windows Firewall for WSL2..."
echo "  Adding firewall rule to allow port 8080 from WSL2..."
# This needs admin privileges - will prompt UAC
cmd.exe /c "powershell -Command \"Start-Process powershell -Verb RunAs -ArgumentList '-Command', 'New-NetFirewallRule -DisplayName \\\"Revit MCP (WSL2)\\\" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow -Profile Private 2>$null; Write-Host \\\"Firewall rule added\\\"'\"" 2>/dev/null || true
echo "  If a UAC prompt appeared, please click Yes to allow."
echo "  (If port 8080 is already allowed, this step is safe to ignore)"
echo ""

# ---- Step 6: Register MCP with Claude Code ----
echo "[6/6] Registering MCP Server with Claude Code..."
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
echo "  2. If prompted, click 'Always Load' for the add-in"
echo "  3. Go to Add-Ins tab > Click 'Revit MCP Switch'"
echo "  4. Open Claude Code: claude"
echo "  5. Try: 'Get the current view info from Revit'"
echo ""
echo "  Troubleshooting:"
echo "  - If 'connection refused': Check Windows Firewall allows port 8080"
echo "  - If MCP tools missing: Restart Claude Code"
echo "  - If Revit doesn't show add-in: Close Revit, re-run setup-windows.bat"
echo ""
echo "  Gateway IP: $GATEWAY_IP"
echo "  MCP Server: $MCP_SERVER_PATH"
echo "============================================"
