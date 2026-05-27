# Meta-Analysis of Unguided Self-Help CBT for Adolescent Depressive Symptoms

This repository contains the R scripts and data files for a systematic review and meta-analysis of unguided self-help cognitive behavioural therapy (CBT) interventions for adolescents with depressive symptoms. The project uses a numbered script workflow so that data import, effect size computation, main analysis, follow-up analysis, risk of bias assessment, subgroup analysis, meta-regression, publication bias assessment, and acceptability analysis can be run in a reproducible order.

---

## Project Aim

This meta-analysis evaluates the effectiveness of unguided self-help CBT interventions in reducing depressive symptoms among adolescents. Because adolescents' help-seeking is shaped by developmental, family, school, and access-related constraints, "unguided" is operationalized as the absence of human-delivered CBT content. Non-therapeutic contact, such as motivational prompting, technical support, orientation, or reminders, does not disqualify a study.

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
| Acceptability | Differential dropout analysed via meta::metabin() (risk ratio). Primary estimate is the random-effects RR (inverse-variance pooling, REML, Hartung-Knapp), consistent with the main analysis; the Mantel-Haenszel common-effect estimate (MH.exact = TRUE) is reported alongside it |
| Risk of bias | Cochrane RoB 2.0, visualised with `robvis` |
| Software | R packages: `meta`, `metafor`, `robvis`, `dplyr`, `ggplot2`, `readxl`, `writexl`, `readr`, `janitor`, `tibble` |

---

## Key Analytical Decisions

**Effect-size inputs:** Most studies contributed endpoint SMDs. Of the 14 studies, 11 contributed endpoint means and SDs (computed via `escalc()`), and one, O'Dea (2025), contributed a pre-calculated between-group *d* with its standard error derived from the reported CI; both are endpoint-type effects. Two studies contributed change-score SMDs: Stallard (2024) and Fleming (2012). Because a separate change-score synthesis would contain only *k* = 2 studies, endpoint-type and change-score effects were combined in the primary analysis. The Cochrane Handbook §10.5.2 concern about mixing endpoint and change-score SMDs is acknowledged, and Ostinelli et al. (2024) is used as field-specific empirical justification: their IPD analysis of 61 iCBT depression trials found no substantive pooled-estimate difference across endpoint-based, change-score-based, and mixed SMD approaches.

**Cluster RCT:** Bohr et al. (2023) is a cluster RCT with no ICC reported. It is excluded from the main analysis and included in a sensitivity analysis without ICC correction.

**Baseline severity:** Studies not meeting a validated clinical cutoff at baseline are flagged for sensitivity analysis rather than excluded outright.

**Acceptability:** Three studies have single-arm zero dropout events: Ip (2016), Poppelaars (2016), and Smith (2015). The primary acceptability estimate is the random-effects risk ratio (inverse-variance pooling, REML between-study variance, Hartung-Knapp adjustment), consistent with the main SMD analysis. The Mantel-Haenszel common-effect estimate (method = "MH", MH.exact = TRUE) is reported alongside it. MH.exact = TRUE avoids a continuity correction in the Mantel-Haenszel common-effect row; the inverse-variance random-effects estimate still applies the default 0.5 correction to the single-zero studies, which is why excluding them and re-running with an alternative correction (RR.Cochrane = TRUE) are reported as sensitivity analyses.

**Publication bias:** Pustejovsky and Rodgers' (2019) SMD-corrected test is treated as the primary funnel-asymmetry test because standard Egger's test can produce an artifactual association between SMDs and their standard errors. Egger's test is retained for transparency. The three-parameter selection model is not applied because *k* is below the recommended threshold of 20.

---

## Data Dictionary (`data.xlsx` sheets)

