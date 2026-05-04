# Related chapters in Doing Meta with R:
# 1. Basic statistical knowledge — 3.1
# 2. Effect size calculation — 3.3.1 (SMD) + 3.4.1 small sample bias (Hedge's g)
# 3. When data formats are not minimum raw data (pre-calculate; see in Pre-calculate_effects.R) — 3.5.1 (guide) + 17 “Helpful Tools” section (several effect size converters) + 4.2.1 metagen function (allows us to perform a meta-analysis of effect size data that had to be pre-calculated) + prepare two more columns as 3.5.1 guiding

#### 02_compute_effect_sizes.R ####
#### Purpose: compute Hedges' g and sampling variance for each outcome row ####


#### 1. Load cleaned data ####

source("C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/scripts/01_read_data.R")


#### 2. Check required columns ####

required_cols <- c(
  "study_id",
  "author",
  "timepoint",
  "timing_mo",
  "n_exp",
  "n_ctrl",
  "m_exp",
  "sd_exp",
  "m_ctrl",
  "sd_ctrl",
  "measure"
)

missing_cols <- setdiff(required_cols, names(outcome_data))  # setdiff(A, B) 的意思是：A 里面有，但 B 里面没有的东西

if (length(missing_cols) > 0) {
  stop(
    "These required columns are missing from Outcome_Data: ",
    paste(missing_cols, collapse = ", ")
  )
}


#### 3. Keep rows with enough raw data for effect size calculation ####

effect_input <- outcome_data %>%
  dplyr::filter(
    !is.na(n_exp),
    !is.na(n_ctrl),
    !is.na(m_exp),
    !is.na(sd_exp),
    !is.na(m_ctrl),
    !is.na(sd_ctrl)
  )



#### 4. Compute standardized mean difference using metafor ####

effect_data_raw <- metafor::escalc(
  measure = "SMD",
  m1i = m_exp,
  sd1i = sd_exp,
  n1i = n_exp,
  m2i = m_ctrl,
  sd2i = sd_ctrl,
  n2i = n_ctrl,
  data = effect_input
)


#### 5. Make direction easier to interpret ####
#### Depression scores: lower = better.
#### metafor calculates m1 - m2.
#### If intervention has lower depression than control, raw yi is negative.
#### We multiply by -1 so positive yi means "favours intervention". ####

effect_data <- effect_data_raw %>%
  dplyr::mutate(
    # 1. Save the original results from escalc()
    hedges_g_original = yi,
    variance_original = vi,
    se_original = sqrt(variance_original),
    
    # 2. Reverse the direction so that positive values mean intervention is better
    hedges_g_final = -hedges_g_original,
    variance_final = variance_original,
    se_final = sqrt(variance_final),
    
    # 3. Keep standard names for later meta-analysis functions
    yi = hedges_g_final,
    vi = variance_final,
    te = hedges_g_final,
    se_te = se_final,
    
    # 4. Record how to interpret the direction
    effect_direction = "positive values favor intervention"
  )


#### 6. Inspect computed effect sizes ####

effect_data %>%
  dplyr::select(
    study_id,
    author,
    timepoint,
    timing_mo,
    measure,
    n_exp,
    n_ctrl,
    m_exp,
    sd_exp,
    m_ctrl,
    sd_ctrl,
    hedges_g_original,
    variance_final,
    yi,
    vi,
    se_te,
    effect_direction
  ) %>%
  print(n = Inf)  # 把所有行都打印出来


#### 7. Export effect-size dataset ####

# 7.1 Create output folders if they do not exist

dir.create(
  "C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/results/models",
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  "C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/results/tables",
  recursive = TRUE,
  showWarnings = FALSE
)


# 7.2 Save R object for later analysis scripts

saveRDS(
  effect_data,
  file = "C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/results/models/effect_data.rds"
)


# 7.3 Optional: export a CSV version for manual checking

readr::write_csv(
  effect_data,
  file = "C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/results/tables/effect_data.csv"
)


#### 8. Finish ####

cat("02_compute_effect_sizes.R completed successfully.\n")