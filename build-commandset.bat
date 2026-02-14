@echo off
cd /d "D:\Talal\Work\CLAUDE\Revit-MCP\revit-mcp-commandset"
dotnet restore revit-mcp-commandset.sln
dotnet build revit-mcp-commandset.sln -c "Debug R26"
