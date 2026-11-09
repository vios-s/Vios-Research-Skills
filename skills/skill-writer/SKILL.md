---
name: skill-writer
description: Use this skill when the user wants to write a new skill for this library, improve an existing skill, or evaluate skill quality. Triggers include "help me write a skill", "improve this skill", "my skill is not firing", "the description is wrong", "refine this SKILL.md", "review this skill for quality", "why isn't this skill triggering", or when a user pastes a draft SKILL.md and asks for feedback. Do not use for maintaining library structure (SUMMARY.md, frontmatter CI) — use gitbook-maintenance instead.
license: MIT
metadata:
  category: "Community & Infrastructure"
  version: "0.1.0"
  author: "VIOS Lab, University of Edinburgh"
---

# Skill Writer

A skill for creating high-quality skill files for this library — or improving ones that exist. Most skill quality problems come from one of three sources: a description that doesn't trigger, a workflow that's too vague to execute, or anti-patterns that are generic rather than specific. This skill diagnoses and fixes all three.

## When to invoke this skill

- A researcher wants to contribute a new skill
- A skill exists but agents rarely invoke it even when they should
- A skill fires too often (false positives)
- The workflow produces inconsistent or shallow output
- You want a quality review of a draft SKILL.md before opening a PR

## The two-context principle

A skill is read in two completely different contexts. Design for both explicitly.

**Context 1 — Trigger matching** (only `description` is read):
The agent scans the `description` to decide whether to invoke the skill. It matches on natural language similarity to the user's request. If the description does not contain phrases a user would actually say, the skill will not fire.

**Context 2 — Execution** (full body is read):
Once invoked, the agent reads the entire SKILL.md and follows the workflow. If the steps are vague, the agent will fill gaps with generic behaviour. If the steps are specific, the output will be consistent and high-quality.

---

## Workflow: writing a new skill from scratch

### Step 1. Define the trigger precisely

Before writing anything else, answer:
- What does a user say that should trigger this skill? Write 5 exact phrases.
- What do they say that should NOT trigger it? Write 3 counter-examples.
- Is there an existing skill that overlaps? If so, add a clear boundary in both skills' negatives.

The 5 trigger phrases become the `description` field's example list. The 3 counter-examples become the "Do not use for" clause.

### Step 2. Draft the `description` field

Formula:
```
Use this skill when [one-sentence summary of the trigger situation]. 
Triggers include "[phrase 1]", "[phrase 2]", "[phrase 3]", [other patterns]. 
[Optional: handles [scope summary].] 
Do not use for [explicit out-of-scope cases] — use [alternative skill] instead.
```

Checklist before moving on:
- [ ] Starts with "Use this skill when"
- [ ] Contains ≥ 3 quoted trigger phrases that users would actually say
- [ ] Contains at least one explicit negative with an alternative skill named
- [ ] Is 150–400 characters
- [ ] Uses natural language, not jargon, in trigger phrases

### Step 3. Choose the category

Pick one of the valid pipeline stages from CONTRIBUTING.md. Pipeline stages cover universal research workflow steps (Discovery, Reading, Writing, etc.); domain categories (Domain: Medical Imaging, Domain: Plant Phenotyping, Domain: Causality, Domain: Computer Vision) cover research-area-specific skills. If the skill spans two stages, pick the one where it is most often first invoked. Do not invent a new category — if the skill truly does not fit, discuss with the maintainer.

### Step 4. Write the workflow

Structure the workflow as numbered phases, each with concrete sub-steps. For each step ask: *"If I followed only this step and nothing else, what would I produce?"*. If the answer is "it depends" or "I'm not sure", the step is too vague.

**Specificity test for each step:**

| Too vague | Specific enough |
|-----------|----------------|
| "Analyse the methodology" | "For each methodological choice, state: (a) is it justified in the text? (b) what breaks if the assumption is wrong? (c) is there a simpler alternative that would give the same result?" |
| "Write a good introduction" | "Five-paragraph structure: (1) hook — phenomenon anyone in the field recognises, (2) state of the art and its limits, (3) the specific gap, (4) your approach in one paragraph, (5) bulleted contribution list starting with verbs." |
| "Consider the venue requirements" | "Apply the checklist for the named venue from the `venue-reviewer` skill. If no venue is specified, ask before proceeding." |

