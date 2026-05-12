#### 04_followup_analysis.R ####
#### To produce the pooled effect of follow-ups #####


### 1. Load data ###
source("C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/scripts/01_read_data.R")


### 2. Subset to follow-up ####
### short = 1–3 mo，medium = 4–6 mo，long = > 6 mo (in this study, ≥ 12 mo)

fu_short <- effect_data %>%
  dplyr::filter(timepoint %in% c("fu_1mo", "fu_3mo"))

fu_mid <- effect_data %>%
  dplyr::filter(timepoint %in% c("fu_4mo", "fu_6mo"))

fu_long <- effect_data %>%
  dplyr::filter(timepoint %in% c("fu_12mo", "fu_18mo", "fu_24mo"))


### 3. metagen — fit the pooled effect model ###

model_fu_short <- metagen(
  TE               = te,
  seTE             = se_te,
  studlab          = author,
  data             = fu_short,
  sm               = "SMD",
  common           = FALSE,           
  random           = TRUE,
  method.tau       = "REML",
  method.random.ci = "HK",
  prediction       = TRUE
)

model_fu_mid <- metagen(
  TE               = te,
  seTE             = se_te,
  studlab          = author,
  data             = fu_mid,
  sm               = "SMD",
  common           = FALSE,           
  random           = TRUE,
  method.tau       = "REML",
  method.random.ci = "HK",
  prediction       = TRUE
)

model_fu_long <- metagen(
  TE               = te,
  seTE             = se_te,
  studlab          = author,
  data             = fu_long,
  sm               = "SMD",
  common           = FALSE,           
  random           = TRUE,
  method.tau       = "REML",
  method.random.ci = "HK",
  prediction       = TRUE
)



### 4. Quick look ###

summary(model_fu_short)
summary(model_fu_mid)
summary(model_fu_long)


### 6. Save files ###

results_dir <- "C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/results"

# 保存模型对象（供 04 森林图脚本读取）
saveRDS(model_fu_short, file.path(results_dir, "models", "model_fu_short.rds"))
saveRDS(model_fu_mid, file.path(results_dir, "models", "model_fu_mid.rds"))
saveRDS(model_fu_long, file.path(results_dir, "models", "model_fu_long.rds"))

# 保存数据子集（供检查）
readr::write_csv(fu_short, file.path(results_dir, "tables", "fu_short.csv"))
readr::write_csv(fu_mid, file.path(results_dir, "tables", "fu_mid.csv"))
readr::write_csv(fu_long, file.path(results_dir, "tables", "fu_long.csv"))
                 
                 
                 
                 