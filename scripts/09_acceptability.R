#### 06_acceptability.R ####
#### Purpose: Acceptability analysis using post-intervention dropout ####
#### Effect size: Risk Ratio (RR) ####
#### Primary: MH exact + REML + Hartung-Knapp
#### Sensitivity: (1) exclude single-zero studies
####              (2) IV + Cochrane-style continuity correction
#### Exploratory: (1) exclude two highest-weight studies (heterogeneity source)
####              (2) Viechtbauer-Cheung influence diagnostics + Baujat plot
#### Method reference: Harrer et al. (2021) Ch 4.2.3.1, 5.4/6.3


### 1. Load data and helper paths ####

source("C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/scripts/02_compute_effect_sizes.R")

figures_dir <- "C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/figures"


### 2. Prepare post-intervention dropout data ####

accept_data <- effect_data %>%
  dplyr::filter(
    timepoint == "post",
    !is.na(n_dropout_exp),
    !is.na(n_dropout_ctrl),
    !is.na(n_exp),
    !is.na(n_ctrl)
  )

### Create unified study label: study_id + year ####
### This label will be used consistently in forest plot, Baujat plot,
### and influence diagnostics.

year_col <- dplyr::case_when(
  "year" %in% names(accept_data) ~ "year",
  "publication_year" %in% names(accept_data) ~ "publication_year",
  "pub_year" %in% names(accept_data) ~ "pub_year",
  "study_year" %in% names(accept_data) ~ "study_year",
  TRUE ~ NA_character_
)

if (is.na(year_col)) {
  stop("No year column found. Please check whether the year column is named year, publication_year, pub_year, or study_year.")
}

accept_data <- accept_data %>%
  dplyr::mutate(
    study_label = paste0(study_id, " (", .data[[year_col]], ")")
  )

cat("Acceptability dataset prepared: k =", nrow(accept_data), "\n")
cat("Study labels used in plots:\n")
print(accept_data %>% dplyr::select(study_id, dplyr::all_of(year_col), study_label))


### 3. Primary analysis: MH exact + random-effects ####
### Common-effect estimate uses exact MH without continuity correction.
### Random-effects estimate uses inverse-variance pooling (REML + HK),
### with a light continuity correction applied internally where needed
### for individual zero-cell studies.

model_accept_rr <- meta::metabin(
  event.e = n_dropout_exp,
  n.e     = n_exp,
  event.c = n_dropout_ctrl,
  n.c     = n_ctrl,
  studlab = study_label,
  data    = accept_data,
  
  sm       = "RR",
  method   = "MH",
  MH.exact = TRUE,
  
  common = TRUE,
  random = TRUE,
  
  method.tau       = "REML",
  method.random.ci = "HK",
  
  title = "Acceptability: post-intervention dropout (primary)"
)

summary(model_accept_rr)


### 4. Sensitivity 1: exclude single-zero studies ####
### Tests whether the primary estimate is driven by zero-cell studies.

single_zero_ids <- accept_data %>%
  dplyr::filter(n_dropout_exp == 0 | n_dropout_ctrl == 0) %>%
  dplyr::pull(study_id)

cat("\nSingle-zero studies to be excluded in Sensitivity 1:\n")

print(
  accept_data %>%
    dplyr::filter(study_id %in% single_zero_ids) %>%
    dplyr::select(
      study_label,
      n_exp,
      n_ctrl,
      n_dropout_exp,
      n_dropout_ctrl
    )
)

accept_data_no_sz <- accept_data %>%
  dplyr::filter(!study_id %in% single_zero_ids)

model_accept_no_sz <- meta::metabin(
  event.e = n_dropout_exp,
  n.e     = n_exp,
  event.c = n_dropout_ctrl,
  n.c     = n_ctrl,
  studlab = study_label,
  data    = accept_data_no_sz,
  
  sm       = "RR",
  method   = "MH",
  MH.exact = TRUE,
  
  common = TRUE,
  random = TRUE,
  
  method.tau       = "REML",
  method.random.ci = "HK",
  
  title = "Acceptability: excluding single-zero studies (sensitivity 1)"
)

summary(model_accept_no_sz)


