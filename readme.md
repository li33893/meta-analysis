# Meta-Analysis of Unguided Self-Help CBT for Adolescent Depressive Symptoms

This repository contains the R scripts and data files for a systematic review and meta-analysis on unguided self-help cognitive behavioural therapy (CBT) interventions for adolescents with depressive symptoms. The analysis follows a numbered script workflow so that data import, effect size computation, main analysis, follow-up analysis, risk of bias assessment, subgroup analysis, meta-regression, publication bias assessment, and acceptability analysis can be run in a reproducible order.

---

## Project Aim

This meta-analysis evaluates the effectiveness of unguided self-help CBT interventions in reducing depressive symptoms among adolescents, considering unique ecological feature in help-seeking around this age. "Unguided" is therefore operationalized as: no human delivers CBT content, and motivational prompting or technical support does not disqualify a study. The review includes RCTs comparing such interventions with waitlist, treatment-as-usual, assessment-only, or minimal-contact control conditions.

---

## Research Questions

### Primary Questions
1. What is the overall feature of, post-intervention effect of unguided self-help CBT on adolescent depressive symptoms?
2. Are intervention effects maintained at follow-up?
3. How acceptable are unguided self-help CBT interventions, as reflected by differential dropout rates between conditions?

### Exploratory Questions
Where data are sufficient, the project examines whether effects differ by:
- Control type (passive vs. minimally active)
- Baseline depression severity (low vs. high)
- Presence of human contact during the intervention period
- Inclusion of certain certain therapeutic component (relaxation, problem-solving, homework)
- Number of therapeutic components (meta-regression)
- Publication year (post-hoc meta-regression)
- Sample size (post-hoc meta-regression)
---

## Methods Overview

