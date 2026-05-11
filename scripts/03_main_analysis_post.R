#### 03_main_analysis_post.R ####
#### To produce the pooled effect #####


### 1. Load data ###
source("C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/scripts/01_read_data.R")


### 2. Subset to post-test, exclude Bohr 2023 ####
# Exclude Bohr 2023 (study_id = 3): cluster RCT without reported ICC.
# Retained in sensitivity analysis with uncorrected estimate.
data_to_be_pooled <- effect_data %>%
  dplyr::filter(timepoint == "post" & study_id != 3)


### 3. metagen — fit the pooled effect model ###

model_post <- metagen(
  TE               = te,
  seTE             = se_te,
  studlab          = author,
  data             = data_to_be_pooled,
  sm               = "SMD",
  common           = FALSE,
  random           = TRUE,
  method.tau       = "REML",
  method.random.ci = "HK",
  prediction       = TRUE
)


### 4. Quick look ###

summary(model_post)


### 6. Save files ###

results_dir <- "C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/results"

# 保存模型对象（供 04 森林图脚本读取）
saveRDS(model_post, file.path(results_dir, "models", "model_post.rds"))

# 保存数据子集（供检查）
readr::write_csv(post_data, file.path(results_dir, "tables", "post_data.csv")



