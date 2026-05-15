#!/usr/bin/env bash
# One-command setup: install VIOS Research Skills and configure the
# Claude Code SessionStart hook for automatic background updates.
# Works on macOS and Linux. If Node.js/npx is missing, this script installs
# Node.js LTS through nvm first.
#
# Usage:
#   bash <(curl -fsSL https://raw.githubusercontent.com/vios-s/Vios-Research-Skills/main/install/setup.sh)

set -euo pipefail

REPO="vios-s/Vios-Research-Skills"
SETTINGS="$HOME/.claude/settings.json"
NVM_VERSION="v0.40.1"
NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

profile_file() {
  if [ -n "${PROFILE:-}" ]; then
    echo "$PROFILE"
    return
  fi

  case "${SHELL:-}" in
    */zsh) echo "$HOME/.zshrc" ;;
    */bash) echo "$HOME/.bashrc" ;;
    *) echo "$HOME/.profile" ;;
  esac
}

load_nvm() {
  export NVM_DIR
  if [ -s "$NVM_DIR/nvm.sh" ]; then
    # shellcheck disable=SC1091
    . "$NVM_DIR/nvm.sh"
  fi
}

has_node_tools() {
  command -v node >/dev/null 2>&1 && command -v npx >/dev/null 2>&1
}

ensure_profile_loads_nvm() {
  local profile
  profile="$(profile_file)"
  mkdir -p "$(dirname "$profile")"
  touch "$profile"

  # shellcheck disable=SC2016 -- intentional: checking for literal string, not expansion
  if ! grep -qs 'NVM_DIR="$HOME/.nvm"' "$profile"; then
    cat >> "$profile" <<'EOF'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
EOF
  fi
}

install_nvm() {
  if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl is required to install Node.js automatically." >&2
    echo "Please install Node.js LTS from https://nodejs.org/ and rerun this script." >&2
    exit 1
  fi

  echo "==> Installing nvm so Node.js can be managed without admin rights..."
  curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" | PROFILE="$(profile_file)" bash
  ensure_profile_loads_nvm
  load_nvm
}

ensure_node() {
  if has_node_tools; then
    return
  fi

  load_nvm
  if has_node_tools; then
    return
  fi

  if ! command -v nvm >/dev/null 2>&1; then
    install_nvm
  fi

  if ! command -v nvm >/dev/null 2>&1; then
    echo "Error: nvm installation completed, but nvm is not available in this shell." >&2
    echo "Open a new terminal or install Node.js LTS from https://nodejs.org/, then rerun this script." >&2
    exit 1
  fi

  echo "==> Installing Node.js LTS..."
  nvm install --lts
  nvm use --lts
  nvm alias default 'lts/*' >/dev/null

  if ! has_node_tools; then
    echo "Error: Node.js was installed, but node and npx are not both available." >&2
    echo "Open a new terminal and rerun this script." >&2
    exit 1
  fi
}

ensure_node

echo "==> Installing VIOS Research Skills..."
npx skills add "$REPO"

echo "==> Configuring Claude Code auto-update hook..."

# Ensure settings.json exists with at least an empty object
if [ ! -f "$SETTINGS" ]; then
  mkdir -p "$(dirname "$SETTINGS")"
  echo '{}' > "$SETTINGS"
fi

# Inject the hook using Node.js, which this script has already verified.
# The hook uses a cross-platform Node.js inline script so it also works
# when this settings file is shared with a Windows machine.
node <<'NODEEOF'
const fs = require('fs');
const os = require('os');
const path = require('path');

const settingsPath = path.join(os.homedir(), '.claude', 'settings.json');
const hookCmd = "node -e \"const{spawn}=require('child_process');spawn('npx',['skills','update','--yes'],{detached:true,stdio:'ignore',shell:true}).unref()\"";

let settings = {};
try {
  settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));
} catch (error) {
  if (error.code !== 'ENOENT') {
    throw new Error('Could not parse ' + settingsPath + ': ' + error.message);
  }
}

if (!settings || typeof settings !== 'object' || Array.isArray(settings)) {
  settings = {};
}
if (!settings.hooks || typeof settings.hooks !== 'object' || Array.isArray(settings.hooks)) {
  settings.hooks = {};
}
if (!Array.isArray(settings.hooks.SessionStart)) {
  settings.hooks.SessionStart = [];
}

const alreadyPresent = settings.hooks.SessionStart.some((entry) =>
  Array.isArray(entry.hooks) &&
  entry.hooks.some((hook) => hook.command === hookCmd)
);

if (alreadyPresent) {
  console.log('  Hook already configured, skipping.');
  process.exit(0);
}

settings.hooks.SessionStart.push({
  hooks: [{ type: 'command', command: hookCmd }],
});

fs.mkdirSync(path.dirname(settingsPath), { recursive: true });
fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2) + '\n');
console.log('  Hook added to ' + settingsPath);
NODEEOF

echo ""
echo "Done! Skills installed and auto-update hook configured."
echo "On every Claude Code session start, skills will update silently in the background."
