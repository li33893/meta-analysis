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


### 5. Forest plot ###
figures_dir <- "C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/figures"

png(file.path(figures_dir, "forest_post.png"),
    width  = 3000,
    height = 800 + 200 * nrow(data_to_be_pooled),
    res    = 300)

forest(model_post,
       sortvar     = TE,
       smlab       = "Hedges' g",
       leftlabs    = c("Study", "g", "95% CI"),
       label.left  = "Favours Control",
       label.right = "Favours Intervention",
       col.diamond = "steelblue",
       print.tau2  = TRUE,
       print.I2    = TRUE,
       prediction  = TRUE,
       xlim        = c(-2, 2),
       main        = "Post-intervention")

dev.off()
cat("Post-intervention forest plot saved to figures/\n")

### 6. Save files ###
results_dir <- "C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/results"

saveRDS(model_post, file.path(results_dir, "models", "model_post.rds"))
readr::write_csv(data_to_be_pooled, file.path(results_dir, "tables", "post_data.csv"))



