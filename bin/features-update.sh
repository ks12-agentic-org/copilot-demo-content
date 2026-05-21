#!/usr/bin/env bash
# features-update.sh — Nightly: Update features.json from MS Learn + Tech Community Blog
# Cron: 0 2 * * * /home/jens/.openclaw/workspace/bin/features-update.sh >> /tmp/features-update.log 2>&1

WORKSPACE="/home/jens/.openclaw/workspace"
REPO_DIR="/tmp/copilot-demo-content"
NOW=$(date -u '+%Y-%m-%d %H:%M UTC')
TODAY=$(date -u '+%Y-%m-%d')
GH_TOKEN=$(op read "op://OpenClaw/ptmkg2if5rwh6u7qgmlkdmp4im/Token" 2>/dev/null)

echo ""
echo "=== [$NOW] Features Update ==="

cd "$WORKSPACE"

# Run Python updater
python3 "$WORKSPACE/bin/features_update.py" "$TODAY" 2>&1
STATUS=$?

if [ $STATUS -eq 0 ]; then
  echo "[$NOW] ✅ features.json updated"
  
  # Deploy to Azure VM
  bin/deploy-to-azure projects/copilot-demo/features.json copilot-demo/features.json 2>&1
  
  # Push to GitHub
  if [ -n "$GH_TOKEN" ] && [ -d "$REPO_DIR" ]; then
    cd "$REPO_DIR"
    cp "$WORKSPACE/projects/copilot-demo/features.json" ./features.json
    git add features.json
    git diff --staged --quiet || git commit -m "chore: nightly features update [$TODAY]" && git push origin main 2>&1
    echo "[$NOW] ✅ GitHub pushed"
  fi
else
  echo "[$NOW] ⚠️  features_update.py exited with $STATUS"
fi

echo "=== [$NOW] Features Update COMPLETE ==="
