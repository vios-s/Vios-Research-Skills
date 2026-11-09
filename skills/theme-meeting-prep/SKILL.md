---
name: theme-meeting-prep
description: Use this skill when the user is preparing for, or running, a VIOS theme meeting. Triggers include "prepare my theme meeting update", "fill in my dashboard row", "should this be a deep dive or an update", "what will the discussant ask", "write my pre-meeting snapshot", or "plan the theme meeting agenda". Produces the stage snapshot, dashboard row, discussant questions and agenda. Do not use for writing the project proposal itself — use project-idea-pitch — or for reviewing a paper draft — use internal-meta-review.
license: MIT
metadata:
  category: "Lab Operations"
  version: "0.1.0"
  author: "VIOS Lab, University of Edinburgh"
---

# Theme Meeting Prep

VIOS theme meetings run every two weeks per theme. Each project presents either a short Update or a 30-minute Deep Dive, depending on its stage and whether it needs the group's help. This skill prepares a presenter's snapshot and dashboard row, predicts the discussant's hard questions, and helps a host plan the agenda.

## When to invoke this skill

- **Presenter**: filling the dashboard row and snapshot 24 hours before the meeting, or rehearsing for a Deep Dive
- **Discussant**: preparing the hard questions for a Deep Dive
- **Host / Lead PDRA**: choosing the Deep Dive and building the agenda from the dashboard

## Workflow

### 1. Place the project in a stage

| Stage | Name | Typical signal |
|-------|------|----------------|
| 1 | New Pitch | First time the group sees the idea |
| 2 | PoC Results | The 2-week proof of concept has finished |
| 3 | Mid-Project (the grind) | Building, ablating, hitting walls |
| 4 | Pre-Submission | Skeleton Lock or Revision Lock period |
| 5 | Rebuttal | Reviews have arrived |

### 2. Decide Update or Deep Dive

| Stage | Update (5–7 min) | Deep Dive (30 min) |
|-------|------------------|--------------------|
| 1 New Pitch | Minor tweak to an idea already seen | Default: first time the group sees a wild idea |
| 2 PoC | Results confirmed the hypothesis | Results were weird, negative or inconclusive |
| 3 Mid-Project | Track B momentum project on schedule | Track A flagship hitting a mathematical or coding wall |
| 4 Pre-Submission | Final formatting and logistics | Mandatory: the Skeleton Lock interrogation |
| 5 Rebuttal | Reviews are clear accepts | Borderline scores or a lethal critique |

Only one Deep Dive fits per meeting; if two projects qualify, the one with a blocker that the group can unblock wins.

### 3. Write the snapshot (mandatory headings)

Fill only the headings for the project's stage. Each answer is one or two sentences with a number where one exists.

| Stage | Headings |
|-------|----------|
| 1 | The pain point (1 sentence) · The wild factor (High/Med/Low) · PoC goal (e.g. "Beat baseline X on dataset Y by Friday") · The one-sentence idea · The graveyard (who failed before) |
| 2 | Hypothesis vs reality · The signal (e.g. "+15% mAP on preliminary runs") · The risk (e.g. "high variance across seeds") · Resource needs (GPUs) |
| 3 | Current SOTA gap · Figure 1 draft · The wall (the #1 technical blocker) · Current metric vs target (e.g. "85%, target 92%") · Ablation progress |
| 4 | Final evidence (main table) · Figure 1 status (Drafted / Polished / Missing) · The kill-reason (weakest part of the paper) · Reproducibility status · The "so what?" |
| 5 | Meta-reviewer sentiment · The lethal critique · The counter-evidence (experiment or argument) · New experiments run · Pivot strategy |

For stage 1 the full pitch comes from `project-idea-pitch`; for stage 4 the kill-reason comes from `internal-meta-review`.

### 4. Fill the dashboard row

```
| Researcher | Stage (1–5) | Type (Update / Dive) | Status (🟢/🟡/🔴) | The big ask (blocker or decision) |
```

- 🟢 on track, 🟡 at risk, 🔴 blocked or failed.
- The big ask is a question the group can answer or a resource it can provide ("GPU access for final ablations", "pivot or kill after failed PoC"), not a status report.

The dashboard is a live shared document that every theme member updates 24 hours before the meeting; hosts duplicate the template in the lab wiki.

### 5. Predict the discussant questions

The discussant is someone familiar with the area for stages 1, 2, 3 and 5, and any AI researcher for stage 4. Give the presenter these questions plus one project-specific question per stage, each with a suggested answer or "cannot answer yet":

| Stage | Discussant questions |
|-------|----------------------|
| 1 | Is the delta big enough for a top-tier venue? If the week 1–2 PoC fails, do we kill it or pivot? |
| 2 | Is this result luck (seed-picking) or a robust signal? Does this evidence justify moving to Track A? |
| 3 | Are we drifting from the original one-sentence claim? If the wall is not solved in 14 days, what is the fallback? |
| 4 | As Reviewer 2, why do I reject this in the first 5 minutes? Does the data support the abstract's boldest claim? |
| 5 | Which reviewer is our champion and how do we arm them? Is this a fight we can win, or should we withdraw and retarget? |

### 6. Plan the agenda (host)

| Minutes | Block | Content |
|---------|-------|---------|
| 5 | Triage and admin | Review the dashboard, confirm the Deep Dive, lab announcements |
| 30 | Deep Dive | Maximum one; the discussant leads the questioning |
| 20 | Short updates | Two or three projects, 5–7 minutes each: current metric, blocker, what they need. Anything longer goes to a Teams thread or next week's Deep Dive |
| 5 | Assignments | Record the Deep Dive decision (Proceed / Pivot / Kill); assign next meeting's Deep Dive and discussant |

## Anti-patterns

- **Do not** turn a short update into a results tour. An update states the metric, the blocker and the ask; more than seven minutes pushes another project off the agenda.
- **Do not** write a big ask that is not a request ("making progress on ablations"). The dashboard exists so the host can see where the group can help.
- **Do not** let a 🔴 PoC failure go to an Update slot to avoid scrutiny. A failed PoC is the stage-2 Deep Dive case: the group decides pivot or kill.
- **Do not** end a Deep Dive without a recorded decision; an unrecorded "let's see" means the same discussion next fortnight.

## See also

- `project-idea-pitch` for the stage 1 pitch.
- `paper-skeleton-lock` and `internal-meta-review` for stage 4.
- `paper-rebuttal-helper` for stage 5.
