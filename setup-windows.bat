@echo off
REM ============================================================
REM Revit MCP - Windows Side Setup
REM Builds the C# Plugin + CommandSet and deploys to Revit 2026
REM ============================================================
echo.
echo ============================================
echo   Revit MCP - Windows Build
echo ============================================
echo.

REM Get the directory of this script
set "SCRIPT_DIR=%~dp0"

REM ---- Check .NET SDK ----
where dotnet >nul 2>&1
if errorlevel 1 (
    echo [ERROR] .NET 8.0 SDK not found!
    echo   Download from: https://dotnet.microsoft.com/download/dotnet/8.0
    exit /b 1
)

REM ---- Check Revit is NOT running (DLLs would be locked) ----
tasklist /FI "IMAGENAME eq Revit.exe" 2>nul | find /i "Revit.exe" >nul
if not errorlevel 1 (
    echo [WARNING] Revit is currently running!
    echo   DLLs may be locked. Close Revit first for a clean build.
    echo   Continuing anyway...
    echo.
)

REM ---- Build Plugin ----
echo [1/4] Building Revit Plugin...
cd /d "%SCRIPT_DIR%revit-mcp-plugin"
dotnet build revit-mcp-plugin.sln -c "Debug R26" --no-incremental
if errorlevel 1 (
    echo [ERROR] Plugin build failed!
    exit /b 1
)
echo   [OK] Plugin built successfully.
echo.

REM ---- Build Command Set ----
echo [2/4] Building Command Set...
cd /d "%SCRIPT_DIR%revit-mcp-commandset"
dotnet build revit-mcp-commandset.sln -c "Debug R26" --no-incremental
if errorlevel 1 (
    echo [ERROR] CommandSet build failed!
    exit /b 1
)
echo   [OK] CommandSet built successfully.
echo.

REM ---- Copy Command Registry (our expanded version with all 19 commands) ----
echo [3/4] Installing Command Registry...
set "COMMANDS_DIR=%APPDATA%\Autodesk\Revit\Addins\2026\revit_mcp_plugin\Commands"
if not exist "%COMMANDS_DIR%" mkdir "%COMMANDS_DIR%"
copy /Y "%SCRIPT_DIR%commandRegistry.json" "%COMMANDS_DIR%\commandRegistry.json" >nul
if errorlevel 1 (
    echo [ERROR] Failed to copy commandRegistry.json
    exit /b 1
)
echo   [OK] Command registry installed (%COMMANDS_DIR%)
echo.

REM ---- Verify Installation ----
echo [4/4] Verifying installation...
set "ADDINS=%APPDATA%\Autodesk\Revit\Addins\2026"

set "ALL_OK=1"

if exist "%ADDINS%\revit-mcp.addin" (
    echo   [OK] revit-mcp.addin manifest
) else (
    echo   [!!] revit-mcp.addin NOT found
    echo        The plugin build should have copied it automatically.
    echo        Manual fix: copy from revit-mcp-plugin\revit-mcp-plugin\revit-mcp.addin
    set "ALL_OK=0"
)

if exist "%ADDINS%\revit_mcp_plugin\revit-mcp-plugin.dll" (
    echo   [OK] revit-mcp-plugin.dll
) else (
    echo   [!!] revit-mcp-plugin.dll NOT found
    set "ALL_OK=0"
)

if exist "%COMMANDS_DIR%\RevitMCPCommandSet\2026\RevitMCPCommandSet.dll" (
    echo   [OK] RevitMCPCommandSet.dll
) else (
    echo   [!!] RevitMCPCommandSet.dll NOT found
    set "ALL_OK=0"
)

if exist "%COMMANDS_DIR%\commandRegistry.json" (
    echo   [OK] commandRegistry.json (19 commands)
) else (
    echo   [!!] commandRegistry.json NOT found
    set "ALL_OK=0"
)

echo.
if "%ALL_OK%"=="1" (
    echo ============================================
    echo   Windows build COMPLETE - all files verified!
    echo ============================================
) else (
    echo ============================================
    echo   Windows build COMPLETE with warnings
    echo   Check [!!] items above
    echo ============================================
)
