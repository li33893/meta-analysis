# Meta-Analysis of Unguided Self-Help CBT for Adolescent Depressive Symptoms

This repository contains the R scripts and data files for a systematic review and meta-analysis of unguided self-help cognitive behavioural therapy (CBT) interventions for adolescents with depressive symptoms. The project uses a numbered script workflow so that data import, effect size computation, main analysis, follow-up analysis, risk of bias assessment, subgroup analysis, meta-regression, publication bias assessment, and acceptability analysis can be run in a reproducible order.

---

## Project Aim

This meta-analysis evaluates the effectiveness of unguided self-help CBT interventions in reducing depressive symptoms among adolescents. Because adolescents' help-seeking is shaped by developmental, family, school, and access-related constraints, "unguided" is operationaliZed as the absence of human-delivered CBT content. Non-therapeutic contact, such as motivational prompting, technical support, orientation, or reminders, does not disqualify a study.

The review includes RCTs comparing unguided self-help CBT interventions with waitlist, treatment-as-usual, assessment-only, or minimal-contact control conditions.

---

## Research Questions

### Primary Questions

1. What is the post-intervention effect of unguided self-help CBT on adolescent depressive symptoms?
2. Are intervention effects maintained at follow-up?

### Exploratory Questions

Where data are sufficient, the project examines whether effects differ by:

- control type: passive vs. minimally active;
- baseline depression severity: low vs. high;
- presence of human contact during the intervention period;
- inclusion of selected therapeutic components: relaxation, problem-solving, homework;
- number of therapeutic components, examined through meta-regression;
- publication year, examined through post-hoc meta-regression;
- sample size, examined through post-hoc meta-regression.

### Extended Question

How acceptable are unguided self-help CBT interventions?

---

## Methods Overview

| Component | Specification |
|---|---|
| Reporting framework | PRISMA 2020 |
| Study design | Individual RCTs, cluster RCTs, and pilot RCTs |
| Population | Adolescents aged 10–19 with elevated or clinically significant depressive symptoms |
| Intervention | Unguided self-help CBT based on Beck's cognitive model, including cognitive restructuring and at least one behavioural component |
| Comparator | Waitlist, treatment-as-usual, assessment-only, or minimal-contact control |
| Primary outcome | Depressive symptoms measured by validated scales; depression must be a primary or key outcome |
| Included publication types | Peer-reviewed journal articles and dissertations, 1998–2025 |
| Effect size | Hedges' *g* |
| Pooling model | Random-effects meta-analysis using REML estimation and Hartung-Knapp adjustment |
| Effect size computation | Three pathways by `m_type`: (A) raw endpoint means/SDs via `metafor::escalc()`; (B) change scores with SD back-calculated from CI; (C) pre-calculated between-group *d* with SE from CI via `meta::metagen()` |
| Follow-up classification | Short-term: < 3 months; mid-term: 3–6 months; long-term: > 6 months |
| Subgroup analyses | Six analyses: control type, baseline severity, human contact, relaxation, problem-solving, homework; all using `tau.common = TRUE`, REML, and Hartung-Knapp adjustment |
| Meta-regression | Pre-specified: number of CBT components (`component_count`); post-hoc: publication year centred at 2010 and sample size |
| Publication bias | Contour-enhanced funnel plot; Egger's test retained for transparency; Pustejovsky and Rodgers' (2019) SMD-corrected test as the primary asymmetry test; trim-and-fill; 3PSM excluded because *k* < 20 |
| Acceptability | Differential dropout analysed via `meta::metabin()` using Mantel-Haenszel estimation with `MH.exact = TRUE`; random-effects results with REML and Hartung-Knapp adjustment reported alongside fixed-effect results |
| Risk of bias | Cochrane RoB 2.0, visualised with `robvis` |
| Software | R packages: `meta`, `metafor`, `robvis`, `dplyr`, `ggplot2`, `readxl`, `writexl`, `readr`, `janitor`, `tibble` |

---

## Key Analytical Decisions

**Effect-size inputs:** Most studies contributed endpoint SMDs, while three studies contributed change-score SMDs: Ackerson (1998), Makarushka (2011), and Rohde (2015). Although endpoint and change-score estimates are ideally examined separately, a separate change-score synthesis would contain only *k* = 3 studies. The two types were therefore combined in the primary analysis. The Cochrane Handbook §10.5.2 concern is acknowledged, and Ostinelli et al. (2024) is used as field-specific empirical justification because their IPD analysis of iCBT depression trials found no substantive pooled-estimate difference across endpoint, change-score, and mixed SMD approaches.

**Cluster RCT:** Bohr et al. (2023) is a cluster RCT with no ICC reported. It is excluded from the main analysis and included in a sensitivity analysis without ICC correction.