### 5. Sensitivity 2: alternative continuity correction ####
### IV + RR.Cochrane = TRUE applies the heavier Cochrane-style CC
### 0.5 to all four cells of zero-cell studies.
### Represents the "heavy CC" end of the zero-cell-handling spectrum.

model_accept_iv_cochrane <- meta::metabin(
  event.e = n_dropout_exp,
  n.e     = n_exp,
  event.c = n_dropout_ctrl,
  n.c     = n_ctrl,
  studlab = study_label,
  data    = accept_data,
  
  sm          = "RR",
  method      = "Inverse",
  RR.Cochrane = TRUE,
  
  common = TRUE,
  random = TRUE,
  
  method.tau       = "REML",
  method.random.ci = "HK",
  
  title = "Acceptability: IV + Cochrane-style continuity correction (sensitivity 2)"
)

summary(model_accept_iv_cochrane)


### 6. Exploratory 1: exclude two highest-weight studies ####
### Post-hoc heterogeneity source exploration.
### NOT a primary sensitivity check.
### Reports the change in tau^2 and I^2 when the two highest-weight trials are removed.

accept_data_no_high <- accept_data %>%
  dplyr::filter(!author %in% c("O'Dea 2025", "Wright 2020"))

model_accept_no_high <- meta::metabin(
  event.e = n_dropout_exp,
  n.e     = n_exp,
  event.c = n_dropout_ctrl,
  n.c     = n_ctrl,
  studlab = study_label,
  data    = accept_data_no_high,
  
  sm       = "RR",
  method   = "MH",
  MH.exact = TRUE,
  
  common = TRUE,
  random = TRUE,
  
  method.tau       = "REML",
  method.random.ci = "HK",
  
  title = "Acceptability: excluding two highest-weight studies (exploratory)"
)

summary(model_accept_no_high)


### 7. Exploratory 2: influence diagnostics ####
### Viechtbauer & Cheung (2010) influence diagnostics + Baujat plot.
### Re-fit using metafor::rma() to enable influence() S3 dispatch.

library(metafor)

accept_rma <- metafor::rma(
  ai      = n_dropout_exp,
  n1i     = n_exp,
  ci      = n_dropout_ctrl,
  n2i     = n_ctrl,
  measure = "RR",
  data    = accept_data,
  method  = "REML",
  slab    = study_label
)

inf_result <- influence(accept_rma)
inf_df     <- inf_result$inf

influence_table <- data.frame(
  study    = accept_rma$slab,
  rstudent = round(inf_df$rstudent, 3),
  dffits   = round(inf_df$dffits, 3),
  cook_d   = round(inf_df$cook.d, 3),
  hat      = round(inf_df$hat, 3),
  weight   = round(inf_df$weight, 2),
  is_infl  = inf_df$inf
)

cat("\nInfluence diagnostics table:\n")
print(influence_table)


### 8. Combined results summary table ####

sensitivity_summary <- tibble::tibble(
  analysis = c(
    paste0("Primary - MH exact random-effects (k = ", model_accept_rr$k, ")"),
    paste0("Primary - MH exact common-effect (k = ", model_accept_rr$k, ")"),
    paste0("Sensitivity 1 - excluding single-zero (k = ", model_accept_no_sz$k, ")"),
    paste0("Sensitivity 2 - IV + Cochrane CC (k = ", model_accept_iv_cochrane$k, ")"),
    paste0("Exploratory - excluding two high-weight studies (k = ", model_accept_no_high$k, ")")
  ),
  rr = c(
    exp(model_accept_rr$TE.random),
    exp(model_accept_rr$TE.common),
    exp(model_accept_no_sz$TE.random),
    exp(model_accept_iv_cochrane$TE.random),
    exp(model_accept_no_high$TE.random)
  ),
  ci_lower = c(
    exp(model_accept_rr$lower.random),
    exp(model_accept_rr$lower.common),
    exp(model_accept_no_sz$lower.random),
    exp(model_accept_iv_cochrane$lower.random),
    exp(model_accept_no_high$lower.random)
  ),
  ci_upper = c(
    exp(model_accept_rr$upper.random),
    exp(model_accept_rr$upper.common),
    exp(model_accept_no_sz$upper.random),
    exp(model_accept_iv_cochrane$upper.random),
    exp(model_accept_no_high$upper.random)
  ),
  p_value = c(
    model_accept_rr$pval.random,
    model_accept_rr$pval.common,
    model_accept_no_sz$pval.random,
    model_accept_iv_cochrane$pval.random,
    model_accept_no_high$pval.random
  ),
  i2_pct = c(
    model_accept_rr$I2 * 100,
    NA_real_,
    model_accept_no_sz$I2 * 100,
    model_accept_iv_cochrane$I2 * 100,
    model_accept_no_high$I2 * 100
  ),
  tau2 = c(
    model_accept_rr$tau2,
    NA_real_,
    model_accept_no_sz$tau2,
    model_accept_iv_cochrane$tau2,
    model_accept_no_high$tau2
  )
)

