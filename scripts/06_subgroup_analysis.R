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
    has_rx = sapply(stringr::str_split(cbt_components, "\\+"), 
                    function(x) "rx" %in% x),
    has_ps = sapply(stringr::str_split(cbt_components, "\\+"), 
                    function(x) "ps" %in% x),
    has_hw = sapply(stringr::str_split(cbt_components, "\\+"), 
                    function(x) "hw" %in% x)
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


### 5. Subgroup analyses (fixed-effects plural model) ###

sg_control  <- update(model_sub, subgroup = control_2lvl,    tau.common = TRUE)
sg_severity <- update(model_sub, subgroup = severity_2lvl,   tau.common = TRUE)
sg_human    <- update(model_sub, subgroup = human_contact_f, tau.common = TRUE)
sg_rx       <- update(model_sub, subgroup = has_rx,          tau.common = TRUE)
sg_ps       <- update(model_sub, subgroup = has_ps,          tau.common = TRUE)
sg_hw       <- update(model_sub, subgroup = has_hw,          tau.common = TRUE)


### 6. Save files ###

results_dir <- "C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/results"

saveRDS(sg_control,  file.path(results_dir, "models", "sg_control.rds"))
saveRDS(sg_severity, file.path(results_dir, "models", "sg_severity.rds"))
saveRDS(sg_human,    file.path(results_dir, "models", "sg_human.rds"))
saveRDS(sg_rx,       file.path(results_dir, "models", "sg_rx.rds"))
saveRDS(sg_ps,       file.path(results_dir, "models", "sg_ps.rds"))
saveRDS(sg_hw,       file.path(results_dir, "models", "sg_hw.rds"))

extract_sg <- function(sg, var_name) {
  tibble::tibble(
    subgroup_variable = var_name,
    level             = as.character(sg$subgroup.levels),
    k                 = sg$k.w,
    g                 = sg$TE.random.w,
    ci_lo             = sg$lower.random.w,
    ci_hi             = sg$upper.random.w,
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
  extract_sg(sg_hw,       "Homework")
)

readr::write_csv(subgroup_summary, 
                 file.path(results_dir, "tables", "subgroup_summary.csv"))
