---
name: internal-meta-review
description: Use this skill when a VIOS PDRA or student wants the internal meta-review of a draft, or a red-team of it before submission. Triggers include "write the internal meta-review for this draft", "red-team my paper", "give me the reasons to reject", "act as a cynical area chair", "PDRA review checklist", or "what checkmate questions will reviewers ask". Produces the scored VIOS meta-review form and an R2R mitigation table. Do not use for a structural completeness check — use pre-submission-review — or for real reviews already received — use paper-rebuttal-helper.
license: MIT
metadata:
  category: "Review & Dissemination"
  version: "0.1.0"
  author: "VIOS Lab, University of Edinburgh"
---

# Internal Meta-Review and Red-Team

At T-minus 4 weeks the PDRA stops being a mentor and becomes an internal Area Chair. The goal is not to be nice; it is to be the hardest reviewer the student will face, so the real reviewers find nothing new. This skill runs the VIOS internal review in one of two modes and always ends with an action plan the student can execute in 14 days.

## When to invoke this skill

- **PDRA mode**: a PDRA has received a student's draft and must return the meta-review within 48 hours
- **Red-team mode**: a student wants a brutally honest "reasons to reject" assessment of their Abstract, Introduction and results before the Skeleton Lock or Internal Review
- Someone asks what a hostile Reviewer 2 would say

Do not use for a checklist of missing sections (use `pre-submission-review`), for venue-specific criteria (use `venue-reviewer`), or once real reviews have arrived (use `paper-rebuttal-helper`).

## Workflow

### 1. Pick the mode and collect inputs

- **Red-team mode** needs: target venue, Abstract, Introduction, and a summary of the main tables and plots.
- **PDRA mode** needs: the full draft, project name, lead researcher, reviewer name, date.

If the user does not say, use PDRA mode when a full draft is provided and red-team mode otherwise.

### 2. Adopt the reviewer persona

Act as a senior programme committee member and a highly cynical Area Chair at the target venue (default: a top-tier ML venue such as NeurIPS, ICLR or CVPR) with a 15% acceptance rate and a reputation for rigour on novelty and evidence. Your job is to find every reason to reject so the authors can fix them before the deadline. Do not soften findings.

Critique along four axes:

| Axis | Questions to answer |
|------|---------------------|
| Originality | Is this a marginal delta over SOTA? An obvious combination of two known techniques? Name the closest prior paper. |
| Technical quality | Hidden assumptions? Is the maths sound? Is the "why" explained, or only "it works better"? |
| Experimental rigour | Baselines too weak or too old? Dataset too small or toy? Improvement within noise (no seeds, no error bars)? |
| Clarity | Is the core contribution buried in jargon? Does the motivation solve a real problem? |

### 3. Run the PDRA checklist (PDRA mode)

Answer each with Yes/No and point to the evidence in the draft. A "Yes" with no evidence is a "No".

| Area | Check |
|------|-------|
| Story | Golden thread: Abstract, Intro and Conclusion tell one consistent story |
| Story | Motivation is grounded in empirical evidence (expected for CV papers) |
| Story | Claim mapping: every bold claim in the Intro is backed by a numbered Table or Figure |
| Story | Notation is consistent across sections and appendix |
| Glance | Figures are self-contained: captions plus plots explain what and why |
| Glance | All plots show error bars or variance; seeds are documented |
| Glance | Figure fonts legible; palette colour-blind friendly |
| Glance | Whole-paper appearance: page limit used fully, no unfinished sentences, no large blank space |
| Proof | SOTA reality check: if not beating SOTA, the reason (efficiency, interpretability) is scientifically compelling |
| Proof | Ablations show which component provides the gain |
| Proof | The improvement is meaningful, not noise-chasing |

### 4. Write the output

**Red-team mode** — three sections:

1. **Summary of rejection**: two paragraphs on why this paper would be rejected in its current state.
2. **Top 3 Reasons to Reject (R2R)**: each specific — name the too-similar paper or the missing experiment, not just "lack of novelty".
3. **Killer questions**: three questions a hostile reviewer would ask in the rebuttal that the authors probably cannot answer yet.

**PDRA mode** — the VIOS Internal Meta-Review form:

```
VIOS INTERNAL META-REVIEW
Project: [ ]  | Lead: [ ]
Internal reviewer (PDRA): [ ]  | Date: [ ]

1. Summary & contribution — the paper in 3 sentences.
   (If this is impossible, say so: the one-sentence claim is failing.)
2. Likely rating: [ /10]  Confidence: [ /5]
   (10 = best paper candidate, 5 = borderline, 3 = clear reject)
3. Primary strengths (reasons to accept): 1. 2. 3.
4. Primary weaknesses (reasons to reject): the 3 things a hostile reviewer will use to kill this paper.
5. Checkmate questions: Q1, Q2 — questions we cannot answer yet.
6. Required revisions (Revision Lock plan) — what must change in 14 days to move the score by +2:
   [ ] Writing:     e.g. "Rewrite Section 3.2 to clarify the loss."
   [ ] Experiments: e.g. "Run baseline B on dataset X."
   [ ] Visuals:     e.g. "Redraw Figure 2 to show the architecture flow."
```

### 5. Build the mitigation table (both modes)

For every R2R and weakness, fill:

| Identified weakness | Valid? (Yes/No, one-line reason) | Action taken / planned |
|---------------------|----------------------------------|------------------------|
| e.g. "Baselines are 2 years old" | Yes | Run against [2025 paper] immediately |
| e.g. "Contribution is unclear" | Yes | Rewrite Section 1.2 around the one-sentence claim |

Mark a weakness "No" only with a concrete reason (e.g. "the cited paper solves a different task"); the student still adds a sentence to the paper pre-empting it. Hand the "Yes" rows to `revision-lock-tracker` as the high-priority revision log.

## Anti-patterns

- **Do not** balance every weakness with a compliment. The form has a separate strengths section; mixing them hides the severity of the weaknesses.
- **Do not** write generic weaknesses ("novelty is limited"). Without the specific paper or experiment, the student cannot act on it and the review is wasted.
- **Do not** rate above 5 when any claim in the Introduction has no supporting table or figure — real reviewers treat unsupported claims as fatal.
- **Do not** propose required revisions that cannot be done in 14 days or that change the core method. Those belong in a SLIDE recommendation, not the revision plan.

## See also

- `paper-skeleton-lock` for the T-6 weeks structural gate.
- `revision-lock-tracker` to execute the required revisions.
- `pre-submission-review` for a structural completeness check.
- `venue-reviewer` for venue-specific scoring rubrics.
