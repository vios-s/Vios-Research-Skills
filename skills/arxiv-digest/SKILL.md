---
name: arxiv-digest
version: 0.1.0
author: VIOS Lab, University of Edinburgh
license: MIT
description: >-
  Use this skill when the user wants to monitor or summarise recent arXiv
  activity in a specific research area. Triggers include "what's new on arXiv
  this week in X", "summarise today's arXiv in cs.LG".
---

# Arxiv Digest

A skill for producing focused, signal-dense digests of recent arXiv activity in a research area. Designed for the working researcher who wants to skim 50 new preprints in 5 minutes and flag the 3 worth reading properly.

## When to invoke this skill

* Daily/weekly digest requests for a specific category (e.g. `cs.LG`, `eess.IV`, `stat.ME`).
* Topic-based monitoring across categories ("anything new on diffusion-model unlearning").
* Bulk triage of an existing arXiv search results page.

Do not invoke for a single-paper deep read — that's the `paper-reader-heilmeier` skill's job.

## Workflow

### 1. Confirm the digest scope

Ask the user once (and cache for future runs in the conversation):

* Category or categories.
* Topic filter (keywords / author names / methods).
* Time window (last 24h, last 7 days, since last digest).
* Digest length: brief (5 papers, one-liners), standard (10–15 papers, short summaries), exhaustive (everything matched, longer summaries).

### 2. Fetch

Use arXiv's listing endpoints or the user's saved arXiv search/RSS URL. If no fetch tool is available, ask the user to paste the listing page.

### 3. Triage each paper

For every paper, capture:

* arXiv ID, title, primary authors (first + last), submission date.
* A one-line "what they actually did" (not the abstract — the _contribution_).
* Method family.
* A 1–3 relevance score against the user's topic filter, with one-clause justification.

### 4. Output

Default digest format:

```
## arXiv Digest — {date} — {topic}

### High relevance (3)
- **[2511.12345] Title** (Smith et al.) — One-line contribution. *Why it matters:* …

### Medium relevance (2)
- …

### Low relevance / out-of-scope (1)
- (collapsed list, just IDs and titles)
```

End the digest with:

* A 2–3 sentence "trends" paragraph spotting any clusters of method or topic.
* A list of papers worth deep reading (link to `paper-reader-heilmeier`).

## Anti-patterns

* **Do not** rephrase abstracts verbatim. The point of a digest is signal compression.
* **Do not** include every paper at standard length — the user has a budget.
* **Do not** invent submission dates or author names. If unsure, mark the field as unknown.

## Scheduling (advanced)

If invoked in an environment that supports recurring runs (cron, GitHub Actions, lab server), output a config block the user can save:

```yaml
arxiv_digest:
  categories: [cs.LG, cs.CV, cs.AI]
  topic_filter: ["diffusion", "concept erasure", "unlearning"]
  time_window: 7d
  length: standard
  delivery: email | markdown_file | slack
```

## See also

* `literature-review` for deeper synthesis after the digest flags something.
* `paper-reader-heilmeier` for full-paper analysis of flagged items.
