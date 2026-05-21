<#
.SYNOPSIS
    Copilot Demo Pre-Run Agent
    Uses GitHub Copilot CLI + Playwright MCP to prepare demos automatically.
    
    MODE 1 — setup:  Opens browser, navigates to URL, Copilot sidebar open
    MODE 2 — prerun: Executes the first demo steps completely (prompts typed + submitted, results visible)
    
.USAGE
    .\run-setup.ps1 prerun outlook     # Full pre-run: Outlook demo already executed, ready for handoff
    .\run-setup.ps1 prerun excel       # Full pre-run: Excel with analysis done
    .\run-setup.ps1 setup  outlook     # Just open browser + sidebar (faster, less prep)
    .\run-setup.ps1 --list             # Show all demos and their handoff points
    
.REQUIRES
    - Node.js (installed by install.ps1)
    - GitHub Copilot CLI (installed by install.ps1): command: copilot
    - @playwright/mcp configured in ~/.copilot/mcp-config.json (done by install.ps1)
    - M365 session active in Edge (sign in once, stays logged in)
#>

param(
    [string]$Mode = "prerun",   # prerun | setup
    [string]$DemoId = "",
    [switch]$List
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ContentFile = Join-Path $ScriptDir "content.json"

if (-not (Test-Path $ContentFile)) {
    Write-Host "❌ content.json not found. Run install.ps1 first." -ForegroundColor Red
    exit 1
}

$content = Get-Content $ContentFile -Raw | ConvertFrom-Json
$tabs = $content.tabs | Where-Object { $_.playwright }

# ── List mode ─────────────────────────────────────────────────────────────────
if ($List -or $DemoId -eq "--list" -or ($DemoId -eq "" -and $Mode -eq "prerun")) {
    Write-Host ""
    Write-Host "  🎭 Copilot Demo Pre-Run Agent" -ForegroundColor Cyan
    Write-Host "  =============================" -ForegroundColor Cyan
    Write-Host ""
    foreach ($tab in $tabs) {
        $pw = $tab.playwright
        $hasPrerun = $null -ne $pw.prerun_prompt
        $icon = if ($hasPrerun) { "🚀" } else { "⚙️ " }
        Write-Host "  $icon $($tab.id.PadRight(16)) $($tab.title)" -ForegroundColor White
        if ($hasPrerun) {
            Write-Host "    ✅ Handoff: $($pw.handoff)" -ForegroundColor Green
            Write-Host "    ⏱  ~$($pw.prerun_time_sec)s to complete" -ForegroundColor Gray
        } else {
            Write-Host "    ⚙️  Setup only (no pre-run configured)" -ForegroundColor Yellow
        }
        Write-Host ""
    }
    Write-Host "  Usage:" -ForegroundColor Yellow
    Write-Host "    .\run-setup.ps1 prerun outlook   # Run demo steps, hand off result to presenter" -ForegroundColor White
    Write-Host "    .\run-setup.ps1 setup  outlook   # Just prepare browser (no prompts executed)" -ForegroundColor White
    Write-Host ""
    exit 0
}

# Handle positional args: run-setup.ps1 prerun outlook OR run-setup.ps1 outlook
if ($Mode -eq "outlook" -or $Mode -eq "excel" -or $Mode -eq "teams" -or 
    $Mode -eq "word" -or $Mode -eq "powerpoint" -or $Mode -eq "workiq" -or 
    $Mode -eq "chat" -or $Mode -eq "agentbasic" -or $Mode -eq "agentpremium") {
    $DemoId = $Mode
    $Mode = "prerun"
}

$tab = $tabs | Where-Object { $_.id -eq $DemoId } | Select-Object -First 1
if (-not $tab) {
    Write-Host "❌ Demo '$DemoId' not found. Run --list to see options." -ForegroundColor Red
    exit 1
}

$pw = $tab.playwright
$usePrerun = ($Mode -eq "prerun") -and ($null -ne $pw.prerun_prompt)
$prompt = if ($usePrerun) { $pw.prerun_prompt } else { $pw.setup_prompt }
$estimatedTime = if ($usePrerun) { $pw.prerun_time_sec } else { $pw.setup_time_sec }

# ── Header ────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  🎭 Copilot Demo Pre-Run Agent" -ForegroundColor Cyan
Write-Host "  =============================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Demo    : $($tab.icon) $($tab.title)" -ForegroundColor White
Write-Host "  Mode    : $(if ($usePrerun) { '🚀 PRERUN (full execution)' } else { '⚙️  SETUP (browser prep only)' })" -ForegroundColor $(if ($usePrerun) { "Green" } else { "Yellow" })
Write-Host "  User    : $($pw.user)" -ForegroundColor White
Write-Host "  Est.    : ~${estimatedTime}s" -ForegroundColor White
if ($usePrerun) {
    Write-Host "  Handoff : $($pw.handoff)" -ForegroundColor Green
}
Write-Host ""

# ── Check Copilot CLI ─────────────────────────────────────────────────────────
$copilotInstalled = $null -ne (Get-Command copilot -ErrorAction SilentlyContinue)
if (-not $copilotInstalled) {
    Write-Host "  ⚠️  GitHub Copilot CLI ('copilot' command) not found." -ForegroundColor Yellow
    Write-Host "     Install: https://docs.github.com/en/copilot/how-tos/set-up/install-copilot-cli" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Falling back: copying prompt to clipboard for manual agent use..." -ForegroundColor Yellow
    $prompt | Set-Clipboard
    Write-Host "  📋 Prompt copied to clipboard!" -ForegroundColor Green
    Write-Host "  Paste into: GitHub Copilot in VS Code (agent mode), Claude, or any agent with Playwright MCP" -ForegroundColor Gray
    exit 0
}

# ── Check Playwright MCP config ───────────────────────────────────────────────
$mcpConfig = "$env:USERPROFILE\.copilot\mcp-config.json"
if (-not (Test-Path $mcpConfig)) {
    Write-Host "  ⚙️  Configuring Playwright MCP..." -ForegroundColor Yellow
    $mcpDir = "$env:USERPROFILE\.copilot"
    New-Item -ItemType Directory -Path $mcpDir -Force | Out-Null
    @{
        mcpServers = @{
            playwright = @{
                command = "npx"
                args = @("@playwright/mcp@latest", "--browser", "msedge", "--headed", "--cdp-endpoint", "about:blank")
            }
        }
    } | ConvertTo-Json -Depth 5 | Set-Content -Path $mcpConfig -Encoding UTF8
    Write-Host "  ✅ Playwright MCP configured" -ForegroundColor Green
}

# ── Build full prompt for Copilot CLI ─────────────────────────────────────────
$systemContext = @"
You are a demo preparation agent for Microsoft 365 Copilot live demos.
You have access to Playwright MCP tools: browser_navigate, browser_click, browser_type, browser_snapshot, browser_wait_for_load_state, browser_select_option.

RULES:
- Use browser_snapshot after each step to verify progress
- If a login page appears, wait for it to complete (user may need to sign in)
- Execute ALL steps completely — do not stop partway through
- When finished, report: DONE — [handoff description]
- Keep the browser OPEN after completion

YOUR TASK:
$prompt
"@

# Write to temp file (avoids PowerShell escaping issues with special chars)
$promptFile = "$env:TEMP\copilot-demo-prerun.txt"
Set-Content -Path $promptFile -Value $systemContext -Encoding UTF8

# ── Execute via GitHub Copilot CLI ────────────────────────────────────────────
Write-Host "  🤖 Starting GitHub Copilot agent..." -ForegroundColor White
Write-Host "  (Browser will open — do not interfere until 'DONE' is reported)" -ForegroundColor Gray
Write-Host ""

try {
    # GitHub Copilot CLI programmatic mode with Playwright MCP
    & copilot -p (Get-Content $promptFile -Raw) `
        --allow-tool="mcp_playwright_browser_navigate" `
        --allow-tool="mcp_playwright_browser_click" `
        --allow-tool="mcp_playwright_browser_type" `
        --allow-tool="mcp_playwright_browser_snapshot" `
        --allow-tool="mcp_playwright_browser_wait_for_load_state" `
        --allow-tool="mcp_playwright_browser_select_option" `
        --allow-tool="mcp_playwright_browser_take_screenshot"
    
    Write-Host ""
    Write-Host "  ✅ Pre-run complete!" -ForegroundColor Green
    Write-Host "  Handoff: $($pw.handoff)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  The browser is ready. You can now present the demo." -ForegroundColor White

} catch {
    Write-Host "  ⚠️  Copilot CLI error: $_" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Manual fallback — prompt copied to clipboard:" -ForegroundColor Yellow
    $systemContext | Set-Clipboard
    Write-Host "  📋 Paste into VS Code Copilot (agent mode with Playwright MCP) or Claude Desktop" -ForegroundColor White
}

# Cleanup
Remove-Item $promptFile -Force -ErrorAction SilentlyContinue
