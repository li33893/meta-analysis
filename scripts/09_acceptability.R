#### 06_acceptability.R ####
#### Purpose: extended analysis of acceptability using post-intervention dropout ####
#### Outcome: dropout as a dichotomous outcome
#### Effect size: Risk Ratio (RR)


### 1. Load data ####
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


### 3. Primary analysis: MH + IV random-effects ####

model_accept_rr <- meta::metabin(
  event.e = n_dropout_exp,
  n.e     = n_exp,
  event.c = n_dropout_ctrl,
  n.c     = n_ctrl,
  studlab = author,
  data    = accept_data,
  
  sm       = "RR",
  method   = "MH",
  MH.exact = TRUE,
  
  common = TRUE,
  random = TRUE,
  
  method.tau       = "REML",
  method.random.ci = "HK",
  
  title = "Acceptability: post-intervention dropout"
)
summary(model_accept_rr)


### 4. Primary results table (random-effects = main inference) ####

accept_rr_summary <- tibble::tibble(
  model    = "Random effects (IV, REML, HK)",
  k        = model_accept_rr$k,
  rr       = exp(model_accept_rr$TE.random),
  ci_lower = exp(model_accept_rr$lower.random),
  ci_upper = exp(model_accept_rr$upper.random),
  p_value  = model_accept_rr$pval.random,
  tau2     = model_accept_rr$tau2,
  i2_pct   = model_accept_rr$I2 * 100
)
print(accept_rr_summary)

# MH fixed-effect (reported as model sensitivity)
accept_rr_mh <- tibble::tibble(
  model    = "Fixed effect (MH, exact, no continuity correction)",
  k        = model_accept_rr$k,
  rr       = exp(model_accept_rr$TE.common),
  ci_lower = exp(model_accept_rr$lower.common),
  ci_upper = exp(model_accept_rr$upper.common),
  p_value  = model_accept_rr$pval.common
)
print(accept_rr_mh)


### 5. Sensitivity: exclude single-zero studies ####

single_zero_ids <- accept_data %>%
  dplyr::filter(n_dropout_exp == 0 | n_dropout_ctrl == 0) %>%
  dplyr::pull(study_id)

cat("\nSingle-zero studies excluded in sensitivity analysis:\n")
print(accept_data %>%
        dplyr::filter(study_id %in% single_zero_ids) %>%
        dplyr::select(author, n_exp, n_ctrl, n_dropout_exp, n_dropout_ctrl))

accept_data_no_sz <- accept_data %>%
  dplyr::filter(!study_id %in% single_zero_ids)

model_accept_no_sz <- meta::metabin(
  event.e = n_dropout_exp,
  n.e     = n_exp,
  event.c = n_dropout_ctrl,
  n.c     = n_ctrl,
  studlab = author,
  data    = accept_data_no_sz,
  
  sm       = "RR",
  method   = "MH",
  MH.exact = TRUE,
  
  common = TRUE,
  random = TRUE,
  
  method.tau       = "REML",
  method.random.ci = "HK",
  
  title = "Acceptability: excluding single-zero studies"
)
summary(model_accept_no_sz)


### 6. Combined summary table for write-up ####

sensitivity_summary <- tibble::tibble(
  analysis = c(
    "Primary — Random effects (IV, k = 14)",
    "Model sensitivity — Fixed effect (MH exact, k = 14)",
    "Sensitivity — Random effects, excluding single-zero (k = 10)",
    "Sensitivity — Fixed effect (MH exact), excluding single-zero (k = 10)"
  ),
  k = c(
    model_accept_rr$k,
    model_accept_rr$k,
    model_accept_no_sz$k,
    model_accept_no_sz$k
  ),
  rr = c(
    exp(model_accept_rr$TE.random),
    exp(model_accept_rr$TE.common),
    exp(model_accept_no_sz$TE.random),
    exp(model_accept_no_sz$TE.common)
  ),
  ci_lower = c(
    exp(model_accept_rr$lower.random),
    exp(model_accept_rr$lower.common),
    exp(model_accept_no_sz$lower.random),
    exp(model_accept_no_sz$lower.common)
  ),
  ci_upper = c(
    exp(model_accept_rr$upper.random),
    exp(model_accept_rr$upper.common),
    exp(model_accept_no_sz$upper.random),
    exp(model_accept_no_sz$upper.common)
  ),
  p_value = c(
    model_accept_rr$pval.random,
    model_accept_rr$pval.common,
    model_accept_no_sz$pval.random,
    model_accept_no_sz$pval.common
  ),
  i2_pct = c(
    model_accept_rr$I2 * 100,
    NA,
    model_accept_no_sz$I2 * 100,
    NA
  ),
  tau2 = c(
    model_accept_rr$tau2,
    NA,
    model_accept_no_sz$tau2,
    NA
  )
)
print(sensitivity_summary)


### 7. Save outputs ####

saveRDS(model_accept_rr,    file.path(results_dir, "models", "model_accept_rr.rds"))
saveRDS(model_accept_no_sz, file.path(results_dir, "models", "model_accept_no_sz.rds"))

readr::write_csv(
  accept_data,
  file.path(results_dir, "tables", "acceptability_dropout_post_data.csv")
)
readr::write_csv(
  sensitivity_summary,
  file.path(results_dir, "tables", "acceptability_sensitivity_summary.csv")
)


### 8. Forest plot (primary analysis) ####

png(file.path(figures_dir, "forest_acceptability_dropout_rr.png"),
    width  = 3000,
    height = 600 + 120 * nrow(accept_data),
    res    = 300)

forest(model_accept_rr,
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
       
       main        = "Acceptability: Post-intervention Dropout")
dev.off()

cat("\nAcceptability forest plot saved to figures/\n")
cat("06_acceptability.R completed successfully.\n")