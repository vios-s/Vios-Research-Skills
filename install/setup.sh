#!/usr/bin/env bash
# One-command setup: install VIOS Research Skills globally for Claude Code,
# Codex, Gemini CLI, Cursor, GitHub Copilot and OpenCode, and configure the
# Claude Code SessionStart hook for automatic background updates.
# Works on macOS and Linux. If Node.js/npx is missing or older than the
# `skills` CLI needs (22.20+), this script installs Node.js LTS through nvm first.
#
# Usage:
#   bash <(curl -fsSL https://raw.githubusercontent.com/vios-s/Vios-Research-Skills/main/install/setup.sh)

set -euo pipefail

REPO="vios-s/Vios-Research-Skills"
# Agent ids understood by the `skills` CLI (https://github.com/vercel-labs/skills).
AGENTS=(claude-code codex gemini-cli antigravity-cli cursor github-copilot opencode)
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
    set +u  # nvm.sh uses unbound variables internally; restore after sourcing
    # shellcheck disable=SC1091
    . "$NVM_DIR/nvm.sh"
    set -u
  fi
}

# The `skills` CLI needs Node.js >= 22.20 (it imports `glob` from fs/promises).
has_node_tools() {
  command -v node >/dev/null 2>&1 && command -v npx >/dev/null 2>&1 &&
    node -e 'const [a, b] = process.versions.node.split(".").map(Number); process.exit(a > 22 || (a === 22 && b >= 20) ? 0 : 1)'
}

ensure_profile_loads_nvm() {
  local profile
  profile="$(profile_file)"
  mkdir -p "$(dirname "$profile")"
  touch "$profile"

  # Intentional: checking for the literal string $HOME/.nvm, not an expansion.
  # shellcheck disable=SC2016
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
  set +u  # nvm shell functions use unbound variables internally
  nvm install --lts
  nvm use --lts
  nvm alias default 'lts/*' >/dev/null
  set -u

  if ! has_node_tools; then
    echo "Error: Node.js LTS was installed, but node >= 22.20 and npx are not both available." >&2
    echo "Open a new terminal and rerun this script." >&2
    exit 1
  fi
}

ensure_node

echo "==> Installing VIOS Research Skills..."
# -g: user-level install (not just this directory); -y + --skill '*': no prompts.
npx --yes skills add "$REPO" -g -y --skill '*' -a "${AGENTS[@]}"

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
const hookCmd = "node -e \"const{spawn}=require('child_process');spawn('npx',['--yes','skills','update','-g','-y'],{detached:true,stdio:'ignore',shell:true}).unref()\"";

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

// Drop any earlier version of this hook (e.g. the old project-scoped
// `skills update --yes`) so re-running setup upgrades it in place.
const isOurs = (hook) =>
  typeof hook.command === 'string' && hook.command.includes("'skills','update'");
settings.hooks.SessionStart = settings.hooks.SessionStart
  .map((entry) => (Array.isArray(entry.hooks)
    ? { ...entry, hooks: entry.hooks.filter((hook) => !isOurs(hook)) }
    : entry))
  .filter((entry) => !Array.isArray(entry.hooks) || entry.hooks.length > 0);

settings.hooks.SessionStart.push({
  matcher: 'startup',
  hooks: [{ type: 'command', command: hookCmd }],
});

fs.mkdirSync(path.dirname(settingsPath), { recursive: true });
fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2) + '\n');
console.log('  Hook added to ' + settingsPath);
NODEEOF

echo ""
echo "Done! Skills installed for: ${AGENTS[*]}"
echo "On every new Claude Code session, skills update silently in the background."
echo "Other clients: run 'npx skills update -g -y' to update by hand."
