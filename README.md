# Vios Research Skills

A curated library of [Agent Skills](https://github.com/vios-s/Vios-Research-Skills) for AI, causality, and medical-imaging research, maintained by the [VIOS Lab](https://vios.science/) at the University of Edinburgh.

Each skill is a self-contained `SKILL.md` that any Agent-Skills-compatible client — Claude Code, Cursor, Codex, Gemini CLI — can install and invoke.

## Install

```bash
npx skills add vios-s/Vios-Research-Skills
```

## Auto-update

Run once to keep skills current every time you start Claude Code:

**macOS / Linux**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/vios-s/Vios-Research-Skills/main/install/setup.sh)
```

**Windows (PowerShell)**
```powershell
irm https://raw.githubusercontent.com/vios-s/Vios-Research-Skills/main/install/setup.ps1 | iex
```

Both scripts install the skills and add a Claude Code `SessionStart` hook that runs `npx skills update` silently in the background on every session start. The hook uses a cross-platform Node.js call, so it works on macOS, Linux, and Windows without modification.

To configure the hook manually, copy [`install/claude-code-hook.json`](./install/claude-code-hook.json) into your `~/.claude/settings.json`.

## Browse

Human-readable previews and editable docs live at the GitBook site: *(URL to be added after GitBook Git Sync is configured)*.

## Contribute

See [`CONTRIBUTING.md`](./CONTRIBUTING.md) for the SKILL.md template, frontmatter conventions, and PR process.

## License

MIT, see [`LICENSE`](./LICENSE). Individual skills may carry their own license — check each skill's frontmatter.
