<#
.SYNOPSIS
    Run a Copilot demo setup using GitHub Copilot CLI + Playwright MCP.
    Reads the setup_prompt from content.json and executes it via AI agent.

.USAGE
    .\run-setup.ps1 outlook
    .\run-setup.ps1 --list
#>

param(
    [string]$DemoId = "",
    [switch]$List
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ContentFile = Join-Path $ScriptDir "content.json"

# Load content.json
if (-not (Test-Path $ContentFile)) {
    Write-Host "❌ content.json not found. Run install.ps1 first." -ForegroundColor Red
    exit 1
}

$content = Get-Content $ContentFile -Raw | ConvertFrom-Json
$tabs = $content.tabs | Where-Object { $_.playwright }

# List mode
if ($List -or $DemoId -eq "--list" -or $DemoId -eq "") {
    Write-Host ""
    Write-Host "  🎭 Available Demo Setups" -ForegroundColor Cyan
    Write-Host "  ========================" -ForegroundColor Cyan
    Write-Host ""
    foreach ($tab in $tabs) {
        $pw = $tab.playwright
        Write-Host "  $($tab.icon) $($tab.id.PadRight(16)) $($tab.title)" -ForegroundColor White
        Write-Host "    👤 $($pw.user)" -ForegroundColor Gray
        Write-Host "    ✅ $($pw.ready_check)" -ForegroundColor Gray
        Write-Host ""
    }
    Write-Host "  Usage: .\run-setup.ps1 <demo-id>" -ForegroundColor Yellow
    Write-Host "  Example: .\run-setup.ps1 outlook" -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

# Find demo
$tab = $tabs | Where-Object { $_.id -eq $DemoId } | Select-Object -First 1
if (-not $tab) {
    Write-Host "❌ Demo '$DemoId' not found. Run --list to see options." -ForegroundColor Red
    exit 1
}

$pw = $tab.playwright
$prompt = $pw.setup_prompt

Write-Host ""
Write-Host "  🎭 Setting up: $($tab.icon) $($tab.title)" -ForegroundColor Cyan
Write-Host "  👤 User: $($pw.user)" -ForegroundColor White
Write-Host "  🌐 URL: $($pw.url)" -ForegroundColor White
Write-Host "  ⏱  Est. time: ~$($pw.setup_time_sec)s" -ForegroundColor White
Write-Host ""

# ── Check GitHub Copilot CLI ──────────────────────────────────────────────────
$ghInstalled = $null -ne (Get-Command gh -ErrorAction SilentlyContinue)
if (-not $ghInstalled) {
    Write-Host "  ⬇  Installing GitHub CLI..." -ForegroundColor Yellow
    winget install --id GitHub.cli --silent --accept-package-agreements --accept-source-agreements 2>$null
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Host "  ❌ gh CLI install failed. Install manually: https://cli.github.com" -ForegroundColor Red
        exit 1
    }
}

# ── Check Playwright MCP config ───────────────────────────────────────────────
$mcpConfig = "$env:USERPROFILE\.copilot\mcp-config.json"
if (-not (Test-Path $mcpConfig)) {
    Write-Host "  ⚙️  Configuring Playwright MCP for GitHub Copilot..." -ForegroundColor Yellow
    $mcpDir = "$env:USERPROFILE\.copilot"
    New-Item -ItemType Directory -Path $mcpDir -Force | Out-Null
    $mcpJson = @{
        mcpServers = @{
            playwright = @{
                command = "npx"
                args = @("@playwright/mcp@latest", "--browser", "msedge", "--headed")
            }
        }
    } | ConvertTo-Json -Depth 5
    Set-Content -Path $mcpConfig -Value $mcpJson -Encoding UTF8
    Write-Host "  ✅ Playwright MCP configured" -ForegroundColor Green
}

# ── Build the full agent prompt ───────────────────────────────────────────────
$fullPrompt = @"
You are a demo setup agent. Use the Playwright MCP tools to prepare a Microsoft 365 Copilot demo.

TASK: $prompt

IMPORTANT RULES:
- Use browser_navigate to go to the correct URL
- Use browser_snapshot to verify each step
- Use browser_click to interact with UI elements
- If login is required, wait for the user to complete it (use browser_wait_for_load_state)
- When done, report: "✅ Demo ready: $($pw.ready_check)"
- Keep Edge browser open after setup

Start now.
"@

# ── Run via GitHub Copilot CLI agent mode ─────────────────────────────────────
Write-Host "  🤖 Launching GitHub Copilot agent with Playwright MCP..." -ForegroundColor White
Write-Host ""

# Write prompt to temp file to avoid shell escaping issues
$promptFile = "$env:TEMP\demo-setup-prompt.txt"
Set-Content -Path $promptFile -Value $fullPrompt -Encoding UTF8

# Run GitHub Copilot CLI in agent mode
# gh copilot agent runs in interactive mode with MCP servers
try {
    & gh copilot suggest --target shell (Get-Content $promptFile -Raw) 2>&1
} catch {
    # Fallback: open VS Code with the prompt if gh agent mode not available
    Write-Host "  ℹ️  gh copilot agent not available. Showing prompt for manual use:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Copy this prompt into your agent (VS Code Copilot, Claude, etc.):" -ForegroundColor White
    Write-Host ""
    Write-Host $fullPrompt -ForegroundColor Gray
    Write-Host ""
    
    # Copy to clipboard
    $fullPrompt | Set-Clipboard
    Write-Host "  📋 Prompt copied to clipboard!" -ForegroundColor Green
}

Write-Host ""
Write-Host "  Setup complete. Browser should be ready for demo." -ForegroundColor Cyan
