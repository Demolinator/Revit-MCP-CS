@echo off
echo Building Revit MCP Plugin for Revit 2026...
cd /d "D:\Talal\Work\CLAUDE\Revit-MCP\revit-mcp-plugin"
dotnet build revit-mcp-plugin.sln -c "Debug R26"
if errorlevel 1 (
    echo Plugin build FAILED
    exit /b 1
)
echo Plugin build OK
echo.
echo Building Command Set for Revit 2026...
cd /d "D:\Talal\Work\CLAUDE\Revit-MCP\revit-mcp-commandset"
dotnet build revit-mcp-commandset.sln -c "Debug R26"
if errorlevel 1 (
    echo CommandSet build FAILED
    exit /b 1
)
echo CommandSet build OK
echo.
echo ALL BUILDS SUCCESSFUL
