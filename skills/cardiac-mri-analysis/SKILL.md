---
name: cardiac-mri-analysis
description: Use this skill when the user is working with cardiac MRI data — including segmentation, reconstruction, benchmarking, or active learning for MRI acquisition. Triggers include "segment the left ventricle", "benchmark my cardiac segmentation model", "reconstruct undersampled k-space", "active sampling for MRI", "evaluate on ACDC or UK Biobank", "self-supervised learning for cardiac MRI", or "how do I report Dice for cardiac structures". Handles segmentation evaluation, reconstruction quality, dataset conventions, and active sampling strategies. Do not use for general fairness audits — use fairness-medical-imaging instead.
license: MIT
metadata:
  category: "Domain: Medical Imaging"
  version: "0.1.0"
  author: "VIOS Lab, University of Edinburgh"
---

# Cardiac MRI Analysis

A skill for designing and evaluating computational pipelines for cardiac MRI — covering segmentation, reconstruction, active acquisition, and self-supervised representation learning. VIOS has extensive expertise in cardiac MRI benchmarking (Wang et al., MedIA 2021), active sampling strategies (Du et al., arXiv 2024), and self-supervised learning for MRI.

## When to invoke this skill

- You are training or evaluating a model for cardiac structure segmentation (LV, RV, myocardium)
- You are benchmarking multiple segmentation or reconstruction methods on the same cardiac MRI dataset
- You are designing an active sampling or active learning strategy for MRI acquisition
- You want to apply self-supervised or semi-supervised learning to cardiac MRI with limited labels
- You are evaluating MRI reconstruction quality (e.g., accelerated MRI from undersampled k-space)
- You are writing a cardiac MRI paper and need to know what metrics, splits, and baselines are standard

## Dataset conventions

### ACDC (Automated Cardiac Diagnosis Challenge)

- 150 patients: 30 normal, 30 DCM, 30 HCM, 30 MINF, 30 ARV
- Annotations at end-diastole (ED) and end-systole (ES) frames only
- Structures: LV cavity (left ventricle), myocardium (MYO), RV cavity (right ventricle)
- Train/val/test split: 100 training (with labels), 50 test (labels held by challenge)
- **Do not** create custom splits on ACDC — use the official challenge split or the 80/20 split common in the literature (100 training patients, first 80 for training, last 20 for validation)
- Evaluation metric: **Dice coefficient per structure** (LV, MYO, RV), reported at ED and ES separately and averaged

### UK Biobank

- 40,000+ cardiac MRI studies; annotation campaigns release subsets (∼5,000 annotated)
- Long-axis (LAX) and short-axis (SAX) cines; SAX is the standard for segmentation
- 50 frames per cardiac cycle; annotate all frames only for motion analysis; segmentation work uses ED+ES frames
- Never report results at slice level — aggregate to patient level (per-patient mean Dice, per-patient volumes)
- Protected attributes available (sex, age, BMI, ethnicity) — any model evaluated here should include stratified results (see `fairness-medical-imaging`)

### CMR×Recon (accelerated MRI reconstruction benchmark)

- Multi-coil k-space data; acceleration factors 4×, 8×, 10×
- Evaluation: SSIM, PSNR, NMSE on the reconstructed image (not k-space)
- Report per acceleration factor; do not pool

## Workflow

### 1. Segmentation evaluation

**Standard metric stack:**

| Metric | Structures | Notes |
|--------|-----------|-------|
| Dice coefficient | LV, MYO, RV | Primary metric; report mean ± std per structure |
| Hausdorff distance (HD95) | LV, MYO, RV | Secondary metric; report 95th percentile, not max |
| Volume (mL) | LV, RV | Report end-diastolic volume (EDV), end-systolic volume (ESV) |
| Ejection fraction (EF) | LV, RV | EF = (EDV − ESV) / EDV × 100; compare to reference range |
| Clinical metric correlation | LVEF | Pearson r and Bland-Altman plot vs. manual or echo reference |

**Reporting template:**

```
Results on ACDC (N = 20 validation patients):
              LV Dice    MYO Dice   RV Dice    HD95 (mm)
Model         ED / ES    ED / ES    ED / ES    mean
Ours          x.xx/x.xx  x.xx/x.xx  x.xx/x.xx  x.x
Baseline 1    x.xx/x.xx  x.xx/x.xx  x.xx/x.xx  x.x
```

Always report ED and ES separately — models frequently do well on ED (larger, easier to delineate) but poorly on ES (smaller, harder).

**Apical and basal slice handling:**
Include apical and basal slices in evaluation but note them separately when comparing to papers that exclude them — there is no community consensus. Papers that exclude apical/basal typically report ∼2% higher Dice on LV.

