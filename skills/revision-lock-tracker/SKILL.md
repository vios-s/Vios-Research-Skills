---
name: revision-lock-tracker
description: Use this skill when the user is in the final 14 days before a paper deadline and needs to plan or track revisions. Triggers include "set up the revision lock", "make my 14-day countdown", "what should I do this week before the deadline", "track the meta-review revisions", or "prepare the PI clearance". Builds the revision log, day-by-day milestones and final checks, and enforces the no-fly zone. Do not use for writing the internal review itself — use internal-meta-review — or for checks six weeks out — use paper-skeleton-lock.
license: MIT
metadata:
  category: "Review & Dissemination"
  version: "0.1.0"
  author: "VIOS Lab, University of Edinburgh"
---

# Revision Lock Tracker (final 14 days)

The Revision Lock turns the Internal Meta-Review into a dated plan and holds the line on scope for the last two weeks. The target is a paper the PDRA can call a VIOS 8+/10, submitted 24 hours before the deadline. This skill builds the tracker, tells the user what today's phase requires, and refuses changes that belong to an earlier stage.

## When to invoke this skill

- The internal meta-review is back and the student needs a 14-day plan
- Mid-countdown: "what's left?" or "can I still add this experiment?"
- Preparing the PDRA's statement for the PI at T-48 hours

Do not use more than 14 days out — use `paper-skeleton-lock` (T-6 weeks) or `internal-meta-review` (T-4 weeks).

## Workflow

### 1. Collect inputs

- Project name, lead researcher, PDRA, deadline (date and time zone).
- The internal review score and its required revisions (from `internal-meta-review`). If no meta-review exists, say so and recommend running one before planning.
- Today's date, to place the user in the countdown.

### 2. Build the high-priority revision log

One row per required revision and per "Yes" row of the R2R mitigation table:

| Task / required change | Priority (H/M) | Due (day) | Status | PDRA sign-off |
|------------------------|----------------|-----------|--------|---------------|
| e.g. Add ablation for hyperparameter λ | H | D-10 | [ ] | |
| e.g. Rewrite Intro to address [paper X] novelty | H | D-9 | [ ] | |
| e.g. Redo Figure 3 for colour-blind accessibility | M | D-6 | [ ] | |

Priority H = would cause rejection if left; M = would lower the score. Schedule every H task requiring new numbers before D-10.

### 3. Lay out the countdown milestones

| Days left | Phase | Must be done by the end of the phase |
|-----------|-------|--------------------------------------|
| 14–10 | Structural fix | All H technical weaknesses addressed; all new table numbers and plot data final |
| 9–5 | Narrative and flow | Notation standardised across sections and appendix; reverse outline (read the first sentence of every paragraph — do they tell the story?); a fluency and clarity pass on the final text |
| 4–2 | Fresh eyes | Read a printed copy for typos; check every BibTeX entry for capitalisation and correct venue; no "Table ??" or broken cross-references |
| 1 | Technical sanity | PDF compiles with no warnings; reproducibility appendix or anonymous code link final; submit to the portal 24 h before the deadline |

Tell the user which phase today falls in and list only that phase's open items first.

### 4. Enforce the no-fly zone

During the Revision Lock, refuse and explain if the user proposes:
- **Changing the core method.** If the maths is wrong at T-14, the paper slides to the next cycle.
- **Adding authors.** Authorship was finalised at the Skeleton Lock.
- **Changing the primary figure.** Concept diagrams are stable by now; polish is fine, a new concept is not.
- **New experiments after D-10**, unless the PDRA requests one to answer a checkmate question. Ask whether that is the case before planning it.

### 5. Prepare the PI clearance (T-48 hours)

Draft the PDRA's statement only if every H row is signed off:

> "I have verified that all reasons to reject from the internal review have been mitigated. The paper is now at a VIOS [X]/10 standard."

The PI then decides: SUBMIT, or EMERGENCY DEFERRAL if quality is still below the VIOS threshold. If any H row is open, list it instead of drafting the statement.

### 6. Output

```
REVISION LOCK — [Project] — deadline [date, tz]
Internal score: [ /10] → target 8+/10
Today: D-[n], phase: [name]

REVISION LOG: [table]
TODAY'S FOCUS: [open items of the current phase]
AT RISK: [H items whose due day has passed]
NO-FLY CHECK: [any proposed change that violates the lock]
```

## Anti-patterns

- **Do not** plan new experiments in the 9–5 or later phases to "strengthen" the paper. Late numbers ripple into the abstract, tables and claims, and break the text that was just polished.
- **Do not** mark a revision done because the student says so; status changes need the PDRA sign-off column filled.
- **Do not** schedule submission for the deadline day. Portals slow down near deadlines, and the VIOS goal is 24 hours early.
- **Do not** draft the PI clearance statement with open H rows — it certifies something false.

## See also

- `internal-meta-review` for the review that feeds this log.
- `paper-skeleton-lock` for the T-6 weeks gate.
- `venue-reviewer` for the venue's formatting and checklist requirements on day 1.
- `paper-rebuttal-helper` once reviews arrive.