| Sheet | Key Variables |
|---|---|
| `Study_Info` | `C` (renamed to `study_id` in R), `Author`, `Year`, `Country`, `Program`, `N_rand_exp`, `N_rand_ctrl`, `Age_range`, `Mean_age`, `%Female`, `Recruitment`, `Inclusion_criteria`, `Outcome_measure`, `CBT_components`, `Control_type`, `Support_level`, `Dosage`, `dose_intensity_total`, `human_contact`, `component_count`, `Format`, `Delivery`, `Baseline_severity`, `Publication_type`, `Funding`, `Notes` |
| `Outcome_Data` | `Study_ID`, `Author`, `Timepoint`, `Timing_mo`, `N_exp`, `N_ctrl`, `Pre_M_exp`, `Pre_SD_exp`, `Pre_M_ctrl`, `Pre_SD_ctrl`, `M_exp`, `SD_exp`, `M_ctrl`, `SD_ctrl`, `Measure`, `M_type`, `SD_type`, `CI_lower_exp`, `CI_upper_exp`, `CI_lower_ctrl`, `CI_upper_ctrl`, `change_mean_exp`, `change_mean_ctrl`, `CI_lower_between`, `CI_upper_between`, `reported_d_between`, `TE`, `seTE`, `N_dropout_exp`, `N_dropout_ctrl`, `Notes` |
| `RoB_2.0` | `Study ID`, `Author (Year)`, D1–D5 judgement columns, D1–D5 justification columns, `Overall`, `Overall Justification` |
| `PRISMA_Flow` | `Stage`, `n` |
| `Exclusion_Log` | `Study ID`, `Author (Year)`, `Title`, `Exclusion Reason Code`, `Exclusion Reason Detail` |

---

## Included Study Records

The table below lists the study records currently documented in the review dataset. The main post-intervention model uses the subset available in `post_data.csv`.

| Study | Program | Country | Year |
|---|---|---|---|
| Ackerson et al. | Feeling Good | USA | 1998 |
| Bohr et al. | SPARX | Cananda | 2023 |
| Fleming et al. | SPARX | New Zealand | 2012 |
| Stice et al. | Feeling Good | USA | 2008 |
| Makarushka | Blueblaster | UK | 2011 |
| Stasiak et al. | The Journey | New Zealand | 2014 |
| Ip et al. | Grasp the Opportunity | Hong Kong, China | 2016 |
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

**Problem:** Two studies contributed change-score SMDs rather than endpoint SMDs: Stallard (2024) and Fleming (2012). Analysing them separately would leave only *k* = 2 change-score studies, making the separate synthesis unstable and any endpoint-versus-change-score subgroup comparison underpowered.The Cochrane Handbook §10.5.2 and Harrer et al. caution that endpoint and change-score estimates may differ when baseline imbalance, regression to the mean, or inconsistent reporting is present.

**Resolution:** The primary analysis combines endpoint and change-score SMDs. This is justified using Ostinelli et al. (2024, *Research Synthesis Methods*), who analysed individual participant data from 61 iCBT depression trials and found no substantive difference between endpoint-based, change-score-based, and mixed SMD pooling approaches. The Cochrane-level concern should still be acknowledged in the thesis Methods section.

### 2. Single-zero dropout events in the acceptability analysis

**The zeros, and what they mean.** Three studies (Ip, 2016; Poppelaars, 2016; Smith, 2015) reported zero dropout in one arm. Before reading anything into these zeros, one alternative had to be excluded: that dropout is simply a rare outcome, which would make the zeros uninformative. It is not rare. Across the dataset dropout ranged from near zero to over 80%, and an outcome that reaches 80% in some trials cannot be intrinsically rare. If it were, the zeros would sit in the smallest studies while the large trials showed only low single-digit counts; instead they come from studies that were neither small nor single-session. This argument rests on the spread of absolute dropout rates alone. It does not rely on the heterogeneity of the pooled estimate, which is a separate matter addressed below.

Once rare events are ruled out, the zeros carry the substantive signal that matters here. In all three studies dropout was low in both arms, single-digit on each side, and the zero is just the low end of that pattern rather than a feature of one arm; it also falls in different arms across the three (the intervention arm in Smith, the control arm in Ip and Poppelaars), so there is no consistent between-arm story. What they share is retention at the study level. Because acceptability is the question of whether participants stay in these interventions, explaining how a few trials kept dropout this low is part of the finding, not a nuisance to be corrected away.

