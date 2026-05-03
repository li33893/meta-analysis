# Related chapters in Doing Meta with R:
# 1. Basic statistical knowledge — 3.1
# 2. Effect size calculation — 3.3.1 (SMD) + 3.4.1 small sample bias (Hedge's g)
# 3. When data formats are not minimum raw data (pre-calculate; see in Pre-calculate_effects.R) — 3.5.1 (guide) + 17 “Helpful Tools” section (several effect size converters) + 4.2.1 metagen function (allows us to perform a meta-analysis of effect size data that had to be pre-calculated) + prepare two more columns as 3.5.1 guiding

#### 02_compute_effect_sizes.R ####
#### Purpose: compute Hedges' g and sampling variance for each outcome row ####


#### 1. Load setup ####

source("C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/scripts/00_setup.R")


#### 2. Read Excel sheets ####

data_path <- "C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/data/data.xlsx"

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
  sheet = "PRISMA_Flow"
)




#### 3. Check imported data ####

# dplyr::glimpse(study_info)
# dplyr::glimpse(outcome_data)
# dplyr::glimpse(rob_data)
# dplyr::glimpse(exclusion_log)
# dplyr::glimpse(prisma_flow)


#### 4. Clean column names ####

#clean_names:自动把名字像spring的lambda一样转成带下划线的格式

study_info <- janitor::clean_names(study_info)
outcome_data <- janitor::clean_names(outcome_data)
rob_data <- janitor::clean_names(rob_data)
exclusion_log <- janitor::clean_names(exclusion_log)
prisma_flow <- janitor::clean_names(prisma_flow)

#### 4.1 Check cleaned column names ####

# names(study_info)
# names(outcome_data)
# names(rob_data)
# names(exclusion_log)
# names(prisma_flow)


#### 5. Convert numeric columns in Outcome_Data ####

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
  "reported_d_exp",
  "reported_d_ctrl",
  "ci_lower_between",
  "ci_upper_between",
  "reported_d_between",
  "te",
  "se_te",
  "n_dropout_exp",
  "n_dropout_ctrl"
)

outcome_data <- outcome_data %>%
  dplyr::mutate(
    dplyr::across(  # across()对多列一起操作; .cols是across 里的参数：选哪些列；.fns是across 里的参数：对这些列做什么函数
      .cols = dplyr::all_of(numeric_cols),  # all_of(): 按 numeric_cols 这个名字清单选列
      .fns = as.numeric
    )
  )

#### 5.1 Check column attributes ####

# dplyr::glimpse(outcome_data)  # if <dbl> showed up, then successfully runned


#### 6. Check missing values in numeric columns ####

missing_check <- outcome_data %>%
  dplyr::summarise(  # 把很多行压缩成一个汇总结果
    dplyr::across(
      .cols = dplyr::all_of(numeric_cols),
      .fns = ~ sum(is.na(.))  # 对当前这一列，数一数有几个 NA, 这里的 . 代表“当前正在处理的这一列”; is.na()是检查当前列里每个值是不是缺失值;~ 的意思是：定义一个临时的小函数,对每一列，执行后面这个操作
    )
  )

missing_check

# 如果 Console 里太宽，看不全，就运行
print(missing_check, width = Inf)


#### 7. Finish ####

cat("01_read_data.R completed successfully.\n")