print(sensitivity_summary)


### 9. Save outputs ####

saveRDS(model_accept_rr,          file.path(results_dir, "models", "model_accept_rr.rds"))
saveRDS(model_accept_no_sz,       file.path(results_dir, "models", "model_accept_no_sz.rds"))
saveRDS(model_accept_iv_cochrane, file.path(results_dir, "models", "model_accept_iv_cochrane.rds"))
saveRDS(model_accept_no_high,     file.path(results_dir, "models", "model_accept_no_high.rds"))
saveRDS(accept_rma,               file.path(results_dir, "models", "accept_rma.rds"))
saveRDS(inf_result,               file.path(results_dir, "models", "accept_influence.rds"))

readr::write_csv(
  accept_data,
  file.path(results_dir, "tables", "acceptability_dropout_post_data.csv")
)

readr::write_csv(
  sensitivity_summary,
  file.path(results_dir, "tables", "acceptability_sensitivity_summary.csv")
)

readr::write_csv(
  influence_table,
  file.path(results_dir, "tables", "acceptability_influence_diagnostics.csv")
)


### 10. Forest plot: primary analysis ####
### Uses study_label = study_id + year.

png(file.path(figures_dir, "forest_acceptability_dropout_rr.png"),
    width  = 3000,
    height = 600 + 120 * nrow(accept_data),
    res    = 300)

forest(
  model_accept_rr,
  sortvar     = TE,
  leftcols    = c("studlab"),
  leftlabs    = c("Study"),
  rightcols   = c("effect.ci", "w.random"),
  rightlabs   = c("RR [95% CI]", "Weight"),
  smlab       = "",
  label.left  = "Lower dropout in Intervention",
  label.right = "Higher dropout in Intervention",
  col.diamond = "steelblue",
  print.tau2  = TRUE,
  print.I2    = TRUE,
  prediction  = TRUE,
  addrows.below.overall = 4,
  xlim        = c(0.1, 10),
  at          = c(0.25, 0.5, 1, 2, 4, 8),
  backtransf  = TRUE,
  main        = "Acceptability: post-intervention dropout"
)

dev.off()


### 11. Influence diagnostics plot ####
### Labels are based on study_label through accept_rma$slab.

png(file.path(figures_dir, "influence_diagnostics_acceptability.png"),
    width  = 3000,
    height = 2400,
    res    = 300)

par(mar = c(4, 4, 2, 1))
plot(inf_result)

dev.off()


### 12. Baujat plot ####
### symbol = "slab" makes the plot show study_label instead of numeric IDs.

png(file.path(figures_dir, "baujat_acceptability.png"),
    width  = 3000,
    height = 2400,
    res    = 300)

par(mar = c(4, 4, 2, 1))

baujat(
  accept_rma,
  symbol = "slab",
  cex = 0.8
)

dev.off()


### 13. Completion ####

cat("\n", strrep("=", 60), "\n", sep = "")
cat("06_acceptability.R completed successfully.\n")
cat("Models  saved to: ", file.path(results_dir, "models"), "\n")
cat("Tables  saved to: ", file.path(results_dir, "tables"), "\n")
cat("Figures saved to: ", figures_dir, "\n")
cat(strrep("=", 60), "\n", sep = "")