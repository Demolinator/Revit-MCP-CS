@echo off
cd /d "D:\Talal\Work\CLAUDE\Revit-MCP\revit-mcp-plugin"
dotnet restore revit-mcp-plugin.sln
dotnet build revit-mcp-plugin.sln -c "Debug R26"