| Component | Specification |
|---|---|
| Reporting framework | PRISMA 2020 |
| Study design | Individual RCTs, cluster RCTs (with ICC correction), and pilot RCTs |
| Population | Adolescents aged 10–19 with elevated or clinically significant depressive symptoms |
| Intervention | Unguided self-help CBT (Beck's cognitive model + cognitive restructuring + ≥1 behavioural component) |
| Comparator | Waitlist, treatment-as-usual, assessment-only, or minimal-contact control |
| Primary outcome | Depressive symptoms measured by validated scales; depression must be a primary or key outcome |
| Included publication types | Peer-reviewed journal articles and dissertations (1998–2025) |
| Effect size | Hedges' *g* |
| Pooling model | Random-effects meta-analysis, REML estimator, Hartung-Knapp adjustment |
| Effect size computation | Three pathways by `m_type`: (A) raw endpoint means/SDs via `metafor::escalc()`; (B) change scores with SD back-calculated from CI; (C) pre-calculated between-group *d* with SE from CI via `meta::metagen()` <br> * Justified by Ostinelli et al. (2024, *Research Synthesis Methods*), who demonstrated no substantive difference in pooled SMD for depression across 61 iCBT IPD studies|
| Follow-up classification | Short-term: < 3 months; mid-term: 3–6 months; long-term: > 6 months |
| Subgroup analyses | Six analyses: control type, baseline severity, human contact, relaxation, problem-solving, homework; all with `tau.common = TRUE` + REML + HK |
| Meta-regression | (1) Pre-specified: number of CBT components (`component_count`); (2) Post-hoc: publication year (centred at 2010) and Sample size |
| Publication bias | Contour-enhanced funnel plot; Egger's test (retained for transparency); Pustejovsky & Rodgers (2019) bias-corrected test (primary, mandatory for SMD); trim-and-fill; 3PSM excluded (*k* < 20 threshold) |
| Acceptability | Differential dropout analysed via `meta::metabin()` with Mantel-Haenszel method (`MH.exact = TRUE`); REML + HK random-effects reported alongside fixed-effect|
| Risk of bias | Cochrane RoB 2.0; visualised with `robvis` |
| Software | R (`meta`, `metafor`, `robvis`, `dplyr`, `ggplot2`, `readxl`, `writexl`, `janitor`) |

---

## Repository Structure

All files are stored in a flat working directory (no subdirectory nesting). Files are organised by type below for clarity.

```text
meta-analysis-project/
│
├── meta-analysis-project.Rproj
├── .gitignore
├── readme.md
│
├── data/                              # Raw and processed data files
│   ├── data.xlsx                      # Master data (sheets: Study_Info, Outcome_Data,
│   │                                  #   RoB_2.0, PRISMA_Flow, Exclusion_Log)
│   ├── effect_data.csv                # Computed Hedges' g, all timepoints (output of 02)
│   ├── post_data.csv                  # Post-intervention rows, k = 14 (output of 02/03)
│   ├── fu_short.csv / fu_mid.csv / fu_long.csv   # Follow-up rows by window (output of 04)
│   └── acceptability_dropout_post_data.csv        # Dropout counts (output of 10)
│
├── scripts/                           # Numbered R scripts; run in order
│   ├── 00_setup.R                     # Install and load packages
│   ├── 01_read_data.R                 # Import data.xlsx, clean names, type conversion
│   ├── 02_compute_effect_sizes.R      # Compute Hedges' g (pathways A/B/C)
│   ├── 03_main_analysis_post.R        # Main post-intervention analysis (k = 14)
│   ├── 04_followup_analysis.R         # Follow-up analyses (short / mid / long)
│   ├── 05_risk_of_bias.R              # RoB 2.0 visualisation via robvis
│   ├── 06_subgroup_analysis.R         # Six subgroup analyses
│   ├── 07_metaregression.R            # Pre-specified and post-hoc meta-regression 
|   ├── 08_sensitivity.R               # Sensitivity analyses
│   ├── 09_publication_bias.R          # Funnel, Egger's, Pustejovsky & Rodgers, trim-and-fill
│   ├── 10_acceptability.R             # Differential dropout (metabin, MH)
│   └── 100_prisma_flow.R              # PRISMA 2020 flow diagram
│
├── figures/                           # All output plots (300 dpi PNG)
│
├── results/
│   ├── models/                        # Saved model objects (.rds)
│   └── tables/                        # Output tables (.csv)
│
└── thesis/                            # Thesis documents
    └── Thesis_Final.docx
```

---

Getting Started
Prerequisites

R ≥ 4.2.0 (download)
RStudio (download)

Setup and Running
1. Open the project
Open meta-analysis-project.Rproj in RStudio. This sets the working directory automatically — do not use setwd().
2. Install and load packages
Run 00_setup.R once. It checks whether each required package is already installed before attempting installation, so re-running it on an existing setup is safe.
rsource("scripts/00_setup.R")
Required packages: meta, metafor, robvis, dplyr, tidyverse, readxl, writexl, readr, janitor, tibble.
3. Run the analysis scripts in order
Each script from 02 onwards sources 02_compute_effect_sizes.R at the top, so scripts can also be run independently. The first time through, run them in sequence:
rsource("scripts/01_read_data.R")
source("scripts/02_compute_effect_sizes.R")
source("scripts/03_main_analysis_post.R")
source("scripts/04_followup_analysis.R")
source("scripts/05_risk_of_bias.R")
source("scripts/06_subgroup_analysis.R")
# source("scripts/07_metaregression.R")   # to be created
source("scripts/09_publication_bias.R")
source("scripts/10_acceptability.R")
source("scripts/100_prisma_flow.R")
4. Output locations
Output typeLocationForest plots, funnel plot, RoB plots, PRISMA diagramfigures/Pooled estimate tables, subgroup summaryresults/tables/Saved model objects (.rds)results/models/
5. Absolute paths
Each script defines figures_dir and results_dir as absolute paths at the top. Update these to match your local directory before running.
---

## Key Analytical Decisions

**Effect size mixing:** Three studies contribute change-score SMDs rather than endpoint SMDs. Mixing is justified by Ostinelli et al. (2024), who found no substantive pooled-estimate difference across both types in a large iCBT depression IPD dataset. Cochrane Handbook §10.5.2 concern is acknowledged.

**Cluster RCT:** Bohr et al. (2023) is a cluster RCT with no ICC reported; it is excluded from the main analysis and included in a sensitivity analysis without ICC correction.

**Baseline severity:** Studies not meeting a validated clinical cutoff at baseline are flagged for sensitivity analysis rather than excluded outright.

**Acceptability:** Four studies have single-arm zero dropout events (Fleming 2012, Ip 2016, Poppelaars 2016, Smith 2015). Primary analysis uses `MH.exact = TRUE` to handle zero cells without continuity correction (Harrer et al.). A sensitivity analysis excludes these four studies.

**Publication bias:** Pustejovsky & Rodgers (2019) is the primary test because standard Egger's test produces an artifactual correlation between *g* and SE for SMD-type effect sizes. Egger's is retained for transparency. 3PSM requires *k* ≥ 20 and is not applicable here (*k* = 14).

---

## Data Dictionary (data.xlsx sheets)

| Sheet | Key Variables |
|---|---|
| Study_Info | study_id, author, year, country, program, publication_type, funding, n_rand_exp, n_rand_ctrl, age_range, mean_age, pct_female, dosage, format, delivery, inclusion_criteria, cbt_components, control_type, support_level, baseline_severity, recruitment |
| Outcome_Data | study_id, timepoint, timing_mo, measure, m_type, sd_type, pre/post means and SDs, CI bounds, notes |
| RoB_2.0 | study_id, D1–D5 domain judgements, overall judgement, all justification fields |
| PRISMA_Flow | Counts for each PRISMA stage |
| Exclusion_Log | Excluded studies with reasons |

> **Cross-sheet join note:** The `C` column in Study_Info becomes `c` after `janitor::clean_names()`. Always rename with `select(study_id = c, ...)` and use `inner_join` with a defensive `stopifnot(nrow(df) == 14)` assertion.

---

## Included Studies (k = 14 main analysis)

| Study | Program | Country | Year |
|---|---|---|---|
| Ackerson et al. | Workbook CBT | USA | 1998 |
| Fleming et al. | SPARX | New Zealand | 2012 |
| Stice et al. | Feeling Good | USA | 2008 |
| Makarushka | Blueblaster | UK | 2011 |
| Merry et al. | SPARX | New Zealand | 2012 |
| Stasiak et al. | The Journey | New Zealand | 2014 |
| Ip et al. | CatchIt | Hong Kong | 2016 |
| Poppelaars et al. | SPARX | Netherlands | 2016 |
| Ranney et al. | iDove | USA | 2018 |
| O'Dea et al. | Weclick | Australia | 2020 |
| Smith et al. | Stressbusters | UK | 2015 |
| Rohde et al. | Feeling Good | USA | 2015 |
| Wright et al. | Stressbusters | UK | 2020 |
| O'Dea et al. | MobiliseMe/ClearlyMe | Australia | 2025 |
| Stallard et al. | BlueIce | UK | 2024 |

> Bohr et al. (2023) — cluster RCT, no ICC; excluded from main analysis, included in sensitivity analysis.

---
Troubleshooting
1. Mixing endpoint and change-score SMDs
Problem. Three studies (Makarushka 2011, Rohde 2015, Ackerson 1998) report change scores rather than endpoint means and SDs. The natural approach is to synthesise the two types separately. However, this produces a subgroup of k = 3 change-score studies against k = 11 endpoint studies. Both Cochrane Handbook §10.5.2 and Harrer et al. Doing Meta-Analysis with R explicitly caution against mixing the two types in the same pooled estimate, citing potential bias from baseline imbalance and differential regression to the mean. At the same time, k = 3 is too small to support a separate synthesis — a two-group comparison would have almost no power to detect a difference even if one existed.
Resolution. Ostinelli et al. (2024, Research Synthesis Methods) directly tested this question using individual participant data from 61 iCBT depression trials. They found no substantive difference in pooled SMD estimates when endpoint and change-score studies were analysed together versus separately, even under baseline imbalance. This provided the field-specific empirical justification needed to proceed with mixing. The decision is disclosed in the Methods section with a citation to Ostinelli et al., and the Cochrane principle-level concern is acknowledged.

2. Single-zero dropout events and acceptability analysis
Problem. Four studies (Fleming 2012, Ip 2016, Poppelaars 2016, Smith 2015) have zero dropout events in one arm, producing zero cells in the 2×2 dropout table. The standard response in meta-analysis is to treat zero cells as evidence of rare events and apply either a continuity correction (add 0.5) or Peto OR. Neither was appropriate here.
On closer inspection, the zero-event studies are not uniformly small: Ip et al. (2016) randomised 257 participants and Poppelaars et al. (2016) randomised 102. Zero dropout in one arm of a 257-person trial is not a rare-event problem — it reflects a design or reporting feature. Furthermore, the studies with non-zero dropout in both arms showed substantial dropout rates (some exceeding 30%), which means dropout is not a rare event across the dataset as a whole. The dataset presents an unusual combination: a high single-zero proportion (4/14 studies, 29%) alongside high overall dropout rates — a situation that does not fit the classical rare-event framework described in Cochrane Handbook §10.4.4.
Finding a solution. Working through this required filtering a large number of online resources, most of which turned out to be commercial statistics consulting advertisements rather than methodological guidance. After considerable searching, a genuinely useful and detailed solution was found in a post by a medical student at Peking University, who provided a free and thorough walkthrough of the zero-cell problem in binary-outcome meta-analysis with no commercial motive. The core recommendation aligned with Harrer et al.: use metabin() with MH.exact = TRUE, which implements an exact Mantel-Haenszel method that handles single-zero cells correctly without a continuity correction. A sensitivity analysis excluding the four zero-event studies runs alongside the primary analysis to confirm that their inclusion does not materially change the estimate.


