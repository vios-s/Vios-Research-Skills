---
name: paper-skeleton-lock
description: Use this skill when the user wants to check whether a paper draft passes the VIOS Skeleton Lock, six weeks before a deadline. Triggers include "is my paper ready for skeleton lock", "run the T-6 weeks checklist", "check my paper skeleton", "what's missing from my draft structure", or "skeleton lock verdict". Audits the draft against the checklist and returns CLEARED / CONDITIONAL / SLIDE. Do not use for a full review of a finished paper — use internal-meta-review or pre-submission-review instead.
license: MIT
metadata:
  category: "Writing"
  version: "0.1.0"
  author: "VIOS Lab, University of Edinburgh"
---

# Paper Skeleton Lock (T-minus 6 weeks)

At six weeks before submission, a VIOS paper is not a rough sketch: it is a structurally complete logic model that already stands on its own. This skill audits a draft against the Skeleton Lock checklist and produces the Lead PDRA's verdict, so the decision to proceed, sprint, or slide to the next cycle is made on evidence instead of optimism.

If the skeleton cannot stand on its own, the paper will collapse under the weight of last-minute experiments.

## When to invoke this skill

- A student or PDRA is preparing for the T-6 weeks Skeleton Lock meeting
- A Lead PDRA wants a structured first pass before signing the verdict
- Someone asks "should we still go for this deadline?" six or more weeks out

Do not use within the last four weeks for a quality review — use `internal-meta-review`. Do not use for the final 14 days — use `revision-lock-tracker`.

## Workflow

### 1. Collect inputs

Ask for:
- The draft (LaTeX source, PDF, or pasted sections). The group Overleaf template is the expected starting point; ask the Lead PDRA for the link if the draft is not in it.
- Project title, lead researcher, Lead PDRA, target venue, submission date.
- The list of baselines and the current main results table, if not in the draft.

### 2. Audit the four checklist areas

Mark each item ✅ (evidence found in the draft), ⚠️ (partial), or ❌ (missing). Quote or point to the evidence for every ✅ — a box ticked without evidence counts as ❌.

**A. Technical and experimental foundation** (the heavy lifting is 90% done; no architectural changes after today)

| Item | Pass condition |
|------|----------------|
| Baseline freeze | Every primary SOTA baseline is implemented and run. List them. |
| The delta is proven | Current results show a statistically meaningful improvement, or a unique qualitative insight, over baselines |
| Ablation plan | Every planned ablation is listed; no new ablation ideas after this week |
| Resource check | Remaining GPU/CPU hours for final seeds and tuning are scheduled and available; data egress requests (e.g. safe-haven data) are already submitted |

**B. Narrative and visual logic**

| Item | Pass condition |
|------|----------------|
| Figure 1 (teaser) | A high-quality diagram explaining the core intuition to a non-expert |
| Figure 2 (motivation) | A figure showing why this work is needed now, ideally with empirical evidence |
| One-sentence claim | Written and agreed: "This paper contributes [X] by doing [Y], which results in [Z]." |
| Contribution bullets | Each bullet maps to a specific experiment or visualisation ("we show novelty X via ablation Y") |
| LaTeX skeleton | Every section from Abstract to Conclusion exists |
| Table/plot shells | Every table and plot exists as an empty shell with a drafted caption |

**C. AI-augmented stress test**

| Item | Pass condition |
|------|----------------|
| Literature gap check | A search confirms no paper from the last two years already does exactly this |
| Reviewer simulation | The draft Abstract and Intro were red-teamed for the 3 most likely Reasons to Reject (run `internal-meta-review` in red-team mode if not done) |
| R2R mitigation | A written plan addresses each of those 3 weaknesses |

**D. Leadership and ethics**

| Item | Pass condition |
|------|----------------|
| Authorship | Author order finalised and every author notified |
| Code/data readiness | Repository structured; any data release cleared for privacy and IP |

### 3. Check the skeleton's minimum content

| Part | Minimum state at T-6 weeks |
|------|----------------------------|
| Title | A firm working title, not "TBD" |
| Abstract | 200–250 words (adjust to venue limit) stating Problem, Gap in SOTA, Proposed Solution, Key Finding |
| Introduction | Fully drafted, with the contribution bullets; the pitch is locked (e.g. "an efficiency paper, not a robustness paper") |
| Method | All definitions, objectives and algorithms written formally in LaTeX; a notation table; an architecture diagram; an opening paragraph stating the overall objective and why each module is needed |
| Experimental setup | Datasets fully described with statistics and preprocessing; exact baseline list; metrics defined |
| Table 1 | All rows (baselines) and columns (metrics) labelled; at least 50% of cells hold preliminary results |
| Related work | Citations grouped by theme; each theme ends with a sentence positioning this paper ("Existing methods address X but not Y, which motivates us to Z") |
| Discussion/Conclusion | Bullet points of takeaways and limitations |
| Appendix plan | List of what goes in the supplement |
| Math | Fully derived; no "proof to be inserted later" |
| Experiments | The main hypothesis beats the baseline on at least one major benchmark |
| References | At least 20 key papers in the .bib file |

### 4. Issue the verdict

| Verdict | Condition | Action |
|---------|-----------|--------|
| 🟢 CLEARED | Every item ✅; narrative is sound | Proceed to Internal Review (T-4 weeks) |
| 🟡 CONDITIONAL | 1–2 minor experimental gaps, everything else ✅ | 72-hour sprint; set the re-evaluation date (leave 24 h before it for the Lead PDRA to check) |
| 🔴 SLIDE | Fundamental flaw, missing baselines, or the delta is not proven | Slide to the next cycle and focus on quality |

Any ❌ in area A or in the Math/Experiments rows of step 3 means SLIDE, not CONDITIONAL — those cannot be fixed in 72 hours without changing the paper.

### 5. Output

```
SKELETON LOCK — [Project] — [Venue], due [date]
Lead: [name]   Lead PDRA: [name]

A. Foundation:       [✅/⚠️/❌ per item, with evidence]
B. Narrative:        ...
C. Stress test:      ...
D. Leadership:       ...
Skeleton content:    [table with state per part]

VERDICT: 🟢 CLEARED / 🟡 CONDITIONAL (re-evaluate on [date]) / 🔴 SLIDE
GAPS TO CLOSE: [numbered list, owner, deadline]
```

The verdict is a recommendation; the Lead PDRA signs it.

## Anti-patterns

- **Do not** accept "experiments are running" as evidence for the delta. At T-6 weeks the delta must already be visible in numbers; a running job is a hope, not a result.
- **Do not** give CONDITIONAL to soften a SLIDE. A 72-hour sprint cannot add a missing baseline family or fix a wrong derivation, and a false CONDITIONAL costs the student the next cycle as well.
- **Do not** review prose quality. Rough prose is fine at this stage; structure, claims and evidence are what the lock checks.
- **Do not** paste unpublished draft text into external web search tools during the literature gap check — search with keywords and method names instead.

## See also

- `internal-meta-review` for the T-4 weeks PDRA review and red-team.
- `revision-lock-tracker` for the final 14 days.
- `research-paper-writing` for drafting the sections this audit flags.
- `literature-review` for the literature gap check.
