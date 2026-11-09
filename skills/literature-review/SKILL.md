---
name: literature-review
description: Use this skill when the user asks to find, screen, summarise, or synthesise academic literature on a topic. Triggers include "find papers on X", "literature review of X", "what does the field say about X", "summarise these arXiv links", or providing a list of DOIs/arXiv IDs. Handles search-term decomposition, multi-source triage (arXiv, PubMed, OpenAlex, Semantic Scholar), screening for relevance and quality, and structured synthesis with proper citations.
license: MIT
metadata:
  category: "Reading & Analysis"
  version: "0.1.0"
  author: "VIOS Lab, University of Edinburgh"
---

# Literature Review

This skill helps construct rigorous, well-cited literature reviews for AI, causality, and medical-imaging research. It is designed to avoid the two main failure modes of LLM-driven literature work: (1) fabricated citations, and (2) shallow summarisation that misses methodological context.

## When to invoke this skill

Activate when the user's request involves any of:

- Surveying a research area ("what's the state of the art in X?")
- Comparing methods ("how do A and B differ in their approach to Y?")
- Triaging a list of papers (DOIs, arXiv IDs, or PDFs)
- Identifying gaps for a related-work section
- Preparing background for a rebuttal or grant

Do **not** invoke this skill for casual factual questions answerable from general knowledge — overhead is wasted.

## Workflow

### 1. Clarify the scope

Before searching, confirm with the user:
- The specific research question (not just a topic).
- Time window (e.g. last 5 years, foundational works, or both).
- Domain constraints (e.g. only medical-imaging applications, only causal-inference theory).
- Output format expected (annotated bibliography, prose synthesis, comparison table, related-work paragraph).

### 2. Decompose into search terms

Generate 3–6 distinct query phrasings. Cover:
- The canonical term and its synonyms.
- Adjacent or competing terms (e.g. "concept erasure" + "machine unlearning" + "model editing").
- A "broad" and a "narrow" framing.

Show the user the search-term list and let them refine before executing.

### 3. Triage sources

Prefer in this order:
- **arXiv** for ML/AI preprints.
- **OpenAlex / Semantic Scholar** for citation graphs and impact signals.
- **PubMed** for medical-imaging clinical work.
- **PMC** when full-text matters for synthesis.

If web search is available, use it; if not, ask the user to paste results from the relevant database.

### 4. Screen for inclusion

For each candidate paper, capture:
- Title, authors, year, venue, DOI/arXiv ID.
- A one-sentence factual contribution claim (not a marketing summary).
- Method family (so the user can group later).
- A relevance score 1–3 with justification.

Discard 1s without asking. Surface 2s for user confirmation. Keep 3s.

### 5. Synthesise

When summarising:
- Group papers by *method* or *finding*, not by chronology, unless the user asks for a historical survey.
- Quote the contribution claim verbatim only if under 15 words; otherwise paraphrase.
- Flag disagreements between papers explicitly ("X claims A; Y claims not-A under condition Z").
- Cite every claim with the paper's identifier (BibTeX key if known, else arXiv ID).
- Note when *the field* lacks a finding ("no consensus on X" is a valid output).

### 6. Output

Default output format is an annotated bibliography unless the user specified otherwise. End with:
- A 3–5 sentence "what's missing" paragraph (gaps in the field).
- A list of papers you considered but excluded, with reasons.

## Anti-patterns

- **Do not** fabricate citations. If you can't find the paper, say so.
- **Do not** synthesise from titles and abstracts alone if the user asked for methodological comparison — request the user to paste the relevant sections.
- **Do not** produce a wall of paraphrased abstracts. Synthesis means grouping and contrasting, not concatenating.

## Examples of good invocations

- "Find recent work on concept erasure in diffusion models and tell me what evaluation metrics the field uses."
- "Here are 12 arXiv links. Triage them for relevance to causal mediation analysis in clinical imaging."
- "Draft a related-work paragraph on adversarial robustness of T2I models, ~150 words, in NeurIPS style."

## See also

- `paper-rebuttal-helper` for using literature in reviewer responses.
- `arxiv-digest` for periodic monitoring of a research area.
