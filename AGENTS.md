# AGENTS.md — Copilot Demo Content Repo

**Repo:** `ks12-agentic-org/copilot-demo-content`
**Live Dashboard:** https://agent-ui.jens-lab.com/projects/leoni-copilot-demo/
**Owner:** Jens Schneider (jens.schneider@bluepolicy.de)

---

## Was ist dieses Repo?

Dieses Repo enthält alle Inhalte für Microsoft Copilot Demos:

```
promptprompter/   → PromptPrompter App MDs (ein File pro Demo-Tab, nummeriert)
files/            → Demo-Dateien (DOCX, XLSX — neutrale Beispiel-Inhalte)
dashboard/        → HTML Dashboard (deployed auf Azure VM)
.github/workflows → CI/CD: Push → Azure VM Deploy
```

---

## Regeln für Agents (PFLICHT lesen!)

### 1. ALLES muss 100% neutral sein
- **Keine Kundennamen** in Prompts, Dokumenten, oder Demo-Skripten
- **Keine echten Firmennamen** außer generischen Platzhaltern: `Contoso Ltd.`, `Fabrikam AG`, `Northwind Corp.`, `Alpine Systems`
- **Keine Branchen-Spezifika** die einen Kunden identifizieren könnten
- Einzige Ausnahme: `promptprompter/02_LEONIContext__Leoni.md` → darf LEONI-spezifisch bleiben (Tab wird pro Kunde ausgetauscht)

### 2. Dateinamen-Konvention
```
promptprompter/  → NN_TabName__[Kunde].md   (z.B. 06_Outlook__Leoni.md)
files/           → Generic_[Beschreibung].docx / .xlsx
                   Engineering_[Beschreibung].docx für Engineering-spezifische Docs
```

### 3. PromptPrompter MD Format
```markdown
# 📧 Tab Title

> ⏱ X min — optional Hinweis

```demo
Presenter-Instruktion (wird angezeigt, nicht kopiert)
```

## Schritt-Titel (Zeitstempel optional)

```demo
Setup-Anweisung, was der Presenter tun soll
```

### Hint (optional — erscheint als Schritt-Label)

```prompt
Der eigentliche Prompt — wird per Klick kopiert
```
```

### 4. Demo-File Qualitäts-Check
Vor jedem Commit prüfen:
- Keine echten Kundennamen im Dokument-Inhalt
- Keine internen Preise, vertragliche Details, echte Personen
- Fiktive Firmen: Contoso, Fabrikam, Northwind, Alpine Systems, Global Tech GmbH

### 5. Commit & Push Workflow
```bash
cd /tmp/copilot-demo-content
git add -A
git commit -m "feat: [was geändert] — [Grund]"
git push origin main
```
→ GitHub Action deployed automatisch zu Azure VM
→ PromptPrompter ZIP wird automatisch neu gebaut

### 6. Neue Demo-Tab hinzufügen
1. Neue MD-Datei anlegen: `promptprompter/NN_TabName__[Kunde].md`
2. Nächste Nummer in der Sequenz verwenden
3. Bei neuem Demo-File: `files/Generic_[Name].docx` oder `.xlsx`
4. `README.md` → Tabelle "Demo-Tabs" aktualisieren

---

## Aktueller Stand — Demo-Tabs (Leoni)

| Nr | Datei | Inhalt | Duration |
|---|---|---|---|
| 01 | RunOfShow | 75-Min Timeline + Intro-Pitch | — |
| 02 | LEONIContext | Firmenprofil, Personas, Talking Points | — |
| 03 | WhatsNew | Neue Copilot Features (April 2026) | — |
| 04 | WorkIQ | Day-1-Demo: Inbox, Kalender, Cross-App | 10 min |
| 05 | CopilotChat | Free-Tier Demo (kein M365 Copilot) | 5 min |
| 06 | Outlook | Inbox Triage, Thread Summary, Draft | 10 min |
| 07 | Teams | Meeting Recap, Q&A aus Transkript | 8 min |
| 08 | Word | Meeting Notes → Report, Rewrite | 4 min |
| 09 | Excel | KPI Plan Mode, Pipeline-Analyse | 5 min |
| 10 | PowerPoint | Create from Doc, GPT-Image, Web | 10 min |
| 11 | QA | 7 häufige Fragen + Antworten | — |
| 12 | AgentBuilder_Basic | Ohne PayGo: nur Web Search | 6 min |
| 13 | AgentBuilder_Premium | M365 Copilot: File Upload + SharePoint | 12 min |

