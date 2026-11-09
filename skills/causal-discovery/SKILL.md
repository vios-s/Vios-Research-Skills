---
name: causal-discovery
description: Use this skill when the user wants to learn or infer causal structure from data — rather than assuming a known DAG. Triggers include "discover causal structure from data", "learn a causal graph", "which algorithm should I use for causal discovery", "PC algorithm or GES", "run FCI on my dataset", "test for causal directions", "does my data have hidden confounders", or "evaluate my causal discovery result". Handles algorithm selection, faithfulness and Markov assumptions, evaluation against ground truth, and limitations of discovery from observational data. Do not use when the DAG is already specified — use causal-dag-builder instead.
license: MIT
metadata:
  category: "Domain: Causality"
  version: "0.1.0"
  author: "VIOS Lab, University of Edinburgh"
---

# Causal Discovery

A skill for learning causal graph structure from data — selecting the right algorithm, diagnosing assumption violations, and evaluating results. This is distinct from `causal-dag-builder`, which starts from a user-specified DAG; here the goal is to *infer* the DAG from observations, experiments, or a combination.

## When to invoke this skill

- You have observational (or experimental) data and want to recover the underlying causal graph
- You need to choose between constraint-based (PC, FCI), score-based (GES, NOTEARS), or hybrid (GFCI) algorithms
- You want to test whether a proposed causal structure is consistent with the data
- Your dataset may contain latent confounders and you need a method that handles them (FCI, RFCI)
- You want to evaluate a discovered graph against a known ground-truth DAG (simulation study or benchmark)
- You are combining causal discovery with downstream inference and need to propagate discovery uncertainty

## Background: what causal discovery can and cannot do

**What it can do:**
- Recover the Markov Equivalence Class (MEC) of the true DAG from purely observational data under faithfulness + Markov conditions
- Identify some edge directions from conditional independence tests (v-structures)
- With interventional data, further orient edges beyond the MEC
- Detect the presence of latent confounders (FCI outputs PAGs, not DAGs)

**What it cannot do:**
- Uniquely identify a single DAG from observational data alone in general — only the MEC (a CPDAG/PAG)
- Guarantee correctness when faithfulness is violated (rare in theory, common in finite samples)
- Scale to thousands of variables without strong sparsity assumptions

Always communicate this to stakeholders: causal discovery returns a *candidate structure*, not a proven causal graph.

## Workflow

### 1. Pre-discovery checklist

Before running any algorithm, answer:

- [ ] **Sample size**: N < 500 → constraint-based methods are unreliable; prefer score-based or use domain knowledge to restrict the search space.
- [ ] **Variable types**: continuous (Gaussian or non-Gaussian), discrete, or mixed? This determines valid independence tests and score functions.
- [ ] **Latent confounders**: is it plausible that unmeasured common causes exist? If yes, use FCI/RFCI, not PC/GES (which assume causal sufficiency).
- [ ] **Prior knowledge**: do you have any known forbidden or required edges (e.g., time ordering, known biology)? These can be encoded as background knowledge to constrain the search.
- [ ] **Interventional data available**: if any variables were experimentally manipulated, flag which observations are interventional — some algorithms (GIES, JCI) exploit this.

### 2. Algorithm selection

| Setting | Recommended algorithm | Key assumption | Output |
|---------|----------------------|---------------|--------|
| Continuous, Gaussian, causally sufficient, large N | PC | Faithfulness, Markov, causal sufficiency | CPDAG |
| Continuous, Gaussian, causally sufficient, any N | GES | Faithfulness, Markov, causal sufficiency, score decomposability | CPDAG |
| Latent confounders plausible | FCI / RFCI | Faithfulness, Markov | PAG |
| Non-Gaussian continuous (e.g. linear non-Gaussian) | LiNGAM | Linear, non-Gaussian noise | Full DAG |
| Additive noise, non-linear | ANM / RESIT | Additive noise model | Full DAG |
| Large-scale, differentiable | NOTEARS / DAG-GNN | Acyclicity constraint via continuous optimisation | DAG |
| Mixed interventional + observational | GIES / JCI | Faithfulness, known intervention targets | I-CPDAG |