### 2. Active sampling for MRI acquisition (Du et al., arXiv 2024)

Active sampling decides *which* k-space lines to acquire next, given a partial measurement, to maximise reconstruction quality with fewer measurements.

**Design checklist:**
- [ ] Define the acquisition policy: greedy (one line at a time) vs. batch (select B lines jointly)
- [ ] Define the reconstruction model: zero-filled / U-Net / E2E-VarNet — the active policy and reconstruction model must be co-designed or at least co-evaluated
- [ ] Termination criterion: fixed budget (total lines N) or quality threshold (SSIM ≥ 0.90)?
- [ ] Baseline comparisons: uniform random sampling, equidistant sampling, retrospective low-frequency sampling (these are the standard baselines in this literature)
- [ ] Evaluation: SSIM and PSNR at multiple budgets (e.g., 10%, 20%, 30% of k-space acquired); plot SSIM vs. budget curve, not just final performance
- [ ] Cardiac-specific: acquisitions are cardiac-gated; policy must account for breath-hold duration (typically ≤ 15 s per slice)

### 3. Self-supervised and semi-supervised learning

For scenarios with limited annotations (common in cardiac MRI — annotating 50 frames per study is expensive):

**Recommended protocol:**
1. Pre-train on all available unlabelled cardiac cines using self-supervised objective (contrastive, masked image modelling, or motion-based prediction).
2. Fine-tune with N labelled patients. Report performance for N ∈ {1, 5, 10, 20, 100%} to show the label efficiency curve.
3. Baseline: fully supervised model trained on the same N labelled patients without pre-training.
4. Upper bound: fully supervised model trained on all labelled data.

Label efficiency gain = improvement over supervised baseline at N=5 patients. This is the key claim for semi-supervised cardiac MRI papers; report it explicitly.

**Cardiac-specific augmentations** to use during pre-training and fine-tuning:
- Random rotation (±20°) and flipping (cardiac symmetry is not left-right symmetric — flip only for augmentation, not as invariance)
- Intensity scaling (±20%) and Gaussian noise
- Elastic deformation (σ=5-10 pixels) — mimics breath-hold artefact
- Do **not** use aggressive colour jitter or grayscale augmentations — cardiac MRI is greyscale by nature and intensity is clinically meaningful

### 4. MRI reconstruction evaluation

For accelerated MRI reconstruction (from undersampled k-space):

**Metric stack:**
- SSIM (structural similarity) — primary; report per slice, aggregate to volume level
- PSNR — secondary
- NMSE (normalised mean squared error) — required for CMR×Recon leaderboard
- Downstream segmentation Dice — required for clinical validity (a visually good reconstruction that degrades segmentation is not clinically acceptable)

**Acceleration factor reporting:**
Always report separately for each acceleration factor. Do not report averaged across factors — the relationship between quality and acceleration is non-linear.

**Undersampling mask:**
Report the mask pattern (equidistant, random, Poisson disc). Results are not comparable across mask patterns. If comparing to prior work, use identical masks.

### 5. Benchmarking protocol

When comparing multiple methods on the same cardiac MRI dataset (Wang et al., MedIA 2021 benchmarking approach):

1. Fix all hyperparameters using a separate held-out validation set — never tune on the test set.
2. Run each method 3× with different seeds; report mean ± std.
3. Statistical testing: Wilcoxon signed-rank test (per-patient paired comparison) with Bonferroni correction for multiple comparisons.
4. Include a detailed supplementary with per-patient Dice distributions (violin or box plot), not just mean ± std — cardiac anatomy varies significantly across patients.

## Anti-patterns

- **Do not** report only mean Dice without per-structure breakdown — RV is the hardest structure and papers that pool LV/MYO/RV are hiding RV failures behind strong LV/MYO performance.
- **Do not** split at the slice level when the protected attribute or label is at the patient level — slice-level splitting leaks patient identity across train/test and inflates all metrics by approximately 3–5% Dice.
- **Do not** skip the Bland-Altman plot when claiming clinical-level agreement on volume or ejection fraction — AUC or Dice alone cannot confirm clinical equivalence.
- **Do not** compare reconstruction SSIM across different undersampling masks or acceleration factors without noting the mask explicitly — the same model can differ by 0.05 SSIM depending on the mask pattern.
- **Do not** claim self-supervised pre-training helps without reporting the full label efficiency curve — a method that only works at N≥50 annotated patients is not practically useful in cardiac MRI.

## See also

- `fairness-medical-imaging` for stratified evaluation by sex, age, or scanner model on UK Biobank data.
- `medical-image-synthesis` for data augmentation or counterfactual generation to address training data scarcity in cardiac MRI.
- `venue-reviewer` for MICCAI and Medical Image Analysis submission requirements.