Use **tables**, **checklists**, and **output templates** generously. These constrain agent behaviour and produce consistent structure.

### Step 5. Write anti-patterns

Write 3–5 anti-patterns. Each must:
1. Name a specific wrong action (not "produce bad output")
2. Explain *why* it fails in this context
3. Be something a capable agent would actually be tempted to do

Test each anti-pattern: if you read it without the skill, would it still be obvious it's wrong? If yes, it's too generic — make it skill-specific.

### Step 6. Write "See also"

List 2–4 related skills. A good "See also" helps the user understand the skill's boundaries and reduces overlap confusion.

---

## Workflow: improving an existing skill

### Step 1. Diagnose the problem

Ask the user: what symptom are you seeing?

| Symptom | Root cause | Fix |
|---------|-----------|-----|
| Skill never fires even when relevant | Description triggers are too narrow/jargon-heavy | Rewrite description with natural trigger phrases |
| Skill fires when it shouldn't | Description is too broad; no negative clause | Add "Do not use for X" with named alternatives |
| Output is inconsistent across runs | Workflow steps are vague | Add specificity: expected output format, concrete actions |
| Output is shallow / misses key points | Anti-patterns not explicit about common shortcuts | Add anti-patterns for the specific shortcut |
| Skill is too long and agents truncate it | Workflow contains exposition instead of instructions | Remove explanatory text; replace with actionable steps |
| Trigger fires but wrong section executed | Skill conflates two distinct use cases | Split into two skills |

### Step 2. Rewrite the specific part

Do not rewrite the whole skill when one section is the problem. Target the failing part:

- **Description only** — if the trigger is wrong but the workflow is fine.
- **One workflow step** — if the overall structure is right but one step is vague.
- **Anti-patterns section** — if the skill is firing correctly but producing bad output in a specific way.

### Step 3. Validate the fix

After editing:
1. Read only the `description`. Do the 5 intended trigger phrases match? Do the 3 non-triggers clearly fall outside?
2. Follow the revised workflow step-by-step on a real example. Does it produce the expected output?
3. Run `python scripts/lint_skills.py` — must pass.
4. Run `python scripts/generate_summary.py --check` — must pass (only if SUMMARY.md was touched).

---

## Quality rubric (use for final review before PR)

Rate each dimension 1–3:

| Dimension | 1 — Weak | 2 — Adequate | 3 — Strong |
|-----------|----------|--------------|------------|
| **Trigger coverage** | Trigger phrases are jargon-heavy or missing | At least 2 natural trigger phrases | ≥ 3 varied natural phrases + explicit negatives |
| **Workflow specificity** | Steps name topics, not actions | Steps produce identifiable outputs | Steps include output templates or checklists |
| **Anti-pattern quality** | Generic ("don't produce bad output") | Skill-specific but obvious | Non-obvious, specific to this skill's failure modes |
| **Boundary clarity** | No "See also" or negatives | References one alternative | Clear boundaries with named alternatives for edge cases |
| **Plain Markdown** | Uses GitBook blocks | All standard Markdown | All standard Markdown, renders correctly in plain text |

A skill is ready to merge when all dimensions score ≥ 2 and at least two score 3.

## Anti-patterns

- **Do not** conflate the trigger (what the user says) with the workflow (what the agent does). The description field is not a summary of the workflow — it is a pattern-matching string for user utterances.
- **Do not** write steps that say "consider X" — every step must say "do X, producing Y".
- **Do not** add a "See also" that points to a skill that covers the same trigger — this creates ambiguity. If two skills overlap, add a negative clause to each.
- **Do not** make the skill too long. A workflow longer than 400 lines risks truncation in agent context. If the workflow is that complex, split into two skills.
- **Do not** use GitBook-specific syntax (`{% hint %}`, `{% tabs %}`) — it renders in the browser but appears as raw text to AI agents reading the installed file.

## See also

- `gitbook-maintenance` for scaffolding the file structure and running CI checks.
- `skills/SKILL.md` (this library's homepage) for the compact quality criteria reference.
- `CONTRIBUTING.md` for the frontmatter template and PR workflow.