---

## Demo-Files

| File | Wofür |
|---|---|
| `Generic_Q2_Sales_Pipeline.docx` | Chat + PPT Demo |
| `Generic_Engineering_Meeting_Notes.docx` | allgemein |
| `Generic_RFQ_Response.docx` | Outlook Demo 3 |
| `Generic_Weekly_Operations_Status.docx` | Excel Demo |
| `Generic_EV_Component_Comparison.docx` | PPT/Chat |
| `Generic_Product_Brief.docx` | PPT Demo 1 + Word Demo 2 |
| `Generic_Meeting_Notes.docx` | Word Demo (Copilot Chat) |
| `Contoso_Account_Brief.docx` | Work IQ Demo |
| `Fabrikam_Weekly_Status.docx` | Work IQ Demo |
| `Engineering_Meeting_Notes_Raw.docx` | Word Demo 1 (chaotische Notizen) |
| `Engineering_Onboarding_FAQ.docx` | Agent Builder Premium Demo |
| `Agent_Quick_Reference.docx` | Agent Builder Referenz |
| `Product_Spec_BSM400.docx` | technische Spec Demo |
| `Generic_Plant_KPI_Data.xlsx` | Excel Demo 1 |
| `Generic_Q2_Pipeline_Tracker.xlsx` | Excel Demo 2 |

---

## Deployment

### Azure VM (manuell)
```bash
bin/deploy-to-azure projects/leoni-copilot-demo/index.html leoni-copilot-demo/index.html
```

### GitHub Action (automatisch bei Push)
→ Siehe `.github/workflows/deploy.yml`

---

## Cron-Job (läuft alle 15 Min)
`/home/jens/.openclaw/workspace/bin/demo-refresh.sh`
- Prüft auf neue Copilot-Features
- Verbessert Dashboard-Qualität
- Deployed zu Azure VM
- Schreibt Log: `/tmp/demo-refresh.log`

---

## CDX Demo Tenant

**Tenant:** m365cpi98544940.onmicrosoft.com

| User | UPN | VM | IP | Copilot | Rolle |
|---|---|---|---|---|---|
| MOD Administrator | admin@M365CPI98544940.onmicrosoft.com | TC-Admin | 10.1.1.10 | ✓ | Admin |
| **Leila Goncalves** | LeilaG@M365CPI98544940.onmicrosoft.com | TC-Leila | 10.1.1.19 | ✓ | **Primärer Demo-User** |
| Preston Morales | PrestonM@M365CPI98544940.onmicrosoft.com | TC-Preston | 10.1.1.20 | ✓ | Demo-User |
| Selma Nyberg | SelmaN@M365CPI98544940.onmicrosoft.com | TC-Selma | 10.1.1.18 | ✗ | Chat only (Vorher/Nachher) |
| Jens | jens@M365CPI98544940.onmicrosoft.com | TC-Jens | 10.1.1.11 | ✗ | ⚠️ NICHT für Demo! |

**Lizenzen:** Leila + Preston + Admin = M365 E5 + Copilot. Selma = kein Copilot.

---

## Demo Files auf VMs installieren

### One-Liner (PowerShell, auf jeder Demo-VM ausführen):

```powershell
irm https://raw.githubusercontent.com/ks12-agentic-org/copilot-demo-content/main/install.ps1 | iex
```

**Was das Script macht:**
- Lädt alle Demo-Files aus GitHub (immer aktuelle Version)
- Installiert nach OneDrive (wenn vorhanden) oder Desktop
- Erstellt Desktop-Shortcut "Copilot Demo Files"
- Kopiert auch PromptPrompter MDs in Unterordner

**Empfohlene Demo-VM:** TC-Leila (LeilaG, hat Copilot-Lizenz)
