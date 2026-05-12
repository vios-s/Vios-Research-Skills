---
name: research-question-framing
category: Ideation & Hypothesis
description: Use this skill when the user wants to formulate, sharpen, or stress-test a research question or hypothesis. Triggers include "help me frame my research question", "is this a good research question", "turn this observation into a hypothesis", "what should I research about X", "I have a vague idea about Y", or "is this gap worth pursuing". Handles question decomposition, testability checks, and scope calibration. Do not use for literature searching or paper reading — use literature-review or paper-analyst instead.
version: 0.1.0
author: VIOS Lab, University of Edinburgh
license: MIT
---

# Research Question Framing

A skill for turning a vague observation, frustration, or intuition into a precise, testable, and worthwhile research question. A well-framed question is half the paper written.

## When to invoke this skill

- You have a feeling that "something is wrong with X" but can't articulate what to measure
- You want to know whether a gap you spotted in the literature is actually exploitable
- You have too broad a question ("can AI help medicine?") and need to narrow it
- You want to sanity-check your question before committing months of work to it
- You are starting a new project and need to scope the first paper

## Workflow

### 1. Elicit the raw idea

Ask the user (or extract from context):
- What phenomenon or problem prompted this idea?
- What have you observed or read that makes you think this is a gap?
- Who would care if you answered this question?
- Do you already have data or a setting in mind?

### 2. Decompose into sub-questions

Most vague ideas contain 3–5 research questions bundled together. Surface them:
- **Existence question**: Does X exist / occur?
- **Mechanism question**: Why does X happen?
- **Intervention question**: Can we change X?
- **Comparison question**: Is approach A better than B for X under conditions C?
- **Generalisation question**: Does finding X hold across settings Y, Z?

Identify which sub-question is the right scope for one paper. The others become future work or related work.

### 3. Apply the FINER criteria

Score each candidate question:

| Criterion | Question |
|-----------|----------|
| **Feasible** | Can this be answered with realistic data, compute, and time? |
| **Interesting** | Would the answer change how people work or think? |
| **Novel** | Is the answer unknown? (Check with `literature-review` if unsure) |
| **Ethical** | Does pursuing this raise consent, bias, or harm concerns? |
| **Relevant** | Does it matter to your community and/or VIOS's mission? |

A question that fails on Feasible or Ethical should be reshaped, not pursued.

### 4. Sharpen to a falsifiable hypothesis

Convert the question to a hypothesis in the form:

> **H**: [Intervention / variable X] [causes / improves / is associated with] [outcome Y] [in population / setting Z], [compared to baseline B].

Then state the **null hypothesis** (what "no effect" looks like) and what evidence would falsify H.

If you cannot write the null hypothesis, the question is not yet precise enough.

### 5. Scope calibration

Map the question to one of four contribution types to set expectations:

| Contribution type | Appropriate venue | Typical scope |
|------------------|-------------------|---------------|
| New task / benchmark | NeurIPS, ICML, CVPR | Large dataset + baseline model |
| New method for existing task | NeurIPS, ICLR, MICCAI | Method + ablations + SOTA comparison |
| Analysis / insight | ICML, NeurIPS, journals | Experiments isolating a phenomenon |
| Application to clinical problem | MICCAI, Nature Medicine, MIA | Strong clinical motivation + real data |

Mismatch between scope and contribution type is a common cause of rejection.

### 6. Output

```
RAW IDEA: <user's original phrasing>

SUB-QUESTIONS IDENTIFIED:
  1. [Existence] ...
  2. [Mechanism] ...
  3. [Intervention] ...  (etc.)

RECOMMENDED FOCUS: Sub-question X — because [rationale]

FINER SCORE: F[y/n] I[y/n] N[y/n] E[y/n] R[y/n]
  Issues: [any failures]

SHARPENED HYPOTHESIS:
  H: ...
  Null: ...
  Falsified if: ...

CONTRIBUTION TYPE: [type] → Targets [venue tier]

RISKS & OPEN DEPENDENCIES:
  - [What needs to be true for this to work?]
  - [What literature check is needed before committing?]
```

## Anti-patterns

- **Do not** accept "improve X" as a research question — improve by how much, for whom, compared to what?
- **Do not** skip the null hypothesis. If you can't state it, you can't design an experiment.
- **Do not** frame the question around your proposed method ("how well does our GNN do on Y?") — frame it around the phenomenon ("does graph structure improve Y?").
- **Do not** ignore feasibility. A well-framed but infeasible question is worthless — reshape it to something answerable with the data you have.

## See also

- `literature-review` to check novelty after framing.
- `causal-dag-builder` if the question is causal in nature.
- `research-paper-writing` once the question is locked and results exist.