**For medical imaging and biological data**: prefer FCI (latent confounders are almost always plausible — unmeasured genetic, environmental, or demographic variables exist). Use PC only when you can argue causal sufficiency (rare in practice).

**For time-series**: use Granger causality or PCMCI (Runge et al.) — standard cross-sectional discovery algorithms assume i.i.d. data.

### 3. Independence test and score selection

**For PC/FCI (constraint-based):**

| Data type | Independence test | Notes |
|-----------|------------------|-------|
| Gaussian continuous | Fisher's Z (partial correlation) | Fast; assumes linearity |
| Non-Gaussian continuous | KCI (kernel CI test) | Slow but non-parametric; use for N < 1000 |
| Discrete | G² or χ² | Requires sufficient cell counts |
| Mixed | Mixed CI test (e.g., RCIT) | Active research area; interpret with caution |

**For GES/GIES (score-based):**
- Gaussian BIC score for continuous Gaussian data
- BDeu score for discrete data
- Report the chosen significance level α (for constraint-based) or BIC penalty coefficient (for score-based) — results are sensitive to these hyperparameters.

### 4. Running the algorithm and interpreting output

**CPDAG (output of PC/GES for causally sufficient data):**
- Directed edges (→) are oriented consistently across the MEC
- Undirected edges (—) could go either way — the data cannot distinguish them
- Do **not** arbitrarily orient undirected edges for downstream inference; instead use the identifiable edges only, or perform sensitivity analysis over orientations

**PAG (output of FCI):**
- Circle endpoints (○—) indicate possible adjacency due to latent confounders
- Tail endpoints (◄—) indicate definite non-ancestry
- Report which edges are "definitely causal" vs. "possibly causal" separately in any publication

**Visualisation:**
Always plot the output graph. Use the `causal-dag-builder` skill to annotate and validate the discovered structure against domain knowledge.

### 5. Evaluation against ground truth (simulation studies)

When evaluating a discovery algorithm on simulated data with a known DAG:

| Metric | Definition | Notes |
|--------|-----------|-------|
| SHD (Structural Hamming Distance) | Number of edge additions, deletions, reversals needed to convert output to truth | Primary metric |
| F1 on skeleton | F1 over presence/absence of edges (ignoring direction) | Separates adjacency from orientation errors |
| F1 on CPDAG edges | F1 over directed edges in the ground-truth CPDAG | Measures orientation accuracy |
| False Discovery Rate (FDR) | False edges / all reported edges | Report alongside F1 |

Run over multiple random seeds and DAG samples from the same generating distribution. Report mean ± std. Never report a single run.

**Common confound in benchmarks**: algorithms with more edges (lower α) always have higher recall and lower precision. Compare at matched skeleton F1, not just at default hyperparameters.

### 6. Discovery uncertainty propagation

When using a discovered graph for downstream causal inference (e.g., estimating a causal effect):

1. If the output is a CPDAG with undirected edges on the path of interest: run inference under all orientations consistent with the CPDAG and report the range of estimates as a sensitivity bound.
2. If using FCI output: flag that effect estimates are not identifiable in PAGs without additional assumptions.
3. Do **not** treat a discovered graph as ground truth for identification — always report discovery-induced uncertainty alongside estimation uncertainty.

## Anti-patterns

- **Do not** run PC on data with latent confounders and report a DAG — PC assumes causal sufficiency; if this is violated, the output is biased. Use FCI instead.
- **Do not** arbitrarily orient the undirected edges in a CPDAG to make effect identification easier — this introduces false causal claims. Report what is and is not identified.
- **Do not** report only SHD without specifying the comparison (vs. true DAG or true CPDAG) — SHD against the DAG penalises correct MEC orientations as errors.
- **Do not** run discovery on a dataset and then use the same dataset for effect estimation without correction — this double-dipping inflates confidence in estimated effects.
- **Do not** choose the independence test or α after seeing the output to get a "better-looking" graph — preregister or clearly justify hyperparameter choices before running.

## See also

- `causal-dag-builder` for working with a known or user-specified DAG — identification, adjustment set selection, Mermaid visualisation.
- `fairness-medical-imaging` for causal discovery applied to detecting protected-attribute confounding in medical imaging models.
- `research-question-framing` for stating a falsifiable causal hypothesis before running discovery.
