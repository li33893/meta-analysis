#### 07_metaregression.R ####
#### Purpose: meta-regression for continuous data ####


### 1. Load data and helper paths ####

source("C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/scripts/02_compute_effect_sizes.R")

results_dir <- "C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/scripts/results"
figures_dir <- "C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/figures"


### 2. Prepare meta-regression data ###

### 2-1. extract effect_data with publish year ###

post_data <- effect_data %>%
  dplyr::filter(timepoint == "post", study_id != 3) %>%
  dplyr::mutate(
    publish_year = as.numeric(
      substr(author, nchar(author) - 3, nchar(author))
    ) 
  )

### 2-2. join component_count from study_info (NOT outcome_data) ###

post_data <- post_data %>%
  dplyr::inner_join(
    study_info %>%
      dplyr::select(study_id = c, component_count),
    by = "study_id"
  )

### 2-3. centre the moderators (assign back!) ###

post_data <- post_data %>%
  dplyr::mutate(
    year_c            = publish_year - 2010,
    component_count_c = component_count - mean(component_count, na.rm =TRUE)
    
  )


### 3. Base random-effects model (to update what "componentcount" and "publishyear" matters)

model_mr <- meta::metagen(
  TE               = te, 
  seTE             = se_te, 
  studlab          = author, 
  data             = post_data,
  sm               = "SMD", 
  common           = FALSE, 
  random           = TRUE,
  method.tau       = "REML", 
  method.random.ci = "HK", 
  prediction       = TRUE
)


### 4. Meta-regression ###

### 4-1. component count (pre-specified) ###

mr_comp <- meta::metareg(model_mr, ~ component_count_c)

### 4-2. publication year (post-hoc) ###

mr_year <- meta::metareg(model_mr, ~ year_c)


### 5. Extract results into a table ###

extract_mr <- function(mr, predictor) {
  b   <- mr$beta[2]                 # slope (row 2; row 1 is intercept)
  se  <- mr$se[2]
  ci_lo <- mr$ci.lb[2]
  ci_hi <- mr$ci.ub[2]
  p   <- mr$pval[2]
  R2  <- mr$R2 / 100                # metafor returns R2 as %, store as proportion
  tau2_resid <- mr$tau2
  tibble::tibble(
    predictor    = predictor,
    k            = mr$k,
    beta         = b,
    se           = se,
    ci_lo        = ci_lo,
    ci_hi        = ci_hi,
    p            = p,
    R2           = R2,
    tau2_resid   = tau2_resid
  )
}

table6_raw <- dplyr::bind_rows(
  extract_mr(mr_comp, "Component count (centred)"),
  extract_mr(mr_year, "Publication year (centred at 2010)")
)
print(table6_raw)


### 6. Format Table 6 ####
fmt_p <- function(p) ifelse(p < .001, "< .001", sub("^0", "", sprintf("%.3f", p)))

table6_fmt <- table6_raw %>%
  dplyr::transmute(
    Predictor      = predictor,
    k              = k,
    `β`            = sprintf("%.3f", beta),
    SE             = sprintf("%.3f", se),
    `95% CI`       = sprintf("[%.3f, %.3f]", ci_lo, ci_hi),
    p              = fmt_p(p),
    `R²`           = sprintf("%.1f%%", R2 * 100),
    `Residual τ²`  = sprintf("%.4f", tau2_resid)
  )
print(knitr::kable(table6_fmt, format = "pipe", align = "lrrrlrrr"))


### 7. Save files ###

saveRDS(mr_comp, file.path(results_dir, "models", "mr_component.rds"))
saveRDS(mr_year, file.path(results_dir, "models", "mr_year.rds"))

readr::write_csv(table6_fmt, file.path(results_dir, "tables", "table6_metaregression.csv"))


### 8. Bubble plots ###

png(file.path(figures_dir, "bubble_year.png"), width = 2400, height = 1800, res = 300)
meta::bubble(mr_year,
             xlab = "Publication year (centred at 2010)",
             ylab = "Hedges' g",
             studlab = TRUE, cex.studlab = 0.7)
dev.off()

png(file.path(figures_dir, "bubble_component.png"), width = 2400, height = 1800, res = 300)
meta::bubble(mr_comp,
             xlab = "Number of CBT components (centred)",
             ylab = "Hedges' g",
             studlab = TRUE, cex.studlab = 0.7)
dev.off()


cat("07_metaregression.R completed successfully.\n")