**Baseline severity:** Studies not meeting a validated clinical cutoff at baseline are flagged for sensitivity analysis rather than excluded outright.

**Acceptability:** Four studies have single-arm zero dropout events: Fleming (2012), Ip (2016), Poppelaars (2016), and Smith (2015). The primary acceptability analysis uses `meta::metabin()` with Mantel-Haenszel estimation and `MH.exact = TRUE`, allowing single-zero studies to be retained without applying an arbitrary continuity correction. A sensitivity analysis excluding these four studies is conducted to assess robustness.

**Publication bias:** Pustejovsky and Rodgers' (2019) SMD-corrected test is treated as the primary funnel-asymmetry test because standard Egger's test can produce an artifactual association between SMDs and their standard errors. Egger's test is retained for transparency. The three-parameter selection model is not applied because *k* is below the recommended threshold of 20.

---

## Data Dictionary (`data.xlsx` sheets)

| Sheet | Key Variables |
|---|---|
| `Study_Info` | `study_id`, `author`, `year`, `country`, `program`, `publication_type`, `funding`, `n_rand_exp`, `n_rand_ctrl`, `age_range`, `mean_age`, `pct_female`, `dosage`, `format`, `delivery`, `inclusion_criteria`, `cbt_components`, `control_type`, `support_level`, `baseline_severity`, `recruitment` |
| `Outcome_Data` | `study_id`, `timepoint`, `timing_mo`, `measure`, `m_type`, `sd_type`, pre/post means and SDs, CI bounds, notes |
| `RoB_2.0` | `study_id`, D1–D5 domain judgements, overall judgement, and all justification fields |
| `PRISMA_Flow` | Counts for each PRISMA stage |
| `Exclusion_Log` | Excluded studies and exclusion reasons |

> **Cross-sheet join note:** The `C` column in `Study_Info` becomes `c` after `janitor::clean_names()`. Always rename it with `select(study_id = c, ...)` before joining. Use `inner_join()` with a defensive row-count check, for example `stopifnot(nrow(df) == 14)` when constructing the main post-intervention dataset.

---

## Included Study Records

The table below lists the study records currently documented in the review dataset. The main post-intervention model uses the subset available in `post_data.csv`.

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
| O'Dea et al. | MobiliseMe / ClearlyMe | Australia | 2025 |
| Stallard et al. | BlueIce | UK | 2024 |

> **Cluster RCT note:** Bohr et al. (2023) is not included in the main post-intervention analysis because no ICC was reported. It is retained for sensitivity analysis without ICC correction.

---

## Repository Structure

The project uses a standard directory structure. The main scripts are numbered and should be run in order unless a later script explicitly sources the required earlier scripts.

```text
meta-analysis-project/
│
├── meta-analysis-project.Rproj
├── .gitignore
├── readme.md
│
├── data/
│   ├── data.xlsx                               # Master data file
│   ├── effect_data.csv                         # Computed Hedges' g, all timepoints
│   ├── post_data.csv                           # Post-intervention rows for main analysis
│   ├── fu_short.csv                            # Short-term follow-up rows
│   ├── fu_mid.csv                              # Mid-term follow-up rows
│   ├── fu_long.csv                             # Long-term follow-up rows
│   └── acceptability_dropout_post_data.csv     # Dropout counts for acceptability analysis
│
├── scripts/
│   ├── 00_setup.R                              # Install and load packages
│   ├── 01_read_data.R                          # Import and clean data.xlsx
│   ├── 02_compute_effect_sizes.R               # Compute Hedges' g
│   ├── 03_main_analysis_post.R                 # Main post-intervention analysis
│   ├── 04_followup_analysis.R                  # Follow-up analyses
│   ├── 05_risk_of_bias.R                       # RoB 2.0 visualisation
│   ├── 06_subgroup_analysis.R                  # Six subgroup analyses
│   ├── 07_metaregression.R                     # Pre-specified and post-hoc meta-regression
│   ├── 08_sensitivity.R                        # Sensitivity analyses
│   ├── 09_publication_bias.R                   # Funnel plot and bias diagnostics
│   ├── 10_acceptability.R                      # Differential dropout analysis
│   └── 100_prisma_flow.R                       # PRISMA 2020 flow diagram
│
├── figures/                                    # Output plots, usually 300 dpi PNG
│
├── results/
│   ├── models/                                 # Saved model objects (.rds)
│   └── tables/                                 # Output tables (.csv)
│
└── thesis/
    └── Thesis_Final.docx
```

---

## Getting Started

### Prerequisites

- R ≥ 4.2.0
- RStudio

### Setup and Running

1. **Open the project**

   Open `meta-analysis-project.Rproj` in RStudio. This sets the working directory automatically. Do not use `setwd()`.

