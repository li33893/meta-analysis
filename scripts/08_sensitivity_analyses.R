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
outlier_table <- data.frame(
  study    = model_post$studlab,
  g        = round(model_post$TE, 3),
  ci_lower = round(model_post$lower, 3),
  ci_upper = round(model_post$upper, 3)
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
loo <- metainf(model, pooled = "random")

# clean the table
loo_table <- dataframe(
  omitted_study = loo$studlab,
  g             = round(loo$TE, 3),
  ci_lower      = round(loo$lower, 3),
  ci_upper      = round(loo$upper, 3) 
)
loo_table <- loo_table[order(loo_table$g), ]   # 按剔除后 g 排序
print(loo_table)