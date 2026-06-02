#### 06_subgroup_analysis.R ####
#### To contrast the pooled effect of each pair of subgroups #####
#### Important decision: ####



### 1. Load data and helper paths ####

source("C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/scripts/02_compute_effect_sizes.R")

figures_dir <- "C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/figures"


### 2. Join the data not contained in effect_data.rds ###

post_data <- effect_data %>%
  dplyr::filter(timepoint == "post", study_id != 3) %>%
  dplyr::inner_join(
    study_info %>%
      dplyr::select(
        study_id = c,                  # ← 在 select 里改名
        control_type,
        baseline_severity,
        human_contact,
        cbt_components
      ),
    by = "study_id"
  )


### 3. Build new columns: construct variations of subgroups ###

data_sub <- post_data %>%
  dplyr::mutate(
    
    ### 3-1. control type: passive/minimal ###
    control_2lvl = dplyr::case_when(
      stringr::str_detect(control_type, "WL|TAU|Assessment-only") ~ "Passive",
      stringr::str_detect(control_type, "Attention|Information")  ~ "Minimal"
    ),
    
    ### 3-2. severity: low/high ###
    severity_2lvl = dplyr::case_when(
      baseline_severity %in% c("Mild", "Mild-Moderate") ~ "Low",
      baseline_severity %in% c("Moderate", "Severe")    ~ "High"
    ),
    
    ### 3-3. human contact: yes/no ###
    human_contact_f = factor(human_contact, 
                             levels = c(0, 1), 
                             labels = c("No", "Yes")),
    
    ### 3-4. components ###
    ### 用 Present/Absent 显式 factor，Present 在前，固定亚组顺序 ###
    has_rx = factor(
      ifelse(sapply(stringr::str_split(cbt_components, "\\+"),
                    function(x) "rx" %in% x), "Present", "Absent"),
      levels = c("Present", "Absent")),
    has_ps = factor(
      ifelse(sapply(stringr::str_split(cbt_components, "\\+"),
                    function(x) "ps" %in% x), "Present", "Absent"),
      levels = c("Present", "Absent")),
    has_hw = factor(
      ifelse(sapply(stringr::str_split(cbt_components, "\\+"),
                    function(x) "hw" %in% x), "Present", "Absent"),
      levels = c("Present", "Absent")),
    has_rp = factor(
      ifelse(sapply(stringr::str_split(cbt_components, "\\+"),
                    function(x) "rp" %in% x), "Present", "Absent"),
      levels = c("Present", "Absent")),
    has_ist = factor(
      ifelse(sapply(stringr::str_split(cbt_components, "\\+"),
                    function(x) "ist" %in% x), "Present", "Absent"),
      levels = c("Present", "Absent"))
  )



### 4. Refit metagen on data_sub ###
model_sub <- meta::metagen(
  TE               = te,
  seTE             = se_te,
  studlab          = author,
  data             = data_sub,
  sm               = "SMD",
  common           = FALSE,
  random           = TRUE,
  method.tau       = "REML",
  method.random.ci = "HK",
  prediction       = TRUE
)

### 4.5. Override summary.meta to print within-subgroup p-values for g ###

summary.meta <- function(object, ...) {
  meta:::print.meta(object, ...)
  if (!is.null(object$subgroup.levels)) {
    cat("\nWithin-subgroup p-values for pooled g (random effects, HK):\n")
    df <- data.frame(
      Level = object$subgroup.levels,
      k     = object$k.w,
      g     = sprintf("%.4f", object$TE.random.w),
      p_g   = sprintf("%.4f", object$pval.random.w)
    )
    print(df, row.names = FALSE)
  }
  invisible(object)
}


### 5. Subgroup analyses (fixed-effects plural model) ###

sg_control  <- update(model_sub, subgroup = control_2lvl,    tau.common = TRUE)
sg_severity <- update(model_sub, subgroup = severity_2lvl,   tau.common = TRUE)
sg_human    <- update(model_sub, subgroup = human_contact_f, tau.common = TRUE)
sg_rx       <- update(model_sub, subgroup = has_rx,          tau.common = TRUE)
sg_ps       <- update(model_sub, subgroup = has_ps,          tau.common = TRUE)
sg_hw       <- update(model_sub, subgroup = has_hw,          tau.common = TRUE)
sg_rp       <- update(model_sub, subgroup = has_rp,          tau.common = TRUE)
sg_ist      <- update(model_sub, subgroup = has_ist,         tau.common = TRUE)


### 6. Save files ###

results_dir <- "C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/results"

saveRDS(sg_control,  file.path(results_dir, "models", "sg_control.rds"))
saveRDS(sg_severity, file.path(results_dir, "models", "sg_severity.rds"))
saveRDS(sg_human,    file.path(results_dir, "models", "sg_human.rds"))
saveRDS(sg_rx,       file.path(results_dir, "models", "sg_rx.rds"))
saveRDS(sg_ps,       file.path(results_dir, "models", "sg_ps.rds"))
saveRDS(sg_hw,       file.path(results_dir, "models", "sg_hw.rds"))
saveRDS(sg_rp,       file.path(results_dir, "models", "sg_rp.rds"))
saveRDS(sg_ist,      file.path(results_dir, "models", "sg_ist.rds"))

