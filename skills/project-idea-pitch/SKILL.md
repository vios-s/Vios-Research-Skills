---
name: project-idea-pitch
description: Use this skill when the user wants to turn a research idea into a VIOS project pitch or proposal. Triggers include "fill in the project idea template", "help me pitch this idea at the theme meeting", "write up my new project idea", "what's the kill switch for this project", or "plan the 2-week proof of concept". Produces a filled VIOS Project Idea Template with a kill switch, de-risk experiment and resource plan. Do not use for sharpening a vague question into a hypothesis — use research-question-framing first.
license: MIT
metadata:
  category: "Ideation & Hypothesis"
  version: "0.1.0"
  author: "VIOS Lab, University of Edinburgh"
---

# Project Idea Pitch

A skill for writing up a new research idea in the VIOS Project Idea Template, ready to bring to a theme meeting as a Stage 1 "New Pitch". The template exists to force three things early: a reason anyone would care, a cheap experiment that could kill the idea, and an honest estimate of what the project will cost in data, compute and people.

## When to invoke this skill

- A researcher has an idea and needs to pitch it to the group or their PI
- A student is starting a project and needs the one-page plan
- Someone asks "is this worth a Track A flagship?" or "what's the fastest way to know if this works?"
- Preparing the Stage 1 snapshot for a theme meeting (see `theme-meeting-prep` for the meeting itself)

Do not use when the question itself is still vague ("something about fairness in MRI") — run `research-question-framing` first, then come back with the sharpened hypothesis.

## Workflow

### 1. Gather the raw material

Ask for, or extract from context, in one round:
- The idea in the user's own words
- What prompted it (a paper, a failure, an observation in data)
- The dataset(s) and compute they have in mind
- Whether they see it as Track A (flagship, high-risk) or Track B (momentum, incremental)

If the user has already run `research-question-framing`, reuse its hypothesis statement verbatim.

### 2. Fill the template section by section

Work through each section below. For every prompt, write a concrete answer; where the user has not given enough to answer, write `TODO: <specific question>` rather than inventing content.

**1. Why?**
- The problem or gap in the literature, in 1–2 sentences.
- Who will read and cite this, and how does it change their work? Name the community (e.g. "cardiac MRI segmentation groups using UK Biobank"), not "the field".

**2. Context**
- The 3–5 pieces of related work this builds on, each with one line on what it does and what it leaves open.
- The current state of the art on the target benchmark, with the number.
- Has the problem been reformulated in a different field? (e.g. domain shift in imaging ↔ covariate shift in statistics.)
- The Graveyard: has this been tried and failed? If yes, state why this attempt is different.

If the user cannot answer the state-of-the-art or graveyard questions, recommend a `literature-review` pass before the pitch.

**3. What?**
- The core idea in 1–2 sentences, in the form: "We [do X] to [achieve Y], which [existing methods] cannot because [reason]."
- The pipeline: 4–6 high-level steps from t=0 to submission.
- The Kill Switch: the single experiment whose failure proves the project is a waste of time. It must be a specific experiment with a pass/fail threshold, e.g. "If the causal regulariser does not reduce the subgroup Dice gap by ≥2 points on the validation split, stop."

**4. Early De-Risk**
- The 2-week experiment: the smallest proof of concept that tests the Kill Switch. State the dataset subset, the baseline, the metric, and the threshold.
- Evaluation: the metrics and benchmarks that will show the final method won.
- Timeline: how many submission cycles (VIOS calendar) this will take, and the target venue for the first paper.

**5. Resources**

| Resource | Answer |
|----------|--------|
| Dataset | Name, size, access status (downloaded / needs application / safe-haven egress), storage needed |
| Compute | CPU or GPU; GPU type and count; estimated GPU-hours for the PoC and for the full project |
| Human labour | Annotation, clinical judgement, user studies — who and how many hours |
| Risk level | "Safe incremental step" or "high-risk wild pivot" |

For a wild pivot, state the intuition or preliminary evidence that it might work. For EIDF GPU estimates, the `eidf-job` skill has the per-parameter VRAM rules of thumb and the group quota.

### 3. Stress-test the pitch

Before handing over, ask the two discussant questions the theme meeting will ask, and answer them in the pitch:
1. "Is the delta big enough for a top-tier venue?"
2. "If the 2-week PoC fails, do we kill it or pivot?" — name the pivot, or say "kill".

### 4. Output

Return the filled template as Markdown with the five numbered headings above, followed by:

```
ONE-SENTENCE CLAIM: This project contributes [X] by doing [Y], which results in [Z].
TRACK: A / B — [one-line justification]
KILL SWITCH: [experiment] — fails if [threshold]
OPEN TODOs: [list of TODO items the user must fill]
```

## Anti-patterns

- **Do not** write a Kill Switch that cannot fail ("we will see if the method works"). Without a threshold, nobody can decide to stop, and the project drifts for months.
- **Do not** leave the Graveyard empty because the user did not mention prior failures. An empty Graveyard on a well-studied problem means the search was not done; flag it as a TODO.
- **Do not** estimate compute as "some GPUs". The group shares a fixed quota; an unquantified request cannot be planned against it.
- **Do not** inflate the "Who will cite this" answer to the whole of machine learning. A narrow, named audience is more convincing to the PI than a vague broad one.

## See also

- `research-question-framing` to sharpen the hypothesis before pitching.
- `literature-review` to fill the Context and Graveyard sections.
- `theme-meeting-prep` to present the pitch as a Stage 1 snapshot.
- `eidf-job` for GPU sizing and running the PoC on the cluster.
