#### 04_followup_analysis.R ####
#### To produce the pooled effect of follow-ups #####


### 1. Load data ###
source("C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/scripts/02_compute_effect_sizes.R")


### 2. Subset to follow-up ####
### short = 1–5 mo, long = > = 6 mo 

fu_all <- effect_data %>%
  dplyr::filter(grepl("^fu_", timepoint)) 

fu_short <- fu_all %>%
  dplyr::filter(timing_mo < 6) %>%
  dplyr::group_by(study_id) %>%
  dplyr::slice_max(timing_mo) %>%
  dplyr::ungroup()

fu_long <- fu_all %>%                      # primary: longest timepoint per study
  dplyr::filter(timing_mo >= 6) %>%
  dplyr::group_by(study_id) %>%
  dplyr::slice_max(timing_mo) %>%
  dplyr::ungroup()

fu_long_6mo <- fu_all %>%                  # sensitivity: earliest >= 6 mo timepoint
  dplyr::filter(timing_mo >= 6) %>%
  dplyr::group_by(study_id) %>%
  dplyr::slice_min(timing_mo) %>%
  dplyr::ungroup()


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

model_fu_long_6mo <- metagen(
  TE               = te,
  seTE             = se_te,
  studlab          = author,
  data             = fu_long_6mo,
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
summary(model_fu_long_6mo)
summary(model_fu_long)

long_compare <- data.frame(
  rule = c("A_longest","B_earliest_ge6"),
  k    = c(model_fu_long$k, model_fu_long_6mo$k),
  g    = c(model_fu_long$TE.random, model_fu_long_6mo$TE.random),
  I2   = c(model_fu_long$I2, model_fu_long_6mo$I2))
print(long_compare)



### 6. Save files ###

results_dir <- "C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/results"

# 保存模型对象（供 04 森林图脚本读取）
saveRDS(model_fu_short, file.path(results_dir, "models", "model_fu_short.rds"))
saveRDS(model_fu_long_6mo, file.path(results_dir, "models", "model_fu_long_6mo.rds"))
saveRDS(model_fu_long, file.path(results_dir, "models", "model_fu_long.rds"))

# 保存数据子集（供检查）
readr::write_csv(fu_short, file.path(results_dir, "tables", "fu_short.csv"))
readr::write_csv(fu_long_6mo, file.path(results_dir, "tables", "model_fu_long_6mo.csv"))
readr::write_csv(fu_long, file.path(results_dir, "tables", "fu_long.csv"))


### 5. Forest plots ###

figures_dir <- "C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/figures"

# --- 5a. Short-term follow-up (1–5 mo) ---
png(file.path(figures_dir, "forest_fu_short.png"),
    width = 3000, height = 800 + 200 * nrow(fu_short),
    res = 300)
forest(model_fu_short,
       sortvar     = TE,
       leftcols    = c("studlab"),
       leftlabs    = c("Study"),
       rightcols   = c("effect.ci", "w.random"),
       rightlabs   = c("Hedges' g [95% CI]", "Weight"),
       smlab       = "",
       label.left  = "Favours Control",
       label.right = "Favours Intervention",
       col.diamond = "steelblue",
       print.tau2  = TRUE,
       print.I2    = TRUE,
       prediction  = TRUE,
       
       # 关键：给 random effects / prediction interval 下面加空行
       addrows.below.overall = 4,
       
       xlim        = c(-2, 2),
       main        = "Short-term (post to < 6 months)")
dev.off()

# --- 5b. Long-term_sensitivity ---
png(file.path(figures_dir, "forest_fu_long_6mo.png"),
    width = 3000, height = 800 + 200 * nrow(fu_long_6mo),
    res = 300)
forest(model_fu_long_6mo,
       sortvar     = TE,
       leftcols    = c("studlab"),
       leftlabs    = c("Study"),
       rightcols   = c("effect.ci", "w.random"),
       rightlabs   = c("Hedges' g [95% CI]", "Weight"),
       smlab       = "",
       label.left  = "Favours Control",
       label.right = "Favours Intervention",
       col.diamond = "steelblue",
       print.tau2  = TRUE,
       print.I2    = TRUE,
       prediction  = TRUE,
       
       # 关键：给 random effects / prediction interval 下面加空行
       addrows.below.overall = 4,
       xlim        = c(-2, 2),
       main        = "Follow-up: Long-term sensitivity (earliest >= 6 months)")
dev.off()

# --- 5c. Long-term follow-up (≥6 mo) ---
png(file.path(figures_dir, "forest_fu_long.png"),
    width = 3000, height = 800 + 200 * nrow(fu_long),
    res = 300)
forest(model_fu_long,
       sortvar     = TE,
       leftcols    = c("studlab"),
       leftlabs    = c("Study"),
       rightcols   = c("effect.ci", "w.random"),
       rightlabs   = c("Hedges' g [95% CI]", "Weight"),
       smlab       = "",
       label.left  = "Favours Control",
       label.right = "Favours Intervention",
       col.diamond = "steelblue",
       print.tau2  = TRUE,
       print.I2    = TRUE,
       prediction  = TRUE,
       
       # 关键：给 random effects / prediction interval 下面加空行
       addrows.below.overall = 4,
       
       xlim        = c(-2, 2),
       main        = "Follow-up: Long-term (>= 6 months)")
dev.off()

cat("Follow-up forest plots saved to figures/\n")

# Check if O'Dea was the influencial study at short-term (to see if I^2 drops)
fu_short_noOdea <- fu_short %>% dplyr::filter(study_id != 9)
m <- meta::metagen(TE=te, seTE=se_te, studlab=author, data=fu_short_noOdea,
                   sm="SMD", common=FALSE, random=TRUE,
                   method.tau="REML", method.random.ci="HK")
summary(m)
                 
                 
            
                 