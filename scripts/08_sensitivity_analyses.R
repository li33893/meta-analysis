### 08_sensitivity_analyses.R ###
### Purpose: to test the robustness of the pooled effect size ###


### 1. Load data and helper paths and read the post model###

source("C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/scripts/03_main_analysis_post.R")

results_dir <- "C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/results"

model_post <- readRDS(file.path(results_dir, "models", "model_post.rds"))


### 2. Leave_one_out and outliers ###
# Logic: compare each study's own 95% CI with the 95% CI of the pooled effect.
# If a study's entire CI lies completely outside the pooled CI
# either entirely to the right or entirely to the left, it is flagged as an outlier.
# This is the definition used by Harrer et al.

### 2-1. outliers ###

# lower and upper bounds of the pooled random-effects CI
pooled_lower <- model_post$lower.random
pooled_upper <- model_post$upper.random

# create an outlier table and detect the outliers and put them in
# 因为回答的问题是“影响诊断”，所以loo常常不会考虑PI
outlier_table <- tibble::tibble(
  study    = model_post$studlab,
  g        = round(model_post$TE, 3),
  ci_lower = round(model_post$lower, 2),
  ci_upper = round(model_post$upper, 2)
) %>%
  dplyr::mutate(
    outlier_upper_out = ci_upper < pooled_lower,
    outlier_lower_out = ci_lower > pooled_upper,
    outlier           = outlier_upper_out | outlier_lower_out
  )

outliers <- outlier_table %>%
  dplyr::filter(outlier)

print(outliers)


### 2-2. leave-one-out ###

# run leave_one_out
loo <- metainf(model_post, pooled = "random")

# clean the table
loo_table <- tibble::tibble(
  omitted_study = loo$studlab,
  g             = round(loo$TE, 3),
  ci_lower      = round(loo$lower, 2),
  ci_upper      = round(loo$upper, 2) 
)
loo_table <- loo_table[order(loo_table$g), ]

print(loo_table)


### 3. Function for sensitivity analyses ###

run_sens <- function(df) {
  metagen(
    TE = te, 
    seTE = se_te, 
    studlab = author, 
    data = df,
    sm = "SMD", 
    common = FALSE, 
    random = TRUE,
    method.tau = "REML", 
    method.random.ci = "HK", 
    prediction = TRUE
  )
}

# helper: turn a fitted meta model into one summary-table row
to_table <- function(model, label){
  tibble::tibble(
    analysis    = label,
    k           = model$k,
    g           = round(model$TE.random, 3),
    ci_lower    = round(model$lower.random, 2),
    ci_upper    = round(model$upper.random, 2),
    pi_lower = round(model$lower.predict, 2),
    pi_upper = round(model$upper.predict, 2),
    I2          = round(model$I2, 3)
  )
}


# build post_data: main-analysis subset (14, Bohr excluded) joined with the classification columns needed for filtering.
post_data <- data_to_be_pooled %>%
  dplyr::inner_join(
    study_info %>%
      dplyr::select(study_id = c, publication_type, depression_role),
    by = "study_id"
  ) %>%
  dplyr::inner_join(
    rob_data %>%
      dplyr::select(study_id, overall),
    by = "study_id"
  )

stopifnot(nrow(post_data) == 14)   # defensive check: join must still give 14 rows

m_journal <- run_sens(dplyr::filter(post_data, publication_type == "Journal"))
m_depprim <- run_sens(dplyr::filter(post_data, depression_role == 1))
m_lowrob  <- run_sens(dplyr::filter(post_data, overall != "High"))


### 4. Methodological sensitivity: endpoint-only analysis ###

post_endpoint <- post_data %>%
  dplyr::filter(m_type == "raw")

m_endpoint <- run_sens(post_endpoint)   

summary(m_endpoint)


### 5. Bohr cluster inclusion with assumed ICC values ###

run_bohr_icc_sens <- function(icc_value) {
  
  bohr_row <- effect_data %>%
    dplyr::filter(author == "Bohr 2023", timepoint == "post")
  
  m_bar <- 3
  deff  <- 1 + (m_bar - 1) * icc_value
  
  bohr_corrected <- bohr_row %>%
    dplyr::mutate(se_te = se_te * sqrt(deff))
  
  sens_data <- dplyr::bind_rows(data_to_be_pooled, bohr_corrected)
  model     <- run_sens(sens_data)
  
  # return one row, same column structure as to_table()
  to_table(model, paste0("Bohr included, assumed ICC = ", icc_value))
}

# 实际运行：跑一组 ICC，叠成表
bohr_icc_sens_table <- dplyr::bind_rows(
  run_bohr_icc_sens(0.01),
  run_bohr_icc_sens(0.03),
  run_bohr_icc_sens(0.05),
  run_bohr_icc_sens(0.10)
)


### 6. Summary table of all whole-pool sensitivity analyses ###
# (outlier detection and leave-one-out have a different output structure
#  and are reported separately, not stacked here.)

sens_summary <- dplyr::bind_rows(
  to_table(model_post, "Main analysis (k = 14)"),
  to_table(m_journal,  "Journal articles only"),
  to_table(m_lowrob,   "Excluding high RoB studies"),
  to_table(m_depprim,  "Depression as primary target"),
  to_table(m_endpoint, "Endpoint-only effect sizes"),
  bohr_icc_sens_table
)

print(sens_summary)

readr::write_csv(sens_summary, file.path(results_dir, "tables", "sensitivity_summary.csv"))


cat("\n08_sensitivity_analyses.R completed successfully.\n")


