---
title: Vios Research Skills
---

# Vios Research Skills

A living library of prompts and skill modules for research workflows in AI, causality, and medical imaging, maintained by the VIOS Lab at the University of Edinburgh.

Each entry in the sidebar is a self-contained skill module. The page you're reading is the literal Markdown an AI agent reads when the skill is invoked — what you see in GitBook is what the model sees.

## How to use this library

- **As a human:** browse the sidebar, copy snippets, suggest edits via the pencil icon (top-right) or a GitHub PR.
- **As an AI client:** install as a Claude Code plugin, a Gemini CLI extension, or with `npx skills add vios-s/Vios-Research-Skills -g` for any Agent Skills client (Codex, Cursor, GitHub Copilot, OpenCode, …). See the repository README for each route.

## Scope

Skills here follow the full research pipeline across twelve stages:

| Stage | What it covers |
|-------|---------------|
| **Discovery & Monitoring** | Finding and tracking papers, monitoring arXiv |
| **Reading & Analysis** | Deep reading of single papers, critical evaluation |
| **Ideation & Hypothesis** | Framing questions, sharpening hypotheses |
| **Domain: Medical Imaging** | Fairness, synthesis, cardiac MRI |
| **Domain: Plant Phenotyping** | Leaf segmentation, trait estimation, PhenoAssistant |
| **Domain: Causality** | Causal DAGs, causal discovery, identifiability, counterfactuals, SCMs |
| **Domain: Computer Vision** | General CV methods, benchmarking, representation learning |
| **Writing** | Paper drafting, rebuttals, grant writing |
| **Review & Dissemination** | Internal meta-review, revision lock, pre-submission checks, venue-specific review |
| **Lab Operations** | EIDF GPU jobs, theme meetings |
| **Community & Infrastructure** | Adding skills, maintaining the library |

## Skills at a glance

| Category | Skills |
|----------|--------|
| Discovery & Monitoring | `arxiv-digest` |
| Reading & Analysis | `literature-review`, `paper-analyst` |
| Ideation & Hypothesis | `research-question-framing`, `project-idea-pitch` |
| Domain: Medical Imaging | `cardiac-mri-analysis`, `fairness-medical-imaging`, `medical-image-synthesis` |
| Domain: Plant Phenotyping | `plant-phenotyping` |
| Domain: Causality | `causal-dag-builder`, `causal-discovery` |
| Domain: Computer Vision | `pytorch-segmentation` |
| Writing | `research-paper-writing`, `paper-skeleton-lock`, `paper-rebuttal-helper` |
| Review & Dissemination | `internal-meta-review`, `revision-lock-tracker`, `pre-submission-review`, `venue-reviewer` |
| Lab Operations | `eidf-job`, `theme-meeting-prep` |
| Community & Infrastructure | `gitbook-maintenance`, `skill-writer` |

## Contributing

