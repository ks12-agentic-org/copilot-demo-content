<#
.SYNOPSIS
    Copilot Demo Setup — Downloads all demo files from GitHub to this VM.
    Run this on any CDX Demo VM before a demo.

.USAGE
    Single-line install (run in PowerShell as user):
    irm https://raw.githubusercontent.com/ks12-agentic-org/copilot-demo-content/main/install.ps1 | iex
#>

$ErrorActionPreference = "Stop"
$REPO = "https://github.com/ks12-agentic-org/copilot-demo-content"
$ZIP_URL = "https://github.com/ks12-agentic-org/copilot-demo-content/archive/refs/heads/main.zip"
$DEST_NAME = "CopilotDemoFiles"

Write-Host ""
Write-Host "  Copilot Demo Setup" -ForegroundColor Cyan
Write-Host "  ==================" -ForegroundColor Cyan
Write-Host ""

# Find best destination (OneDrive > Desktop > Documents)
$oneDrive = $null
$possibleOneDrive = @(
    "$env:USERPROFILE\OneDrive",
    "$env:USERPROFILE\OneDrive - m365cpi98544940",
    (Get-ItemProperty -Path "HKCU:\Software\Microsoft\OneDrive" -Name "UserFolder" -ErrorAction SilentlyContinue)?.UserFolder
) | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1

if ($possibleOneDrive) {
    $destBase = $possibleOneDrive
    Write-Host "  📁 Target: OneDrive ($destBase)" -ForegroundColor Green
} else {
    $destBase = [Environment]::GetFolderPath("Desktop")
    Write-Host "  📁 Target: Desktop (OneDrive not found)" -ForegroundColor Yellow
}

$dest = Join-Path $destBase $DEST_NAME

# Download ZIP
$zip = Join-Path $env:TEMP "copilot-demo-content.zip"
Write-Host "  ⬇  Downloading from GitHub..." -ForegroundColor White
Invoke-WebRequest -Uri $ZIP_URL -OutFile $zip -UseBasicParsing

# Extract
$extractTo = Join-Path $env:TEMP "copilot-demo-extract"
if (Test-Path $extractTo) { Remove-Item $extractTo -Recurse -Force }
Expand-Archive -Path $zip -DestinationPath $extractTo -Force

$extractedFolder = Get-ChildItem $extractTo | Select-Object -First 1

# Copy files/ to destination
$filesSource = Join-Path $extractedFolder.FullName "files"
if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
New-Item -ItemType Directory -Path $dest -Force | Out-Null
Copy-Item "$filesSource\*" -Destination $dest -Recurse

# Also copy promptprompter/ MDs
$mdDest = Join-Path $dest "PromptPrompter_MDs"
New-Item -ItemType Directory -Path $mdDest -Force | Out-Null
$mdSource = Join-Path $extractedFolder.FullName "promptprompter"
Copy-Item "$mdSource\*" -Destination $mdDest -Recurse

# Create Desktop shortcut to folder
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut("$env:USERPROFILE\Desktop\Copilot Demo Files.lnk")
$shortcut.TargetPath = $dest
$shortcut.Save()

# Cleanup
Remove-Item $zip -Force -ErrorAction SilentlyContinue
Remove-Item $extractTo -Recurse -Force -ErrorAction SilentlyContinue

# Summary
$fileCount = (Get-ChildItem $dest -File).Count
Write-Host ""
Write-Host "  ✅ Done! $fileCount demo files installed." -ForegroundColor Green
Write-Host ""
Write-Host "  📂 Location : $dest" -ForegroundColor Cyan
Write-Host "  🖥️  Shortcut : Desktop > 'Copilot Demo Files'" -ForegroundColor Cyan
Write-Host "  📝 MDs      : $mdDest" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Files ready to use in Copilot demos:" -ForegroundColor White

Get-ChildItem $dest -File | ForEach-Object {
    Write-Host "    · $($_.Name)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "  Repo: $REPO" -ForegroundColor DarkGray
Write-Host "  Run again to update to latest version." -ForegroundColor DarkGray
Write-Host ""

# ── Install GitHub Copilot CLI + Playwright MCP ────────────────────────────────
Write-Host ""
Write-Host "  🤖 Setting up GitHub Copilot CLI + Playwright MCP..." -ForegroundColor White

# Install GitHub CLI if needed
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "  ⬇  Installing GitHub CLI..." -ForegroundColor Yellow
    try {
        winget install --id GitHub.cli --silent --accept-package-agreements --accept-source-agreements 2>$null
        Write-Host "  ✅ GitHub CLI installed" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠️  GitHub CLI install failed (install manually: https://cli.github.com)" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ✅ GitHub CLI already installed" -ForegroundColor Green
}

# Configure Playwright MCP for GitHub Copilot
$mcpConfig = "$env:USERPROFILE\.copilot\mcp-config.json"
$mcpDir = "$env:USERPROFILE\.copilot"
New-Item -ItemType Directory -Path $mcpDir -Force | Out-Null
$mcpJson = '{"mcpServers":{"playwright":{"command":"npx","args":["@playwright/mcp@latest","--browser","msedge","--headed"]}}}'
Set-Content -Path $mcpConfig -Value $mcpJson -Encoding UTF8
Write-Host "  ✅ Playwright MCP configured for GitHub Copilot" -ForegroundColor Green

# Copy run-setup.ps1 to demo files folder
$setupScript = Join-Path $extractedFolder.FullName "run-setup.ps1"
if (Test-Path $setupScript) {
    Copy-Item $setupScript (Join-Path $dest "run-setup.ps1") -Force
}

Write-Host ""
Write-Host "  🎭 Demo Agent ready! Usage:" -ForegroundColor Cyan
Write-Host "     cd '$dest'" -ForegroundColor White
Write-Host "     .\run-setup.ps1 outlook    # Prepare Outlook demo" -ForegroundColor White
Write-Host "     .\run-setup.ps1 --list     # Show all demos" -ForegroundColor White
