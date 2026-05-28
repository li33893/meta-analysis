#### 101_export_study_characteristics.R ####
#### Purpose: produce study_characteristics.csv ####


### 1. Load data ###

source("C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/scripts/01_read_data.R")


### 2. Select the columns ###
study_characteristics <- study_info %>%
  dplyr::arrange(author, year) %>%                   # 按作者首字母排序
  dplyr::mutate(study = paste(author, year)) %>% 
  dplyr::select(
    Study              = study,
    Country            = country,
    Program            = program,
    Age_range          = age_range,
    Recruitment        = recruitment,
    Inclusion_criteria = inclusion_criteria,
    Baseline_severity  = baseline_severity,
    Dosage             = dosage,
    Support_level      = support_level,
    Delivery           = delivery,
    CBT_components     = cbt_components,
    Publication_type   = publication_type,
    Funding            = funding
  )


### 3. Save ###
results_dir <- "C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/results"

readr::write_csv(
  study_characteristics,
  file.path(results_dir, "tables", "study_characteristics.csv")
)


cat("11_export_study_characteristics.R completed successfully.\n")