extract_sg <- function(sg, var_name) {
  tibble::tibble(
    subgroup_variable = var_name,
    level             = as.character(sg$subgroup.levels),
    k                 = sg$k.w,
    g                 = sg$TE.random.w,
    ci_lo             = sg$lower.random.w,
    ci_hi             = sg$upper.random.w,
    p_g               = sg$pval.random.w,
    I2                = sg$I2.w,
    tau2              = sg$tau2.w,
    Q_between         = sg$Q.b.random,       # 标量，tibble 会自动 recycle
    p_between         = sg$pval.Q.b.random   # 同上
  )
}

subgroup_summary <- dplyr::bind_rows(
  extract_sg(sg_control,  "Control type"),
  extract_sg(sg_severity, "Baseline severity"),
  extract_sg(sg_human,    "Human contact"),
  extract_sg(sg_rx,       "Relaxation"),
  extract_sg(sg_ps,       "Problem-solving"),
  extract_sg(sg_hw,       "Homework"),
  extract_sg(sg_rp,       "Relapse prevention"),
  extract_sg(sg_ist,      "Interpersonal skills training")
)

readr::write_csv(subgroup_summary, 
                 file.path(results_dir, "tables", "subgroup_summary.csv"))


### 7. Build publication-ready Table 5 ###

# 辅助函数：从一个 sg 对象抠全部需要的数字
extract_sg_full <- function(sg, var_name, tier) {
  tibble::tibble(
    tier              = tier,
    subgroup_variable = var_name,
    level             = as.character(sg$subgroup.levels),
    k                 = sg$k.w,
    g_num             = sg$TE.random.w,
    ci_lo_num         = sg$lower.random.w,
    ci_hi_num         = sg$upper.random.w,
    p_within_num      = sg$pval.random.w,
    I2_num            = sg$I2.w,
    I2_lo_num         = sg$lower.I2.w,
    I2_hi_num         = sg$upper.I2.w,
    p_between_num     = sg$pval.Q.b.random
  )
}

# 组装 12 行原始数字表
subgroup_raw <- dplyr::bind_rows(
  extract_sg_full(sg_control,  "Control type",       "Confirmatory"),
  extract_sg_full(sg_severity, "Baseline severity",  "Confirmatory"),
  extract_sg_full(sg_human,    "Human contact",      "Exploratory"),
  extract_sg_full(sg_rx,       "Relaxation",         "Exploratory"),
  extract_sg_full(sg_ps,       "Problem-solving",    "Exploratory"),
  extract_sg_full(sg_hw,       "Homework",           "Exploratory"),
  extract_sg_full(sg_rp,       "Relapse prevention",  "Exploratory"),
  extract_sg_full(sg_ist,      "Interpersonal skills training",    "Exploratory")
)

# 帮助函数：格式化 p 值（< .001 不写数字，否则 3 位小数无前导零）
fmt_p <- function(p) {
  ifelse(p < .001, "< .001",
         sub("^0", "", sprintf("%.3f", p)))
}

# 格式化：把 level 标签也美化一下
relabel <- function(var, lvl) {
  dplyr::case_when(
    lvl == "TRUE"     ~ "Present",
    lvl == "FALSE"    ~ "Absent",
    lvl == "Yes"      ~ "Yes",
    lvl == "No"       ~ "No",
    lvl == "Passive"  ~ "Passive",
    lvl == "Minimal"  ~ "Minimally active",
    lvl == "Low"      ~ "Low",
    lvl == "High"     ~ "High",
    TRUE              ~ lvl
  )
}

# 格式化后的展示表：每行一个亚组层
subgroup_fmt <- subgroup_raw %>%
  dplyr::mutate(
    level_disp    = purrr::map2_chr(subgroup_variable, level, relabel),
    g_disp        = sprintf("%.2f", g_num),
    ci_disp       = sprintf("[%.2f, %.2f]", ci_lo_num, ci_hi_num),
    p_within_disp = fmt_p(p_within_num),
    I2_disp       = sprintf("%.1f%% [%.1f, %.1f]", 
                            I2_num*100, I2_lo_num*100, I2_hi_num*100),
    p_between_disp = fmt_p(p_between_num)
  ) %>%
  # 只在每个 variable 的第一行显示 p_between，第二行留空
  dplyr::group_by(subgroup_variable) %>%
  dplyr::mutate(
    p_between_disp = ifelse(dplyr::row_number() == 1, p_between_disp, "")
  ) %>%
  dplyr::ungroup() %>%
  dplyr::select(tier, subgroup_variable, level_disp, k, 
                g_disp, ci_disp, p_within_disp, I2_disp, p_between_disp) %>%
  dplyr::rename(
    Tier             = tier,
    `Subgroup variable` = subgroup_variable,
    Level            = level_disp,
    `Hedges' g`      = g_disp,
    `95% CI`         = ci_disp,
    `p (within)`     = p_within_disp,
    `I² [95% CI]`    = I2_disp,
    `p (between)`    = p_between_disp
  )

# 写出 CSV：Excel 打开后全选 → Ctrl+C → 粘贴到 Word
readr::write_csv(subgroup_fmt, 
                 file.path(results_dir, "tables", "table5_subgroups_formatted.csv"))

# 在控制台输出 Markdown 表（也可以直接复制贴进 Word）
print(knitr::kable(subgroup_fmt, format = "pipe", align = "lllrrlrll"))

summary(sg_hw)
summary(sg_rx)
summary(sg_ps)
summary(sg_rp)
summary(sg_ist)

summary(sg_severity)
summary(sg_human)
