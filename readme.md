# Unguided Self-Help CBT for Adolescent Depression: A Meta-Analysis

Systematic review and meta-analysis of the effectiveness of unguided self-help cognitive behavioural interventions for adolescents with depressive symptoms.

## Overview

This repository contains the analysis code and data extraction materials for a meta-analysis evaluating whether unguided (self-directed) CBT interventions effectively reduce depressive symptoms in adolescents, and which intervention characteristics moderate their effectiveness.

The review follows **PRISMA guidelines** and uses **Cochrane's Risk of Bias 2.0 (RoB 2.0)** for quality assessment. Effect sizes are computed as Hedge's *g* under a random-effects model.

## Research Questions

**Primary**
1. What are the research trends in unguided self-help CBT interventions for adolescent depression?
2. What is the overall effect size on depressive symptoms (post-intervention)?
3. Are treatment effects maintained at follow-up?

**Secondary**
- How do effects differ by comorbidity, age group, intervention components, delivery format, support level, and baseline severity?

**Extended**
- What is the acceptability of unguided self-help CBT (dropout rates)?

## Methods

| Component | Specification |
|-----------|--------------|
| **Databases** | PubMed, PsycINFO, Embase, Cochrane Library, ProQuest, CNKI |
| **Study design** | Randomised controlled trials (RCTs) only |
| **Population** | Adolescents aged 10–19 with clinically significant depressive symptoms |
| **Intervention** | CBT-based self-help with no therapist-delivered guidance |
| **Comparison** | TAU, waitlist, or inactive control |
| **Quality assessment** | Cochrane Risk of Bias 2.0 (RoB 2.0) |
| **Effect size** | Hedge's *g* (corrects for small-sample bias) |
| **Heterogeneity** | Q-test, I² statistic, random-effects model |
| **Subgroup analysis** | By age, comorbidity, components, delivery format, support level, severity |
| **Sensitivity analysis** | Leave-one-out and influence diagnostics |
| **Publication bias** | Funnel plot, Egger's test, trim-and-fill, selection models |
| **Analysis software** | R 4.4.2 |

## Intervention Component Framework

The review codes each intervention across a standardised set of CBT components (adapted from Furukawa et al., 2021):

**Cognitive-behavioural components**: Cognitive Restructuring, Behavioural Activation, Problem Solving, Relaxation, Interpersonal Skills Training

**Additional therapeutic elements**: Psychoeducation, Third-wave Components (mindfulness, self-compassion), Behavioural Therapy for Insomnia, Relapse Prevention, Homework Requirements, Initial Face-to-Face Contact

**Support levels**: Automated Encouragement, Human Encouragement, Technical Support

This framework enables component-level analysis of which specific therapeutic elements contribute to intervention effectiveness.

## Repository Structure

```
├── analysis/
│   ├── main_analysis.R            # Overall effect size and forest plot
│   ├── subgroup_analysis.R        # Moderator analyses
│   ├── sensitivity_analysis.R     # Influence diagnostics
│   └── publication_bias.R         # Funnel plot, Egger's test, trim-and-fill
├── data/
│   ├── extraction_template.xlsx   # Data extraction form
│   ├── rob2_assessment.xlsx       # Risk of bias ratings
│   └── coded_studies.csv          # Final coded dataset
├── figures/
│   └── (generated forest plots, funnel plots)
├── prisma/
│   └── prisma_flowchart.R         # PRISMA flow diagram
├── requirements.txt               # R package dependencies
└── README.md
```

## Key Methodological Features

- **Component-level coding**: Each intervention is decomposed into standardised CBT components, enabling analysis of which specific elements (e.g., behavioural activation, cognitive restructuring) contribute to treatment effects. This goes beyond simply comparing "intervention vs. control."
- **Follow-up time stratification**: Effects are analysed separately for short-term (≤1 month), medium-term (2–5 months), and long-term (6–12 months) follow-up periods.
- **Age-stratified subgroups**: Pre-defined age groups (10–13, 14–15, ≥16) based on prior evidence of differential treatment response in adolescent depression (Curry, 2006).
- **Acceptability analysis**: Dropout rates compared between intervention and control groups via risk ratios, addressing the known challenge of high attrition in self-guided interventions.
- **Multiple publication bias methods**: Funnel plot visual inspection is supplemented with Egger's regression test, Duval and Tweedie's trim-and-fill, and selection models for robust assessment.

## Skills Demonstrated

- Systematic literature search and screening (PRISMA)
- Standardised quality assessment (Cochrane RoB 2.0)
- Quantitative evidence synthesis (random-effects meta-analysis)
- Moderator and subgroup analysis
- Publication bias detection and adjustment
- Statistical computing in R
- Structured data extraction and coding

## Relevance

This project demonstrates the capacity to **systematically evaluate evidence quality and synthesise findings across a body of research** — a core competency in policy research, technology assessment, and evidence-based programme evaluation. The methodological rigour applied here (PRISMA compliance, RoB 2.0, multiple bias-correction methods) reflects the standards expected in institutional research and policy advisory contexts.

## How to Run

1. Clone this repository.
2. Install R (≥ 4.4.0) and required packages (see `requirements.txt`).
3. Place extracted data files in `data/`.
4. Run analysis scripts in `analysis/` sequentially.
5. Generated figures will appear in `figures/`.
