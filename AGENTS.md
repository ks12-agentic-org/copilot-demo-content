# AGENTS.md — Copilot Demo Content Repo

**Repo:** `ks12-agentic-org/copilot-demo-content`
**Live Dashboard:** https://agent-ui.jens-lab.com/projects/copilot-demo/
**Owner:** Jens Schneider (jens.schneider@bluepolicy.de)

---

## ⚠️ THREE NON-NEGOTIABLE RULES

### 1. 🌐 ALWAYS ENGLISH — NO EXCEPTIONS
Every prompt, demo instruction, file content, and UI text must be in **English only**.
No German. No bilingual. No `<span class="de">`. English everywhere, always.

### 2. 🏢 ALWAYS NEUTRAL — NO CUSTOMER NAMES
Use **only official Microsoft Fictitious Companies** (see [DEMO_COMPANIES.md](DEMO_COMPANIES.md)).
- ✅ Contoso Manufacturing, Fabrikam AG, Northwind Industries, Tailwind Traders
- ❌ LEONI, BMW, Volkswagen, real company names of any kind
- ❌ Real locations, real people, real products that identify a customer

### 3. 🔍 MICROSOFT LEARN MCP IS YOUR FIRST SOURCE
Before writing **any** Copilot feature description, availability, or licensing claim:
**Search Microsoft Learn via MCP first.** No guessing. No training data.

MCP server: `microsoft-learn` → `https://learn.microsoft.com/api/mcp`
Tools: `microsoft_docs_search`, `microsoft_docs_fetch`, `microsoft_code_sample_search`

Example: Before writing "Copilot in Outlook can do X" → search `microsoft_docs_search("Copilot Outlook features 2026")`.

---

## Repo Structure

```
promptprompter/   → PromptPrompter MDs (01–13, numbered, English only)
files/            → Demo documents (DOCX, XLSX — Contoso/Fabrikam/Northwind names only)
dashboard/        → HTML Dashboard → deployed to Azure VM
DEMO_COMPANIES.md → Full reference for all MS fictitious companies
install.ps1       → One-liner setup for CDX Demo VMs
.github/          → CI/CD workflows
```

---

## Content Rules

### Naming Convention
```
promptprompter/  → NN_TabName.md   (e.g. 06_Outlook.md)
files/           → Generic_[Description].docx / .xlsx
                   Or: Contoso_[Description].docx, Fabrikam_[Description].docx
```

### PromptPrompter MD Format
```markdown
# 📧 Tab Title

> ⏱ X min

` ``demo
Presenter instruction (displayed, not copied)
` ``

## Step Title

` ``prompt
The actual prompt — copied on click
` ``
```

### Demo File Quality Check
Before every commit, verify:
- English only in all file content
- Only Contoso / Fabrikam / Northwind / Tailwind / Woodgrove as company names
- No real prices, contracts, personal data
- No customer-identifiable information

---

## CDX Demo Tenant

**Tenant:** m365cpi98544940.onmicrosoft.com

| User | UPN | VM | IP | Copilot | Role |
|---|---|---|---|---|---|
| MOD Administrator | admin@M365CPI98544940.onmicrosoft.com | TC-Admin | 10.1.1.10 | ✓ | Admin |
| **Leila Goncalves** | LeilaG@M365CPI98544940.onmicrosoft.com | TC-Leila | 10.1.1.19 | ✓ | **Primary Demo User** |
| Preston Morales | PrestonM@M365CPI98544940.onmicrosoft.com | TC-Preston | 10.1.1.20 | ✓ | Demo User |
| Selma Nyberg | SelmaN@M365CPI98544940.onmicrosoft.com | TC-Selma | 10.1.1.18 | ✗ | Chat only (before/after) |
| Jens | jens@M365CPI98544940.onmicrosoft.com | TC-Jens | 10.1.1.11 | ✗ | ⚠️ NOT for demo! |

**Licenses:** Leila + Preston + Admin = M365 E5 + Copilot. Selma = no Copilot.

---

## Install Demo Files on VMs

### One-liner (PowerShell — run on any CDX VM):
```powershell
irm https://raw.githubusercontent.com/ks12-agentic-org/copilot-demo-content/main/install.ps1 | iex
```
→ Installs to OneDrive (or Desktop), creates shortcut, always pulls latest from main.

---

## Demo Companies
See [DEMO_COMPANIES.md](DEMO_COMPANIES.md) for full profiles.
Short: **Contoso Manufacturing** = primary customer, **Fabrikam AG** = new customer/RFQ, **Northwind** = existing account, **Tailwind** = supplier.

---

## Current Demo Tabs

| # | File | Content | Duration |
|---|---|---|---|
| 01 | RunOfShow.md | 75-min timeline + intro pitch | — |
| 03 | WhatsNew.md | New Copilot features | — |
| 04 | WorkIQ.md | Day-1 demo: inbox, calendar, cross-app | 10 min |
| 05 | CopilotChat.md | Free-tier demo (no M365 Copilot) | 5 min |
| 06 | Outlook.md | Inbox triage, thread summary, draft | 10 min |
| 07 | Teams.md | Meeting recap, Q&A from transcript | 8 min |
| 08 | Word.md | Meeting notes → report, rewrite | 4 min |
| 09 | Excel.md | KPI Plan Mode, pipeline analysis | 5 min |
| 10 | PowerPoint.md | Create from doc, GPT-Image, web | 10 min |
| 11 | QA.md | 7 common questions + answers | — |
| 12 | AgentBuilder_Basic.md | No PayGo: web search only | 6 min |
| 13 | AgentBuilder_Premium.md | M365 Copilot: file upload + SharePoint | 12 min |

---

## Cron Job (runs every 15 min)
`/home/jens/.openclaw/workspace/bin/demo-refresh.sh`
- Checks for new Copilot features via **Microsoft Learn MCP**
- Improves dashboard quality
- Deploys to Azure VM
- Log: `/tmp/demo-refresh.log`

## Deployment
```bash
# Manual deploy from workspace
bin/deploy-to-azure projects/copilot-demo/index.html copilot-demo/index.html
```
