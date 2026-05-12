# Contributing to Vios Research Skills

## Adding a new skill

1. Create a new folder under `skills/` named in `kebab-case` (e.g. `causal-dag-builder`, not `Causal_DAG_Builder`).
2. Inside it, create `SKILL.md` using the template below.
3. Update `skills/SUMMARY.md` to include your skill, or run `python scripts/generate_summary.py` to regenerate it.
4. Open a pull request against `main`. CI will lint your frontmatter and check SUMMARY.md is in sync.

## SKILL.md template

```markdown
---
name: skill-name-in-kebab-case
category: Discovery & Monitoring  # pick one of the valid pipeline stages (see Frontmatter conventions)
description: Use this skill when [trigger]. Triggers include "[example phrasing 1]", "[example phrasing 2]". Handles [scope of what the skill does]. Do not use for [out-of-scope cases].
version: 0.1.0
author: Your Name, VIOS Lab
license: MIT
---

# Human-Readable Skill Title

One-paragraph human-facing summary. This is what GitBook readers see first.

## When to invoke this skill

[Bulleted triggers and counter-triggers.]

## Workflow

[Numbered steps the agent should follow.]

## Anti-patterns

[Things the agent should NOT do.]

## See also

[Cross-references to related skills.]
```

## Frontmatter conventions

- `name`: kebab-case, must match the folder name.
- `category`: determines which section of the GitBook sidebar your skill appears in. Valid values:
  - `Discovery & Monitoring`
  - `Reading & Analysis`
  - `Ideation & Hypothesis`
  - `Methodology`
  - `Domain: Medical Imaging`
  - `Domain: Plant Phenotyping`
  - `Domain: Causality`
  - `Domain: Computer Vision`
  - `Writing`
  - `Review & Dissemination`
  - `Community & Infrastructure`

  Quote the value in YAML frontmatter if it contains a colon: `category: "Domain: Medical Imaging"`.
- `description`: must contain at least one trigger phrase ("Use this skill when…"). This is what the agent reads to decide whether to fire. Aim for 200–400 characters. Include positive examples and at least one negative ("Do not use for…").
- `version`: semantic versioning, increment on substantive changes.
- `author`: name + affiliation.
- `license`: usually MIT (the repo default), unless you have reason otherwise.

## Style notes

- Write the SKILL body for an agent first, but readable by a human. The first paragraph after the H1 should be a human-facing intro before any "Workflow" headers.
- Keep concrete examples in the body — they help both humans and agents.
- Prefer clear instructions over hedged ones. "Always do X" beats "You might consider doing X".
- Cross-reference related skills at the bottom in a `## See also` section.

## Editing via GitBook vs. via Git

You can edit either way:

- **GitBook**: open the page, click edit, save. Changes commit to `main` automatically via Git Sync.
- **Git**: clone the repo, edit Markdown directly, push or PR.

**Important:** Do not create new pages or folders via the GitBook UI. New skills must be added via a GitHub PR so that `skills/SUMMARY.md` is kept in sync with the generator script. A stray page created in GitBook will cause CI to fail on the next developer push.

Do not create `README.md` files inside `skills/<name>/` folders — the config uses `SKILL.md` as the per-folder readme.

## Review process

Any lab member can merge their own PRs after CI passes. Once we have external contributors, we will move to a review-required model.
