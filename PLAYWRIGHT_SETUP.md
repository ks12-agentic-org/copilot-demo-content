# Demo Setup with GitHub Copilot CLI + Playwright MCP

## Overview

Each demo tab has a natural-language `setup_prompt` in `content.json`.
You give this prompt to GitHub Copilot CLI (with Playwright MCP enabled) on the demo VM.
The AI interprets the prompt and prepares the browser automatically.

## Architecture

```
content.json
  └── tabs[].playwright.setup_prompt
           │
           ▼
  run-setup.ps1 "outlook"
           │  reads prompt from content.json
           │  passes to GitHub Copilot CLI
           ▼
  gh copilot + @playwright/mcp
           │  AI interprets natural language
           │  uses browser_navigate, browser_click, etc.
           ▼
  Browser ready for demo ✅
```

## One-Time Setup on Demo VM

Run `install.ps1` — it handles everything:
```powershell
irm https://raw.githubusercontent.com/ks12-agentic-org/copilot-demo-content/main/install.ps1 | iex
```

Installs:
- Node.js LTS
- `@playwright/mcp` (official Microsoft Playwright MCP server)
- GitHub Copilot CLI (`gh` + extension)
- Configures Playwright MCP in `~/.copilot/mcp-config.json`

## Run a Demo Setup

```powershell
cd CopilotDemoFiles   # or wherever you installed
.\run-setup.ps1 outlook       # Outlook demo
.\run-setup.ps1 excel         # Excel demo
.\run-setup.ps1 agentpremium  # Agent Builder Premium
.\run-setup.ps1 --list        # Show all demos
```

## Available Demos

| Demo ID | Setup | User Account |
|---|---|---|
| `outlook` | Inbox + Copilot sidebar | Leila (M365 Copilot) |
| `teams` | Teams Copilot Chat | Leila (M365 Copilot) |
| `word` | Word + Copilot + file ready | Leila (M365 Copilot) |
| `excel` | Excel + KPI file + Copilot | Leila (M365 Copilot) |
| `powerpoint` | PowerPoint + Copilot + pipeline doc | Leila (M365 Copilot) |
| `workiq` | M365 Copilot Chat (Work tab) | Leila (M365 Copilot) |
| `chat` | Copilot Chat free tier | **Selma** (no Copilot) |
| `agentbasic` | Agent Builder, no PayGo | **Selma** (no Copilot) |
| `agentpremium` | Agent Builder + file upload | Leila (M365 Copilot) |

## How It Works

`run-setup.ps1` reads the `playwright.setup_prompt` from `content.json` and sends it to
GitHub Copilot CLI which has Playwright MCP connected. The AI then:

1. Calls `browser_navigate(url)` → opens the right page
2. Calls `browser_click(element)` → clicks relevant UI elements
3. Calls `browser_snapshot()` → verifies the page is ready
4. Reports back: "✅ Demo ready: [ready_check]"

## MCP Config (auto-installed)

`~/.copilot/mcp-config.json`:
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest", "--browser", "msedge"]
    }
  }
}
```

## Manual Usage (without run-setup.ps1)

```powershell
# Get the prompt for a demo
$demo = "outlook"
$prompt = (Get-Content content.json | ConvertFrom-Json).tabs | 
  Where-Object { $_.id -eq $demo } | 
  Select-Object -ExpandProperty playwright | 
  Select-Object -ExpandProperty setup_prompt

# Run with GitHub Copilot CLI
gh copilot suggest -t shell $prompt
# OR in Copilot Chat (VS Code):
# Paste prompt into @agent mode with Playwright MCP enabled
```