Lab members can edit existing skill content directly in GitBook (changes sync to GitHub) or open a PR against `main` for new skills. See [`CONTRIBUTING.md`](https://github.com/vios-s/Vios-Research-Skills/blob/main/CONTRIBUTING.md) for the template. To fork this library for private use, see [`FORKING.md`](https://github.com/vios-s/Vios-Research-Skills/blob/main/FORKING.md).

---

## For AI agents: how to create and improve skills in this library

This section is written for AI agents assisting researchers who want to write new skills or improve existing ones. Read it before making any changes to skill files.

### What a skill actually is

A skill is read in **two distinct contexts**:

1. **Trigger context** — the agent scans the `description` field to decide whether to invoke the skill. Only the `description` field matters here; the body is not read.
2. **Execution context** — once invoked, the agent reads the full SKILL.md body and follows the workflow.

Both contexts must be designed for. A skill with a perfect workflow but a weak description will never fire. A skill that fires correctly but has a vague workflow will produce inconsistent output.

### Quality criteria for the `description` field

The description is the most important line in the file. It must:

- **Start with `"Use this skill when"`** — required by the linter.
- **Include at least 3 concrete trigger phrases** in quotation marks — these are the actual user utterances that should activate the skill. Make them specific and varied (e.g. `"review my paper before I submit"`, `"find weaknesses in my paper"`, `"pre-submission check"`).
- **Include at least one explicit negative** — `"Do not use for X"` — to prevent wrong invocations and false positives.
- **Be 150–400 characters** — long enough to be specific, short enough to be scanned.
- **Not use jargon that a non-specialist would not use** in the trigger phrases — agents match on natural language.

**Good description example:**
```
Use this skill when the user wants to deeply analyse a single academic paper. Triggers include "analyse this paper", "break down this paper", "what are the weaknesses of X", or providing an arXiv link for critical reading. Do not use for surveys across multiple papers — use literature-review instead.
```

**Bad description example:**
```
Use this skill for paper analysis including Heilmeier catechism application, methodology auditing, and claim-evidence consistency checking across academic literature.
```
The bad example names the workflow (what happens inside) rather than the trigger (what the user says).

### Quality criteria for the workflow

Each workflow step must be **actionable** — an agent reading it should know exactly what to do, not just what topic to think about.

| Bad step | Good step |
|----------|-----------|
| "Analyse the paper's methodology" | "For each major methodological choice, ask: Is the choice justified? What happens if the assumption is wrong? Was this made before seeing results?" |
| "Consider the research question" | "State the research question in one sentence in the form: H: [X] causes/improves [Y] in [Z], compared to [B]." |
| "Review the related work" | "For each cited group of papers: state what they do, state their limitation relative to yours, cite 2–3 representative works." |

Steps should produce **concrete outputs** the user can verify (a table, a sentence, a score, a list). Avoid steps that only ask for internal reflection.

### Quality criteria for anti-patterns

Anti-patterns must be specific to this skill, not generic writing advice. Each one should:
- Name the specific wrong behaviour
- Explain why it fails (not just "this is bad")
- Be something a competent agent would actually be tempted to do

**Good anti-pattern:** `"Do not adjust for mediators when estimating the total effect — this blocks the causal path and gives the controlled direct effect instead."`
**Bad anti-pattern:** `"Do not produce low-quality output."`

### File constraints for this library

- **Plain Markdown only.** No GitBook-specific syntax (`{% hint %}`, `{% tabs %}`, `{% stepper %}`). These render in GitBook but appear as raw text when an AI agent reads the file via the Agent Skills installer.
- **No `README.md` inside skill folders.** The linter and GitBook both expect `SKILL.md` as the per-folder file.
- **Agent Skills spec fields only at the top level**: `name`, `description`, `license`, `compatibility`, `metadata`, `allowed-tools`. Anything else fails CI and the reference validator.
- **`metadata.category` is required** and must be one of the valid pipeline stages (see CONTRIBUTING.md for the full list). Invalid categories fail CI. All `metadata` values are quoted strings: `category: "Domain: Medical Imaging"`, `version: "0.1.0"`.
- **`name:` must match the folder name exactly** (kebab-case). A mismatch fails CI.
- **`description:` must be 100–1024 characters** and start with `"Use this skill"`.
- **`SKILL.md` stays under 500 lines.** Put long reference material or templates in sibling files (e.g. `references/`, `templates/`) and point to them by relative path.

### How to test a skill before submitting

1. **Trigger test**: Write 5 user utterances you expect to trigger this skill and 3 you expect not to. Read only the `description` — does it clearly include the 5 and exclude the 3? If not, rewrite the triggers.
2. **Workflow test**: Follow the workflow steps yourself on a real example. If any step leaves you uncertain what to produce, it is too vague — add specificity.
3. **Lint test**: `python scripts/lint_skills.py` — must exit 0.
4. **Summary test**: `python scripts/generate_summary.py --check` — must exit 0.

For detailed guidance on writing and refining skills, invoke the `skill-writer` skill.
