@echo off
echo ============================================
echo  Building Revit MCP for Revit 2026
echo ============================================
echo.

:: Check if dotnet is available
where dotnet >nul 2>&1
if errorlevel 1 (
    echo ERROR: .NET SDK not found. Please install .NET 8.0 SDK from:
    echo https://dotnet.microsoft.com/en-us/download/dotnet/8.0
    echo.
    pause
    exit /b 1
)

echo [1/4] Restoring and building revit-mcp-plugin...
cd /d "%~dp0revit-mcp-plugin"
dotnet restore revit-mcp-plugin.sln
dotnet build revit-mcp-plugin.sln -c "Debug R26"
if errorlevel 1 (
    echo ERROR: Plugin build failed!
    pause
    exit /b 1
)
echo [OK] Plugin built successfully.
echo.

echo [2/4] Restoring and building revit-mcp-commandset...
cd /d "%~dp0revit-mcp-commandset"
dotnet restore revit-mcp-commandset.sln
dotnet build revit-mcp-commandset.sln -c "Debug R26"
if errorlevel 1 (
    echo ERROR: CommandSet build failed!
    pause
    exit /b 1
)
echo [OK] CommandSet built successfully.
echo.

echo [3/4] Checking Revit addins folder...
set ADDINS=%AppData%\Autodesk\Revit\Addins\2026
if not exist "%ADDINS%" (
    echo Creating addins folder: %ADDINS%
    mkdir "%ADDINS%"
)
echo Addins folder: %ADDINS%
echo.

echo [4/4] Verifying installation...
echo.
echo Checking for plugin files:
if exist "%ADDINS%\revit-mcp.addin" (
    echo   [OK] revit-mcp.addin found
) else (
    echo   [!!] revit-mcp.addin NOT found - you may need to copy it manually
    echo        From: %~dp0revit-mcp-plugin\revit-mcp-plugin\bin\Debug\2026\
    echo        To:   %ADDINS%\
)

if exist "%ADDINS%\revit_mcp_plugin" (
    echo   [OK] revit_mcp_plugin folder found
) else (
    echo   [!!] revit_mcp_plugin folder NOT found
)

echo.
echo ============================================
echo  Build complete! Next steps:
echo ============================================
echo.
echo  1. Open Revit 2026
echo  2. If prompted about loading add-in, click "Always Load"
echo  3. Go to Add-ins tab - you should see "Revit MCP Plugin"
echo  4. Click "Settings" and configure command set path
echo  5. Click "Revit MCP Switch" to start the TCP server
echo  6. Go back to Claude Code and test!
echo.
pause
