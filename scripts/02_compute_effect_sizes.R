#### 02_compute_effect_sizes.R ####
#### Purpose: compute Hedges' g for each outcome row ####

# Three data types are handled separately based on m_type:
#   "raw"          → escalc(SMD) on post-test means
#   "change score" → escalc(SMD) on change scores (SD derived from change CI)
#   "d"            → use reported between-group d directly (SE from CI)
#
# All depression measures: lower score = better.
# Raw computation gives exp − ctrl, so we flip sign at the end:
# positive g_final = intervention favoured.


#### 1. Load data ####

source("C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/scripts/01_read_data.R")


#### 2. Type A — raw post-test means ####
# escalc() is a function from the metafor package for computing effect sizes.
# You supply means, standard deviations, and sample sizes.
# It returns your original data frame with two new columns added:
#   yi — the effect size (Hedges' g, raw value)
#   vi — the sampling variance of yi (used later in the meta-analysis)

# as_tibble() converts the data frame to a tibble.
# A tibble is a modern version of a data frame — same thing,
# just prints more neatly in the console (shows only the first 10 rows).
# No effect on the actual data or calculations.

dataA <- outcome_data %>% dplyr::filter(m_type == "raw")

esA <- metafor::escalc(
  measure = "SMD",
  m1i = m_exp,  sd1i = sd_exp,  n1i = n_exp,
  m2i = m_ctrl, sd2i = sd_ctrl, n2i = n_ctrl,
  data = dataA
) %>%
  tibble::as_tibble() %>%
  dplyr::mutate(method = "escalc_SMD") # # Add a new column called "method", filling every row with the string "escalc_SMD".

#### 3. Type B — change scores (derive change SD from CI) ####
# SD = (CI_upper − CI_lower) × √n / (2 × 1.96)

dataB <- outcome_data %>%
  dplyr::filter(m_type == "change score") %>%
  dplyr::mutate(
    sd_change_exp  = (ci_upper_exp  - ci_lower_exp ) * sqrt(n_exp ) / 3.92,
    sd_change_ctrl = (ci_upper_ctrl - ci_lower_ctrl) * sqrt(n_ctrl) / 3.92
  )

esB <- metafor::escalc(
  measure = "SMD",
  m1i = change_mean_exp,  sd1i = sd_change_exp,  n1i = n_exp,
  m2i = change_mean_ctrl, sd2i = sd_change_ctrl, n2i = n_ctrl,
  data = dataB
) %>%
  tibble::as_tibble() %>%
  dplyr::mutate(method = "escalc_SMD_change")


#### 4. Type C — reported between-group d with CI ####
# SE = (CI_upper − CI_lower) / (2 × 1.96)

esC <- outcome_data %>%
  dplyr::filter(m_type == "d") %>%
  dplyr::mutate(
    yi     = reported_d_between,
    vi     = ((ci_upper_between - ci_lower_between) / 3.92) ^ 2,
    method = "reported_d"
  )


#### 5. Combine and flip sign ####

effect_data <- dplyr::bind_rows(esA, esB, esC) %>%
  dplyr::mutate(
    hedges_g_original = yi,
    variance_original = vi,
    se_original       = sqrt(vi),
    
    # Flip so positive = intervention favored (variance unchanged)
    hedges_g_final = -yi,
    variance_final = vi,
    se_final       = sqrt(vi),
    
    yi    = hedges_g_final,
    vi    = variance_final,
    te    = hedges_g_final,
    se_te = se_final,
    
    effect_direction = "positive values favor intervention"
  )


#### 6. Quick look ####

effect_data %>%
  dplyr::select(study_id, author, timepoint, measure, method,
                hedges_g_final, se_final) %>%
  dplyr::mutate(dplyr::across(c(hedges_g_final, se_final), ~ round(., 3))) %>%
  print(n = Inf)


#### 7. Export ####

# Set the path to the results folder
results_dir <- "C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/results"

# Create subfolders if they do not exist
# recursive = TRUE: create parent folders if they do not exist
# showWarnings = FALSE: suppress warning if the folder already exists
dir.create(file.path(results_dir, "models"), recursive = TRUE, showWarnings = FALSE)
dir.create(file.path(results_dir, "tables"), recursive = TRUE, showWarnings = FALSE)

# Save R object for use in later scripts
saveRDS(effect_data, file.path(results_dir, "models", "effect_data.rds"))

# Export CSV for manual checking in Excel
readr::write_csv(effect_data, file.path(results_dir, "tables", "effect_data.csv"))

cat("02_compute_effect_sizes.R completed successfully.\n")