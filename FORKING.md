# Forking Vios Research Skills

This guide explains how to create a private fork of this library — useful if you want to maintain a personal or group skills collection that builds on the VIOS base but adds private or sensitive skills.

## When to fork

- You want skills that contain proprietary data pipelines, internal tool references, or unpublished method details
- Your group's research focus diverges enough from VIOS that you want a different default skill set
- You want to experiment with new skills before contributing them upstream

## Step 1. Fork on GitHub

1. Go to [github.com/vios-s/Vios-Research-Skills](https://github.com/vios-s/Vios-Research-Skills).
2. Click **Fork** (top right).
3. In the fork dialog, choose your personal account or org. If you need privacy, make the fork private immediately after creation.

> **Note:** A fork of a public repo is public by default on GitHub. Change the visibility in Settings → Danger Zone → Change repository visibility.

## Step 2. Install from your fork

```bash
npx skills add your-org/Your-Research-Skills -g
```

This installs skills from your fork, not the VIOS upstream. Your private skills stay private.

To also install the fork as a Claude Code plugin or Gemini CLI extension, rename it first: change `name` in `.claude-plugin/marketplace.json`, `.claude-plugin/plugin.json` and `gemini-extension.json` (e.g. to `your-org-research-skills`) so it does not clash with the VIOS upstream if both are installed.

## Step 3. Connect your own GitBook space (optional)

1. Create a new GitBook space in your org or personal account.
2. In Git Sync settings: GitHub repo = your fork, branch = `main`, project directory = `./`.
3. Trigger the initial sync.

The `.gitbook.yaml` is inherited from the fork — no changes needed.

## Step 4. Add private skills

Private skills go through the same PR workflow as public ones:

```bash
git checkout -b skill/my-private-skill
mkdir skills/my-private-skill
# create skills/my-private-skill/SKILL.md using the template in CONTRIBUTING.md
python scripts/generate_summary.py
python scripts/lint_skills.py
git add skills/my-private-skill/ skills/SUMMARY.md
git commit -m "Add my-private-skill"
git push -u origin skill/my-private-skill
gh pr create --base main
```

CI will run the same lint checks on your fork.

## Step 5. Pull updates from VIOS upstream

To incorporate improvements from the upstream VIOS library into your fork:

```bash
# Add the upstream remote once
git remote add upstream https://github.com/vios-s/Vios-Research-Skills.git

# Fetch and merge upstream changes
git fetch upstream
git merge upstream/main

# Resolve any conflicts (typically in SUMMARY.md or skills you have modified)
python scripts/generate_summary.py   # regenerate SUMMARY.md after merge
python scripts/lint_skills.py
git add .
git commit -m "Merge upstream VIOS updates"
git push origin main
```

Upstream changes to existing skills (e.g., improved `literature-review`) will apply automatically. If you have modified the same skill in your fork, you will need to resolve the merge conflict manually.

## Step 6. Contributing back upstream

If a private skill matures and would be useful to the broader lab:

1. Open a PR from your fork to `vios-s/Vios-Research-Skills`.
2. Remove any private data, internal tool names, or unpublished results from the skill content.
3. Ensure the frontmatter passes lint: `python scripts/lint_skills.py`.
4. The VIOS maintainers will review and merge.

## Keeping the auto-update hook pointed at your fork

If you ran the setup script, your Claude Code hook currently updates `vios-s/Vios-Research-Skills`. To update it to point at your fork:

1. Open `~/.claude/settings.json`.
2. Find the `SessionStart` hook command and replace `vios-s/Vios-Research-Skills` with `your-org/Your-Research-Skills`.

Or re-run the setup script from your fork:

```bash
# macOS/Linux
bash <(curl -fsSL https://raw.githubusercontent.com/your-org/Your-Research-Skills/main/install/setup.sh)

# Windows
irm https://raw.githubusercontent.com/your-org/Your-Research-Skills/main/install/setup.ps1 | iex
```

## Tips

- Keep private skills in a separate directory prefix (e.g., `skills/private-*`) to make upstream merges cleaner.
- Tag stable versions of your fork with git tags (`v0.1.0`, `v0.2.0`) so team members can pin to a known-good state: `npx skills add your-org/Your-Research-Skills@v0.2.0 -g` (or `#<branch>` for a branch).
- If you want some skills from VIOS and some private ones, you can install both: `npx skills add vios-s/Vios-Research-Skills -g` and `npx skills add your-org/Private-Skills -g` simultaneously.