2. **Install and load packages**

   Run `00_setup.R` once. It checks whether each required package is already installed before attempting installation, so re-running it on an existing setup is safe.

   ```r
   source("scripts/00_setup.R")
   ```

   Required packages include `meta`, `metafor`, `robvis`, `dplyr`, `tidyverse`, `readxl`, `writexl`, `readr`, `janitor`, and `tibble`.

3. **Run the analysis scripts in order**

   The first full run should follow the numbered workflow:

   ```r
   source("scripts/01_read_data.R")
   source("scripts/02_compute_effect_sizes.R")
   source("scripts/03_main_analysis_post.R")
   source("scripts/04_followup_analysis.R")
   source("scripts/05_risk_of_bias.R")
   source("scripts/06_subgroup_analysis.R")
   source("scripts/07_metaregression.R")
   source("scripts/08_sensitivity.R")
   source("scripts/09_publication_bias.R")
   source("scripts/10_acceptability.R")
   source("scripts/100_prisma_flow.R")
   ```

   From script `03` onwards, individual scripts can also be run separately if they source the required upstream objects.

4. **Check output locations**

   | Output type | Location |
   |---|---|
   | Forest plots, funnel plots, RoB plots, PRISMA diagram | `figures/` |
   | Pooled estimate tables and subgroup summaries | `results/tables/` |
   | Saved model objects | `results/models/` |

5. **Update local paths if needed**

   Some scripts define `figures_dir` and `results_dir` as absolute paths. Update these paths to match your local project directory before running the scripts.

---

## Troubleshooting and Analytical Notes

This section records methodological and coding issues that are easy to forget when rerunning or revising the analysis. Short versions of the same decisions are also listed in **Key Analytical Decisions** above.

### 1. Mixing endpoint and change-score effect sizes

**Problem:** Three studies contributed change-score SMDs rather than endpoint SMDs: Ackerson (1998), Makarushka (2011), and Rohde (2015). Analysing them separately would leave only *k* = 3 change-score studies, making the separate synthesis unstable and any endpoint-versus-change-score subgroup comparison underpowered.

**Methodological concern:** The Cochrane Handbook §10.5.2 and Harrer et al. caution that endpoint and change-score estimates may differ when baseline imbalance, regression to the mean, or inconsistent reporting is present.

**Resolution:** The primary analysis combines endpoint and change-score SMDs. This is justified using Ostinelli et al. (2024, *Research Synthesis Methods*), who analysed individual participant data from 61 iCBT depression trials and found no substantive difference between endpoint-based, change-score-based, and mixed SMD pooling approaches. The Cochrane-level concern should still be acknowledged in the thesis Methods section.

### 2. Single-zero dropout events in the acceptability analysis

**Problem:** Four studies had zero dropout events in one arm: Fleming (2012), Ip (2016), Poppelaars (2016), and Smith (2015). These create single-zero cells in the 2 × 2 dropout tables.

**Why this is not a simple rare-event problem:** Dropout was not rare across the dataset as a whole. Several non-zero studies had substantial dropout rates, and some single-zero studies were not very small, including Ip et al. (2016) with 257 randomised participants and Poppelaars et al. (2016) with 102 randomised participants. The zero cells may therefore reflect study design, follow-up procedures, or reporting conventions rather than only random rarity.

**Resolution:** The primary acceptability analysis uses `meta::metabin()` with Mantel-Haenszel estimation and `MH.exact = TRUE`, retaining single-zero studies without applying an arbitrary continuity correction. A sensitivity analysis excluding the four single-zero studies is run alongside the primary analysis to check whether their inclusion materially changes the pooled estimate.

### 3. Cross-sheet joins return zero rows

**Problem.** Some scripts, such as subgroup analysis and meta-regression, join `effect_data` with `study_info` by `study_id`.

A common source of error is the study ID column in `Study_Info`. In the Excel file, this column is labelled `C`. After `janitor::clean_names()`, it becomes `c`, not `study_id`.

If this column is not renamed before joining, `inner_join()` may return zero rows because it cannot find matching study IDs. This can be easy to miss because `inner_join()` does not necessarily produce an error; it simply returns an empty data frame.

**Fix.** Rename the ID column immediately after reading `Study_Info`:

```r
study_info <- study_info %>%
  dplyr::select(study_id = c, dplyr::everything())
```

After important joins, add a row-count check:

```r
post_data <- effect_data %>%
  dplyr::filter(timepoint == "post") %>%
  dplyr::inner_join(study_info, by = "study_id")

stopifnot(nrow(post_data) == 14)
```

This makes the script stop immediately if the join fails, instead of allowing an empty dataset to flow into later analyses.
The stopifnot turns a silent wrong-answer bug into an immediate, interpretable error.

---
