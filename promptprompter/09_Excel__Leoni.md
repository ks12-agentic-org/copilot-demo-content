# 📊 Copilot in Excel

> ⏱ 5 min — M365 Copilot Lizenz
> Files: Generic_Plant_KPI_Data.xlsx · Generic_Q2_Pipeline_Tracker.xlsx

```demo
5 min. Zwei Demos: KPI-Analyse mit Plan Mode + Pipeline-Analyse.
Kernbotschaft: Daten verstehen ohne Formeln — einfach fragen.
```

## Demo 1 — KPI Data: Plan Mode + Analyse (0:52–0:55)

```demo
File: Generic_Plant_KPI_Data.xlsx — Produktionsdaten aus 5 Werken (Output, Defektrate, OTD).

NEU: Plan Mode (Mai 2026) — Copilot zeigt erst was es tun wird, bevor es handelt.
Das ist das "wow"-Moment: KI die transparent vorgeht statt einfach drauflos zu ändern.

Schritt: Excel öffnen → Datei hochladen → Copilot → Plan Mode aktivieren → Prompt.
```

### Plant KPIs analysieren — Plan Mode

```prompt
[Upload: Generic_Plant_KPI_Data.xlsx]

Use Plan mode: first show me what you're going to do before making any changes. Then:
1. Identify which plants are underperforming on defect rate (target: <0.5%) — highlight them red
2. Identify which plants are below OTD target (98%) — highlight them orange  
3. Add a summary row at the bottom with averages for all numeric columns
4. Calculate the financial impact of Plant A's 1.8% defect rate (€385 unit cost × 8,412 units)
```

### Follow-up: Management Dashboard erstellen

```demo
Direkt anschließend — kein neues File öffnen. Copilot baut auf der vorherigen Analyse auf.
```

```prompt
Now create a management dashboard on a new sheet called "Dashboard":
- A bar chart comparing OTD % across all 5 plants (target line at 98%)
- A second chart showing defect rates vs. target
- A 3-sentence written summary I can copy into my Friday management report

Chart title: "Plant Operations — W20/2026 Performance Overview"
```

---

## Demo 2 — Pipeline Tracker: Analyse + Forecast (0:55–0:57)

```demo
File: Generic_Q2_Pipeline_Tracker.xlsx — Q2 Sales Pipeline mit 5 Deals, Stages, Wahrscheinlichkeiten.

Zeigen: Copilot versteht Business-Kontext ohne Erklärung.
```

### Pipeline analysieren

```prompt
[Upload: Generic_Q2_Pipeline_Tracker.xlsx]

Analyze this Q2 sales pipeline:
1. What is the total weighted pipeline value?
2. Which 2 deals have the highest risk of slipping out of Q2?
3. If we improve the Fabrikam AG close probability from 55% to 75%, what happens to the total weighted value?
4. Create a mini heat map: color deals green (>60% probability), yellow (40-60%), red (<40%)
```

### Executive Summary aus den Daten

```prompt
Write a 4-sentence Q2 pipeline status update for the sales review meeting. Include: total pipeline, weighted forecast, top risk, and recommended action. Confident, data-driven tone.
```

---

## Was Copilot in Excel kann

```demo
✅ Plan Mode (NEU Mai 2026) — zeigt Plan vor Ausführung
✅ Daten analysieren in natürlicher Sprache — keine Formeln nötig
✅ Conditional Formatting per Prompt
✅ Charts und Dashboards generieren
✅ Berechnungen auf Basis eigener Daten
✅ Geschäftliche Zusammenfassungen aus Tabellendaten
→ Spart 45-90 Minuten für wöchentliche KPI-Reports
```
