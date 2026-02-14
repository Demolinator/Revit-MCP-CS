@echo off
REM ============================================================
REM Revit MCP - Windows Side Setup
REM Builds the C# Plugin + CommandSet and configures Revit
REM ============================================================
echo.
echo ============================================
echo   Building Revit Plugin and Command Set
echo ============================================
echo.

REM Get the directory of this script
set "SCRIPT_DIR=%~dp0"

REM ---- Build Plugin ----
echo [1/3] Building Revit Plugin...
cd /d "%SCRIPT_DIR%revit-mcp-plugin"
dotnet restore revit-mcp-plugin.sln >nul 2>&1
dotnet build revit-mcp-plugin.sln -c "Debug R26" 2>&1 | findstr /i "succeed fail error"
echo.

REM ---- Build Command Set ----
echo [2/3] Building Command Set...
cd /d "%SCRIPT_DIR%revit-mcp-commandset"
dotnet restore revit-mcp-commandset.sln >nul 2>&1
dotnet build revit-mcp-commandset.sln -c "Debug R26" 2>&1 | findstr /i "succeed fail error"
echo.

REM ---- Copy Command Registry ----
echo [3/3] Configuring Command Registry...
set "ADDINS_DIR=%APPDATA%\Autodesk\Revit\Addins\2026\revit_mcp_plugin\Commands"
if not exist "%ADDINS_DIR%" mkdir "%ADDINS_DIR%"
copy /Y "%SCRIPT_DIR%commandRegistry.json" "%ADDINS_DIR%\commandRegistry.json" >nul 2>&1
echo   Command registry installed to: %ADDINS_DIR%
echo.

echo ============================================
echo   Windows build complete!
echo ============================================
