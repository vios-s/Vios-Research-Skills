# Vios Research Skills

A curated library of [Agent Skills](https://github.com/vios-s/Vios-Research-Skills) for AI, causality, and medical-imaging research, maintained by the [VIOS Lab](https://vios.science/) at the University of Edinburgh.

Each skill is a self-contained `SKILL.md` that any Agent-Skills-compatible client — Claude Code, Cursor, Codex, Gemini CLI — can install and invoke.

## Install

Install all skills:

```
npx skills add vios-s/Vios-Research-Skills
```

Install a single skill:

```
npx skills add vios-s/Vios-Research-Skills/<skill-name>
```

## Auto-update

Run this once to keep skills current every time you start Claude Code:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/vios-s/Vios-Research-Skills/main/install/setup.sh)
```

Or copy [`install/claude-code-hook.json`](./install/claude-code-hook.json) manually into your `~/.claude/settings.json`.

The hook runs `npx skills update --yes` in the background on every session start — silent on failure (e.g. offline).

## Browse

Human-readable previews and editable docs live at the GitBook site: *(URL to be added after GitBook Git Sync is configured)*.

## Contribute

See [`CONTRIBUTING.md`](./CONTRIBUTING.md) for the SKILL.md template, frontmatter conventions, and PR process.

## License

MIT, see [`LICENSE`](./LICENSE). Individual skills may carry their own license — check each skill's frontmatter.