**Statistical handling of the zero cells.** This is the narrower, technical thread, and it is independent of the heterogeneity question below. The primary estimate is the random-effects risk ratio (inverse-variance pooling, REML, Hartung-Knapp), computed with `meta::metabin()`. The Mantel-Haenszel common-effect estimate is reported alongside it; `MH.exact = TRUE` keeps the single-zero studies in that estimate without an arbitrary continuity correction. Two sensitivity analyses confirm the result does not depend on how the zeros are handled: dropping the single-zero studies, and re-running with inverse-variance pooling and the Cochrane continuity correction (`RR.Cochrane = TRUE`).

**Heterogeneity, the outlier, and the comparison.** The pooled risk ratio was heterogeneous. This heterogeneity is in the risk ratio, the ratio of dropout risk between arms, and is a different quantity from the spread of absolute dropout rates used above: studies can share a risk ratio while differing widely in absolute dropout, or share low absolute dropout while differing in their risk ratios. A Baujat plot and Viechtbauer-Cheung influence diagnostics locate the inconsistency in a single study, O'Dea (2025): removing it drops I² from 40.5% to 13.6% and leaves τ² near zero, so the remaining studies are mutually consistent. The inconsistency is one outlier against a coherent set, not a systematic pattern, and it concerns the risk ratio only; it does not imply that O'Dea has the most extreme absolute dropout or that removing it narrows the absolute spread.

O'Dea (2025) is therefore not only a statistical outlier but the high-dropout pole for the comparison that answers the acceptability question. It is a recent, large trial closer to autonomous real-world deployment, and its high dropout stands against the low-dropout studies, above all Smith (2015), which retained participants in both arms. What design conditions let dropout be kept this low is the substantive question, treated here as hypothesis-generating and developed in the Discussion, where it connects to the wider pattern of higher engagement under research-supported conditions and lower engagement as deployment becomes more autonomous.

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

## References

- Harrer, M., Cuijpers, P., Furukawa, T. A., & Ebert, D. D. (2021). *Doing meta-analysis with R: A hands-on guide*. Chapman & Hall/CRC Press. https://doi.org/10.1201/9781003107347
- Higgins, J. P. T., Thomas, J., Chandler, J., Cumpston, M., Li, T., Page, M. J., & Welch, V. A. (Eds.). (2024). *Cochrane handbook for systematic reviews of interventions* (Version 6.5). Cochrane. https://training.cochrane.org/handbook
- Ostinelli, E. G., Efthimiou, O., Luo, Y., Miguel, C., Karyotaki, E., Cuijpers, P., Furukawa, T. A., Salanti, G., & Cipriani, A. (2024). Combining endpoint and change data did not affect the summary standardised mean difference in pairwise and network meta-analyses: An empirical study in depression. *Research Synthesis Methods, 15*(5), 758–768. https://doi.org/10.1002/jrsm.1719
- Page, M. J., McKenzie, J. E., Bossuyt, P. M., Boutron, I., Hoffmann, T. C., Mulrow, C. D., … Moher, D. (2021). The PRISMA 2020 statement: An updated guideline for reporting systematic reviews. *BMJ, 372*, n71. https://doi.org/10.1136/bmj.n71
- Pustejovsky, J. E., & Rodgers, M. A. (2019). Testing for funnel plot asymmetry of standardized mean differences. *Research Synthesis Methods, 10*(1), 57–71. https://doi.org/10.1002/jrsm.1332
- Sterne, J. A. C., Savović, J., Page, M. J., Elbers, R. G., Blencowe, N. S., Boutron, I., … Higgins, J. P. T. (2019). RoB 2: A revised tool for assessing risk of bias in randomised trials. *BMJ, 366*, l4898. https://doi.org/10.1136/bmj.l4898