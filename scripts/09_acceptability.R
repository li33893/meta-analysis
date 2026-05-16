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


### 3. Fit pooled RR model ####
model_accept_rr <- meta::metabin(
  event.e = n_dropout_exp,
  n.e     = n_exp,
  event.c = n_dropout_ctrl,
  n.c     = n_ctrl,
  studlab = author,
  data    = accept_data,
  
  sm       = "RR",
  method   = "MH",
  MH.exact = TRUE,   # MH fixed effect without continuity correction (Cochrane Handbook)
  
  common = TRUE,     # 内部保留 MH fixed effect；和 random 一起输出，便于核对
  random = TRUE,
  
  method.tau       = "REML",   # 与主分析一致
  method.random.ci = "HK",
  
  title = "Acceptability: post-intervention dropout"
)
summary(model_accept_rr)


### 4. Print pooled RR information (random effects = primary estimate) ####
accept_rr_summary <- tibble::tibble(
  model    = "Random effects",
  k        = model_accept_rr$k,
  rr       = exp(model_accept_rr$TE.random),
  ci_lower = exp(model_accept_rr$lower.random),
  ci_upper = exp(model_accept_rr$upper.random),
  p_value  = model_accept_rr$pval.random,
  tau2     = model_accept_rr$tau2,
  i2_pct   = model_accept_rr$I2 * 100
)
print(accept_rr_summary)

# 也提取 MH fixed effect 备查（不在正文报告，仅核对零格子影响）
accept_rr_mh <- tibble::tibble(
  model    = "Fixed effect (MH, exact)",
  k        = model_accept_rr$k,
  rr       = exp(model_accept_rr$TE.common),
  ci_lower = exp(model_accept_rr$lower.common),
  ci_upper = exp(model_accept_rr$upper.common),
  p_value  = model_accept_rr$pval.common
)
print(accept_rr_mh)


### 5. Save model and data ####
saveRDS(
  model_accept_rr,
  file.path(results_dir, "models", "model_accept_rr.rds")
)
readr::write_csv(
  accept_data,
  file.path(results_dir, "tables", "acceptability_dropout_post_data.csv")
)


### 6. Forest plot for appendix ####
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
       prediction  = FALSE,
       
       addrows.below.overall = 4,
       
       xlim        = c(0.1, 10),
       at          = c(0.25, 0.5, 1, 2, 4, 8),
       backtransf  = TRUE,
       
       main        = "Acceptability: Post-intervention Dropout")
dev.off()

cat("Acceptability forest plot saved to figures/\n")
cat("06_acceptability.R completed successfully.\n")