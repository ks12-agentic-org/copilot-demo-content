#!/usr/bin/env python3
"""
features_update.py — Nightly update of features.json
Sources:
  1. MS Release Notes page (web_fetch)
  2. MS Tech Community Copilot Blog RSS
  3. M365 Roadmap API (JSON)

Rules:
  - Microsoft Learn MCP is first source
  - English only
  - No customer-specific content
  - Status: GA | Preview | Frontier | Roadmap
"""

import sys, json, re, datetime, subprocess, os, urllib.request, hashlib

TODAY = sys.argv[1] if len(sys.argv) > 1 else datetime.date.today().isoformat()
WORKSPACE = "/home/jens/.openclaw/workspace"
FEATURES_FILE = f"{WORKSPACE}/projects/copilot-demo/features.json"
LOG_FILE = "/tmp/features-update.log"

SOURCES = {
    "release_notes": "https://learn.microsoft.com/en-us/microsoft-365/copilot/release-notes",
    "roadmap_api": "https://www.microsoft.com/en-us/microsoft-365/roadmap?Filters=Microsoft%20Copilot%20(Microsoft%20365)&output=json",
    "blog_rss": "https://techcommunity.microsoft.com/plugins/custom/microsoft/o365/custom-blog-rss?tid=3&board=microsoft365copilotblog&category=Microsoft%20365%20Copilot",
}

def log(msg):
    print(f"  {msg}")

def fetch_url(url, timeout=15):
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 OpenClaw/features-update"})
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return r.read().decode("utf-8", errors="ignore")
    except Exception as e:
        log(f"⚠️  fetch failed ({url[:60]}): {e}")
        return ""

def fetch_release_notes():
    """Parse MS Release Notes page for new features"""
    content = fetch_url(SOURCES["release_notes"])
    if not content:
        return []
    
    features = []
    # Find dated sections (## Month DD, YYYY)
    sections = re.split(r'##\s+((?:January|February|March|April|May|June|July|August|September|October|November|December)\s+\d+,\s+\d{4})', content)
    
    for i in range(1, min(len(sections), 5)):  # Process last 2 dated sections
        date_str = sections[i]
        body = sections[i+1] if i+1 < len(sections) else ""
        
        # Parse year-month from date
        try:
            d = datetime.datetime.strptime(date_str.strip(), "%B %d, %Y")
            release_month = d.strftime("%Y-%m")
        except:
            release_month = TODAY[:7]
        
        # Extract feature entries (### heading + description)
        feat_sections = re.split(r'\n###\s+', body)
        for feat in feat_sections[1:]:
            lines = feat.strip().split('\n')
            if not lines:
                continue
            title = lines[0].strip()
            if not title or len(title) < 10:
                continue
            
            # Get app context from parent heading
            app = "M365 Copilot"
            
            # Extract description (first paragraph after title)
            desc_lines = []
            for line in lines[1:]:
                line = line.strip()
                if line.startswith('**') or line.startswith('-') or not line:
                    if desc_lines:
                        break
                    continue
                desc_lines.append(line)
            desc = ' '.join(desc_lines[:3])
            
            if not desc:
                desc = title
            
            feat_id = "f" + hashlib.md5(title.encode()).hexdigest()[:6]
            features.append({
                "id": feat_id,
                "title": title,
                "app": [app],
                "platforms": [],
                "status": "GA",
                "released": release_month,
                "tier": "M365 Copilot",
                "description": desc[:300],
                "demo_angle": "",
                "source": SOURCES["release_notes"]
            })
    
    return features

def fetch_blog_posts():
    """Parse Tech Community Blog for recent announcements"""
    content = fetch_url(SOURCES["blog_rss"])
    if not content:
        # Fallback: scrape the blog page
        content = fetch_url("https://techcommunity.microsoft.com/category/microsoft365copilot/blog/microsoft365copilotblog")
    if not content:
        return []
    
    posts = []
    # Find blog post titles and dates
    for m in re.finditer(r'"?([\w\s\-–:,.\']+(?:Copilot|Agent|AI|GPT|Frontier)[^\n"]{5,80})"?\s*\n.*?(\w+ \d+, \d{4})', content, re.DOTALL):
        title = m.group(1).strip()
        date_str = m.group(2).strip()
        if len(title) > 15 and 'Copilot' in title or 'Agent' in title:
            posts.append({"title": title, "date": date_str})
    
    return posts[:5]

def merge_features(existing_features, new_features):
    """Merge new features into existing, avoiding duplicates"""
    existing_titles = {f['title'].lower().strip() for f in existing_features}
    existing_ids = {f['id'] for f in existing_features}
    
    added = 0
    for feat in new_features:
        title_clean = feat['title'].lower().strip()
        if title_clean not in existing_titles and feat['id'] not in existing_ids:
            existing_features.append(feat)
            existing_titles.add(title_clean)
            added += 1
            log(f"  ➕ Added: {feat['title'][:60]}")
    
    return existing_features, added

def main():
    # Load existing features
    try:
        with open(FEATURES_FILE) as f:
            data = json.load(f)
    except Exception as e:
        log(f"⚠️  Could not load features.json: {e}")
        return 1
    
    existing = data.get("features", [])
    log(f"Existing features: {len(existing)}")
    
    # Fetch new features from Release Notes
    log("Fetching MS Release Notes...")
    new_from_rn = fetch_release_notes()
    log(f"  Found {len(new_from_rn)} features in release notes")
    
    # Merge
    existing, added_rn = merge_features(existing, new_from_rn)
    
    # Update metadata
    data["features"] = existing
    data["meta"]["updated"] = TODAY
    data["meta"]["last_run"] = f"{TODAY} (nightly cron)"
    data["meta"]["total_features"] = len(existing)
    
    # Save
    with open(FEATURES_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    
    log(f"✅ features.json: {len(existing)} features total, +{added_rn} new")
    
    # Log summary
    with open(LOG_FILE, 'a') as lf:
        lf.write(f"[{TODAY}] features_update: {len(existing)} total, +{added_rn} new from release notes\n")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
