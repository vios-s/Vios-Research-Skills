---
title: Vios Research Skills
---

# Vios Research Skills

A living library of prompts and skill modules for research workflows in AI, causality, and medical imaging, maintained by the VIOS Lab at the University of Edinburgh.

Each entry in the sidebar is a self-contained skill module. The page you're reading is the literal Markdown an AI agent reads when the skill is invoked — what you see in GitBook is what the model sees.

## How to use this library

- **As a human:** browse the sidebar, copy snippets, suggest edits via the pencil icon (top-right) or a GitHub PR.
- **As an AI client:** `npx skills add vios-s/Vios-Research-Skills` drops the skills into your agent's skills directory. Compatible with Claude Code, Cursor, Codex, and Gemini CLI.

## Scope

Skills here cluster around three research axes:

- **AI methodology** — red-teaming, evaluation, training-pipeline prompts.
- **Causality** — DAG construction, identification, sensitivity analysis.
- **Medical imaging** — preprocessing, fairness, reporting.

Plus cross-cutting workflows for literature review, paper writing, rebuttals, and collaboration.

## Contributing

Lab members can edit existing skill content directly in GitBook (changes sync to the GitHub repo) or open a PR against `main`. To add a new skill, open a GitHub PR — see [`CONTRIBUTING.md`](https://github.com/vios-s/Vios-Research-Skills/blob/main/CONTRIBUTING.md).
