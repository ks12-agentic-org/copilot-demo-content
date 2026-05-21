/**
 * demo-agent.js — Copilot Demo Setup Agent
 * 
 * Reads the setup_prompt from content.json and executes it via Playwright.
 * Run on the CDX Demo VM (TC-Leila, TC-Preston, etc.)
 * 
 * Usage:
 *   node demo-agent.js <demo-id>
 *   node demo-agent.js outlook
 *   node demo-agent.js excel
 *   node demo-agent.js --list
 * 
 * Or as a one-liner after cloning the repo:
 *   npx playwright install chromium && node demo-agent.js outlook
 */

const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const CONTENT_FILE = path.join(__dirname, 'content.json');
const DEMO_FILES_DIR = process.env.DEMO_FILES_DIR || 
  (process.env.OneDrive ? path.join(process.env.OneDrive, 'CopilotDemoFiles') : 
   path.join(process.env.USERPROFILE || process.env.HOME || '.', 'Desktop', 'CopilotDemoFiles'));

// ── Load content ─────────────────────────────────────────────────────────────
let content;
try {
  content = JSON.parse(fs.readFileSync(CONTENT_FILE, 'utf8'));
} catch(e) {
  console.error('❌ Could not load content.json:', e.message);
  process.exit(1);
}

const tabs = content.tabs || [];

// ── CLI handling ──────────────────────────────────────────────────────────────
const arg = process.argv[2];

if (!arg || arg === '--list' || arg === '-l') {
  console.log('\n📋 Available demo setups:\n');
  tabs.forEach(tab => {
    if (tab.playwright) {
      const pw = tab.playwright;
      console.log(`  ${tab.icon} ${tab.id.padEnd(14)} → ${tab.title}`);
      console.log(`    User: ${pw.user}`);
      console.log(`    URL:  ${pw.url}`);
      console.log(`    Ready: ${pw.ready_check}`);
      console.log(`    Time: ~${pw.setup_time_sec}s\n`);
    }
  });
  console.log('Usage: node demo-agent.js <demo-id>\n');
  process.exit(0);
}

const tab = tabs.find(t => t.id === arg);
if (!tab) {
  console.error(`❌ Demo "${arg}" not found. Run --list to see available demos.`);
  process.exit(1);
}

if (!tab.playwright) {
  console.error(`❌ No Playwright setup configured for "${arg}".`);
  process.exit(1);
}

const pw = tab.playwright;

// ── Run Playwright ────────────────────────────────────────────────────────────
async function setupDemo() {
  console.log(`\n🎬 Setting up: ${tab.icon} ${tab.title}`);
  console.log(`👤 User: ${pw.user}`);
  console.log(`🌐 URL: ${pw.url}`);
  console.log(`⏱  Est. time: ~${pw.setup_time_sec}s\n`);

  // Use persistent context so existing M365 sessions are reused
  const userDataDir = path.join(
    process.env.LOCALAPPDATA || process.env.HOME || '.', 
    'CopilotDemoChrome'
  );

  const browser = await chromium.launchPersistentContext(userDataDir, {
    headless: false,
    channel: 'msedge',  // use Edge on demo VMs (falls back to Chrome)
    args: ['--start-maximized'],
    viewport: null,     // use full screen size
    ignoreDefaultArgs: ['--enable-automation'],
  });

  const page = browser.pages()[0] || await browser.newPage();

  try {
    // Navigate to demo URL
    console.log(`→ Navigating to ${pw.url}`);
    await page.goto(pw.url, { waitUntil: 'domcontentloaded', timeout: 30000 });

    // Wait for page to stabilize
    await page.waitForTimeout(2000);

    // Check if login needed
    const url = page.url();
    if (url.includes('login.microsoftonline.com') || url.includes('microsoftonline.com/common')) {
      console.log(`🔐 Login required — please sign in as: ${pw.user}`);
      console.log('   Waiting up to 60 seconds for login...');
      await page.waitForURL('**microsoft365**' + '|' + '**office.com**' + '|' + '**teams.microsoft.com**' + '|' + '**outlook.office.com**', 
        { timeout: 60000 }).catch(() => {});
    }

    // Demo-specific setup steps
    await runDemoSetup(page, tab.id, pw);

    console.log(`\n✅ Demo ready: ${pw.ready_check}`);
    console.log('   Browser will stay open. Close it when done.\n');

    // Keep browser open
    await page.waitForTimeout(999999999).catch(() => {});

  } catch(e) {
    if (e.message.includes('Target page, context or browser has been closed')) {
      console.log('\n👋 Browser closed. Demo done.');
    } else {
      console.error('⚠️ Setup error:', e.message);
    }
  }
}

// ── Demo-specific setup steps ────────────────────────────────────────────────
async function runDemoSetup(page, demoId, pw) {
  switch(demoId) {
    
    case 'outlook':
      // Wait for Outlook to load, try to open Copilot sidebar
      await waitForSelector(page, '[aria-label="Copilot"], [data-tid="app-bar-copilot"], .ms-Icon--CopilotLogo', 5000)
        .then(() => page.click('[aria-label="Copilot"], [data-tid="app-bar-copilot"]').catch(() => {}))
        .catch(() => console.log('   (Copilot sidebar: open manually)'));
      console.log('→ Outlook inbox loaded');
      break;

    case 'teams':
      await page.waitForTimeout(3000);
      // Try to navigate to Copilot in Teams
      await page.goto('https://teams.microsoft.com/_#/conversations/', { timeout: 15000 }).catch(() => {});
      console.log('→ Teams loaded');
      break;

    case 'workiq':
    case 'chat':
      // Copilot Chat — make sure we're on Work tab
      await page.waitForTimeout(2000);
      await waitForSelector(page, '[data-testid="work-tab"], button:has-text("Work")', 5000)
        .then(() => page.click('[data-testid="work-tab"], button:has-text("Work")').catch(() => {}))
        .catch(() => console.log('   (Work tab: select manually)'));
      console.log('→ Copilot Chat ready');
      break;

    case 'word':
    case 'excel':  
    case 'powerpoint':
      await page.waitForTimeout(3000);
      console.log(`→ ${demoId} loading...`);
      // If a demo file is specified, show instructions
      if (pw.file) {
        const filePath = path.join(DEMO_FILES_DIR, pw.file);
        if (fs.existsSync(filePath)) {
          console.log(`📁 Demo file ready: ${filePath}`);
          console.log(`   Upload this file when prompted in the demo.`);
        } else {
          console.log(`⚠️  Demo file not found: ${filePath}`);
          console.log(`   Run install.ps1 to download demo files.`);
        }
      }
      break;

    case 'agentbasic':
    case 'agentpremium':
      await page.waitForTimeout(2000);
      // Try to find Agent Builder button
      await waitForSelector(page, 'button:has-text("Build"), a:has-text("Build an agent")', 5000)
        .then(() => console.log('→ Agent Builder button found'))
        .catch(() => console.log('   (Click "+" or "Agents" → "Build an agent" manually)'));
      break;
  }
}

// ── Helper ────────────────────────────────────────────────────────────────────
async function waitForSelector(page, selector, timeout) {
  return page.waitForSelector(selector, { timeout }).catch(() => { throw new Error('not found'); });
}

// ── Boot ─────────────────────────────────────────────────────────────────────
console.log('🎭 Copilot Demo Setup Agent');
console.log('   Powered by Playwright + content.json\n');
setupDemo().catch(e => {
  console.error('Fatal:', e.message);
  process.exit(1);
});
