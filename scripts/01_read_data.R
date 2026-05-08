#### 01_read_data.R ####
#### Purpose: reading the excel data with R ####

#### 1. Load setup ####
source("C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/scripts/00_setup.R")

#### 2. Read Excel sheets ####
data_path = "C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/data/data.xlsx"

study_info <- readxl::read_excel(
  path = data_path,
  sheet = "Study_Info"
)
outcome_data <- readxl::read_excel(
  path = data_path,
  sheet = "Outcome_Data"
)
rob_data <- readxl::read_excel(
  path = data_path,
  sheet = "RoB_2.0"
)
exclusion_log <- readxl::read_excel(
  path = data_path,
  sheet = "Exclusion_Log"
)
prisma_flow <- readxl::read_excel(
  path = data_path,
  sheet = "PRISMA_Flow",
  skip  = 2          # skip the title row and the blank row; row 3 ("Stage", "n") becomes the header
)

#### 3. Clean column names ####
# clean_names() standardises all column names to lowercase_with_underscores
# (e.g. "Pre M exp" -> "pre_m_exp"), preventing errors in $, select(), across(), etc.
study_info    <- janitor::clean_names(study_info)
outcome_data  <- janitor::clean_names(outcome_data)
rob_data      <- janitor::clean_names(rob_data)
exclusion_log <- janitor::clean_names(exclusion_log)
prisma_flow   <- janitor::clean_names(prisma_flow)

#### 4. Convert numeric columns in Outcome_Data ####
# Columns read from Excel may be imported as character type; coerce all to numeric <dbl>numeric_cols <- c(
numeric_cols <- c(
  "study_id",
  "timing_mo",
  "n_exp",
  "n_ctrl",
  "pre_m_exp",
  "pre_sd_exp",
  "pre_m_ctrl",
  "pre_sd_ctrl",
  "m_exp",
  "sd_exp",
  "m_ctrl",
  "sd_ctrl",
  "ci_lower_exp",
  "ci_upper_exp",
  "ci_lower_ctrl",
  "ci_upper_ctrl",
  "change_mean_exp",         # 新增：Type B 用
  "change_mean_ctrl",        # 新增：Type B 用
  "ci_lower_between",
  "ci_upper_between",
  "reported_d_between",
  "te",
  "se_te",
  "n_dropout_exp",
  "n_dropout_ctrl"
)

outcome_data <- outcome_data %>%
  dplyr::mutate(                        # overwrite existing columns; row count unchanged
    dplyr::across(                      # apply the same function to multiple columns at once
      .cols = all_of(numeric_cols),     # all_of(): select columns by name vector
      .fns  = as.numeric                # coerce each selected column to numeric
    )
  )

cat("01_read_data.R completed successfully.\n")
