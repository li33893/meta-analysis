# Meta-Analysis of Unguided Self-Help CBT for Adolescent Depressive Symptoms

This repository contains the R scripts and data-management workflow for a systematic review and meta-analysis on unguided self-help cognitive behavioural therapy (CBT) interventions for adolescents with depressive symptoms.

The analysis workflow is organised step by step so that data import, effect size calculation, main meta-analysis, subgroup analysis, sensitivity analysis, publication bias assessment, and acceptability analysis can be run in a reproducible order.

## Project Aim

This meta-analysis evaluates whether unguided or minimally supported self-help CBT interventions reduce depressive symptoms among adolescents.

The review focuses on adolescents aged 10–19 with elevated or clinically significant depressive symptoms and includes randomised controlled trials comparing unguided self-help CBT interventions with waitlist, treatment-as-usual, attention-control, or information-only control conditions.

## Research Questions

### Primary Questions

1. What is the overall post-intervention effect of unguided self-help CBT on adolescent depressive symptoms?
2. Are intervention effects maintained at follow-up?
3. How acceptable are unguided self-help CBT interventions, as reflected by dropout or completion rates?

### Secondary / Exploratory Questions

Where data are sufficient, the project will examine whether effects differ by:

- Control type
- Support level
- Baseline depression severity
- Delivery format
- Intervention components
- Follow-up timing
- Risk of bias

## Methods Overview

| Component | Specification |
|---|---|
| Reporting framework | PRISMA 2020 |
| Study design | Randomised controlled trials and pilot RCTs |
| Population | Adolescents aged 10–19 with elevated or clinically significant depressive symptoms |
| Intervention | CBT-based self-help intervention without therapist-delivered treatment guidance |
| Comparator | Waitlist, treatment-as-usual, attention-control, or information-only control |
| Primary outcome | Depressive symptoms measured by validated scales |
| Effect size | Hedges' g |
| Model | Random-effects meta-analysis |
| Risk of bias | Cochrane RoB 2.0 |
| Software | R |

## Repository Structure

```text
meta-analysis-project/
│
├── README.md
├── .gitignore
│
├── data/
│   └── data.xlsx
│
├── scripts/
│   ├── 00_setup.R
│   ├── 01_read_data.R
│   ├── 02_compute_effect_sizes.R
│   ├── 03_main_analysis_post.R
│   ├── 04_followup_analysis.R
│   ├── 05_subgroup_analysis.R
│   ├── 06_metaregression.R
│   ├── 07_sensitivity_analysis.R
│   ├── 08_publication_bias.R
│   ├── 09_acceptability.R
│   └── 99_run_all.R
│
├── results/
│   ├── tables/
│   ├── figures/
│   └── models/
│
├── prisma/
│   ├── prisma_flow_data.csv
│   ├── exclusion_log.csv
│   └── search_strategy.md
│
└── docs/
    └── thesis.docx
