# 🚀 Agent Builder — Premium (M365 Copilot)

> ⏱ 12 min — M365 Copilot Lizenz (€30/user/month)
> Alles aus Basic + Firmen-Daten, SharePoint, Actions

```demo
💡 Mit M365 Copilot wird Agent Builder wirklich powerful:
Der Agent kennt EURE Firmen-Daten — live aus SharePoint, OneDrive, Mail, Calendar.
Kein Datei-Upload mehr nötig. Keine stale Kopien. Immer aktuell.

Access: microsoft365.com/chat → Agents → "Build an agent"
(Gleiche UI wie Basic — aber mit viel mehr Knowledge Options)
```

## Teil A — Onboarding-Agent mit Datei-Upload (5 min)

```demo
Zeigen: File Upload als Knowledge Source — der einfachste Einstieg über Basic hinaus.
Szenario: Neue Mitarbeiter fragen täglich dieselben 12 Fragen an die HR-Inbox.
```

### Agent erstellen

```prompt
Build me an Engineering Onboarding Assistant. It should answer questions from new employees about tools, access requests, processes, and company standards. Friendly tone, step-by-step guidance. When it doesn't know something, it should say so and recommend who to contact.
```

### Knowledge: Datei hochladen

```demo
Agent Builder → "Knowledge" → "Upload files" → Engineering_Onboarding_FAQ.docx hochladen
(Datei liegt im Files-Tab des Dashboards)

💬 Say: "Das ist die einfachste Knowledge Source. Eine Datei hochladen —
der Agent weiß alles darin. Nachteil: wenn das Dokument sich ändert, muss man neu hochladen."
```

### Testen

```prompt
I'm a new engineer. I need to submit a PPAP for the first time. Walk me through the process step by step — what do I need, who do I contact, and where do I find the templates?
```

---

## Teil B — Supplier Escalation Agent mit Live SharePoint (7 min)

```demo
PREMIUM: Statt Datei-Upload → Live SharePoint-Verbindung.
Der Agent liest immer die aktuelle Version. Kein Re-Upload. Kein stale content.

Szenario: Einkäufer und Ingenieure eskalieren Lieferanten-Probleme via E-Mail —
inkonsistent, fehlende Felder, falsche Eskalationsstufe.
```

### Agent erstellen

```prompt
Build a Supplier Escalation Agent for our procurement and quality team. When someone reports a supplier issue, the agent should:
1. Collect: supplier name, part number, production impact (Y/N), defect description
2. Determine escalation level: L1 (single issue <5% defect), L2 (repeat or line impact), L3 (stop/recall/legal)
3. Draft a structured escalation email in the right format
4. Suggest 3 next actions

Step-by-step, professional tone. Don't ask for all info at once.
```

### Knowledge: Live SharePoint verbinden

```demo
Agent Builder → "Knowledge" → "SharePoint" → SharePoint-URL eingeben

💬 Say: "Das ist der Game Changer. Kein Datei-Upload — direkter Zugriff auf 
die Live-Daten in SharePoint. Spec-Änderung gestern eingespielt? Agent weiß's heute."
```

### Testen: Realer Eskalations-Fall

```prompt
I have a quality issue. Supplier Fabrikam AG, part BSM-400-R3, we're seeing 3.8% defect rate. 500 units affected. Our Plant B assembly line can keep running for 4 more hours then we stop. What should I do?
```

### Testen: Agent erkennt Eskalationslevel

```demo
Agent soll L2 erkennen (Repeat + Line Impact <4h) und passende E-Mail-Vorlage nutzen.
Zeigen: strukturierte Eskalations-E-Mail mit allen Pflichtfeldern automatisch befüllt.
```

## Teil C — Actions (Copilot Studio, 2 min Konzept)

```demo
Für echte Power-User: Actions via Copilot Studio.
Der Agent tut nicht nur Antworten geben — er HANDELT.

Beispiele:
• NCR direkt im Qualitätssystem anlegen
• Eskalations-E-Mail automatisch absenden
• Power Automate Flow triggern
• SAP-Daten abfragen

Copilot Studio öffnen (copilotstudio.microsoft.com)
→ Agent → "Tools" → "Add tool" → Connector auswählen

💬 Say: "Das ist der Übergang vom AI Assistant zum AI Worker.
Der Agent schreibt die E-Mail nicht nur — er schickt sie ab, 
loggt sie, und updated den Tracker. Ohne dass der Nutzer etwas copy-pasten muss."
```

## Basic vs. Premium — Vergleich

```demo
BASIC (kein PayGo, kostenlos):
✅ Agent Builder nutzbar
✅ Web Search als Knowledge
✅ Teilen via Link
❌ Keine Firmendaten
❌ Kein File Upload
❌ Kein SharePoint
❌ Keine Actions

PREMIUM (M365 Copilot, €30/user/month):
✅ File Upload als Knowledge ← neu
✅ Live SharePoint + OneDrive ← neu
✅ Mail, Calendar, Meetings des Users ← neu
✅ Graph Connectors (SAP, Salesforce, 600+) ← neu
✅ Actions via Copilot Studio ← neu
✅ Org-weite Verteilung ← neu
✅ Priority Access zu Modellen ← neu

💬 Closing: "Basic zeigt was möglich ist. Premium zeigt was es bedeutet.
Für einen Nutzer, der täglich 30 Minuten mit manuellen Eskalations-E-Mails verbringt: 
ROI in der ersten Woche."
```
