#!/usr/bin/env bash
# One-command setup: install VIOS Research Skills and configure the
# Claude Code SessionStart hook for automatic background updates.
# Works on macOS and Linux.
#
# Usage:
#   bash <(curl -fsSL https://raw.githubusercontent.com/vios-s/Vios-Research-Skills/main/install/setup.sh)

set -euo pipefail

REPO="vios-s/Vios-Research-Skills"
SETTINGS="$HOME/.claude/settings.json"

echo "==> Installing VIOS Research Skills..."
npx skills add "$REPO"

echo "==> Configuring Claude Code auto-update hook..."

# Ensure settings.json exists with at least an empty object
if [ ! -f "$SETTINGS" ]; then
  mkdir -p "$(dirname "$SETTINGS")"
  echo '{}' > "$SETTINGS"
fi

# Inject the hook using Python (available wherever Claude Code runs).
# The hook uses a cross-platform Node.js inline script so it also works
# when this settings file is shared with a Windows machine.
python3 - <<'PYEOF'
import json, os, sys

settings_path = os.path.expanduser("~/.claude/settings.json")
hook_cmd = (
    "node -e \"const{spawn}=require('child_process');"
    "spawn('npx',['skills','update','--yes'],"
    "{detached:true,stdio:'ignore',shell:true}).unref()\""
)

with open(settings_path) as f:
    settings = json.load(f)

hooks = settings.setdefault("hooks", {})
session_hooks = hooks.setdefault("SessionStart", [])

already_present = any(
    any(h.get("command") == hook_cmd for h in entry.get("hooks", []))
    for entry in session_hooks
)

if already_present:
    print("  Hook already configured, skipping.")
    sys.exit(0)

session_hooks.append({"hooks": [{"type": "command", "command": hook_cmd}]})

with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")

print("  Hook added to", settings_path)
PYEOF

echo ""
echo "Done! Skills installed and auto-update hook configured."
echo "On every Claude Code session start, skills will update silently in the background."
