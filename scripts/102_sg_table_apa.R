#### 102_sg_table_apa.R ####
#### Build an APA-style three-line table (Table 5) for all subgroups ####
#### Run AFTER 06_subgroup_analysis.R (uses subgroup_raw already in memory) ####


### 1. Packages ###

# install.packages(c("flextable", "officer"))  # 首次运行解除注释
library(flextable)
library(officer)
library(dplyr)


### 2. Re-format subgroup_raw into display strings ###
### (与你 console 里的数字一致；不重算模型) ###

fmt_p <- function(p) {
  ifelse(p < .001, "< .001",
         sub("^0", "", sprintf("%.3f", p)))
}

relabel <- function(var, lvl) {
  dplyr::case_when(
    lvl == "TRUE"    ~ "Present",
    lvl == "FALSE"   ~ "Absent",
    lvl == "Yes"     ~ "Yes",
    lvl == "No"      ~ "No",
    lvl == "Passive" ~ "Passive",
    lvl == "Minimal" ~ "Minimally active",
    lvl == "Low"     ~ "Low",
    lvl == "High"    ~ "High",
    TRUE             ~ lvl
  )
}

tbl <- subgroup_raw %>%
  dplyr::mutate(
    Level     = purrr::map2_chr(subgroup_variable, level, relabel),
    g         = sprintf("%.2f", g_num),
    CI        = sprintf("[%.2f, %.2f]", ci_lo_num, ci_hi_num),
    p_within  = fmt_p(p_within_num),
    I2        = sprintf("%.1f", I2_num * 100),
    p_between = fmt_p(p_between_num)
  ) %>%
  # p_between 只在每个变量的第一行显示
  dplyr::group_by(subgroup_variable) %>%
  dplyr::mutate(
    p_between = ifelse(dplyr::row_number() == 1, p_between, ""),
    Variable  = ifelse(dplyr::row_number() == 1, subgroup_variable, "")
  ) %>%
  dplyr::ungroup() %>%
  dplyr::select(Variable, Level, k, g, CI, p_within, I2, p_between)


### 3. Build the flextable ###

ft <- flextable(tbl) %>%
  set_header_labels(
    Variable  = "Moderator",
    Level     = "Level",
    k         = "k",
    g         = "g",
    CI        = "95% CI",
    p_within  = "p",
    I2        = "I\u00b2 (%)",
    p_between = "p\u1d47"          # 上标 b，下面加注释说明是 between-groups
  )


### 4. Apply APA three-line style ###

ft <- ft %>%
  # 去掉所有边框
  border_remove() %>%
  # 顶线（表格最上）
  hline_top(part = "header",
            border = fp_border(color = "black", width = 1.5)) %>%
  # 表头与表体之间的线
  hline_bottom(part = "header",
               border = fp_border(color = "black", width = 1)) %>%
  # 底线（表格最下）
  hline_bottom(part = "body",
               border = fp_border(color = "black", width = 1.5)) %>%
  # 字体：APA 用 Times New Roman 12（表内可缩到 10 以塞进一页）
  font(fontname = "Times New Roman", part = "all") %>%
  fontsize(size = 10, part = "all") %>%
  fontsize(size = 10, part = "header") %>%
  # 对齐：文字列左对齐，数字列居中
  align(j = c("Variable", "Level"), align = "left", part = "all") %>%
  align(j = c("k", "g", "CI", "p_within", "I2", "p_between"),
        align = "center", part = "all") %>%
  # 行高紧凑，帮助塞进一页
  padding(padding.top = 2, padding.bottom = 2, part = "all") %>%
  # 表头加粗（APA 表头不加粗也可，按需删这行）
  bold(part = "header", bold = FALSE) %>%
  italic(j = "g", italic = TRUE, part = "header") %>%      # g 斜体
  italic(j = c("p_within", "p_between"), italic = TRUE, part = "header") %>%  # p 斜体
  italic(j = "I2", italic = FALSE, part = "header") %>%
  # 列宽（单位英寸，按需微调）
  width(j = "Variable",  width = 1.5) %>%
  width(j = "Level",     width = 1.3) %>%
  width(j = "k",         width = 0.4) %>%
  width(j = "g",         width = 0.5) %>%
  width(j = "CI",        width = 1.2) %>%
  width(j = "p_within",  width = 0.6) %>%
  width(j = "I2",        width = 0.7) %>%
  width(j = "p_between", width = 0.6)


### 5. Add caption + note (APA) ###

ft <- ft %>%
  add_header_lines(
    values = "Table 5"                                   # 表号
  ) %>%
  add_header_lines(
    values = "Subgroup Analyses of Post-Intervention Effect Sizes"  # 斜体标题
  ) %>%
  add_footer_lines(
    values = paste0(
      "Note. k = number of studies; g = Hedges\u2019 g (random-effects, ",
      "Hartung-Knapp); CI = confidence interval; I\u00b2 = heterogeneity. ",
      "All models used REML with a common \u03c4\u00b2 across subgroups. ",
      "\u1d47 p-value for the test of between-subgroup differences."
    )
  ) %>%
  italic(i = 2, part = "header", italic = TRUE) %>%       # 标题行斜体
  fontsize(i = 1:2, size = 11, part = "header") %>%
  align(i = 1:2, align = "left", part = "header") %>%
  font(fontname = "Times New Roman", part = "footer") %>%
  fontsize(size = 9, part = "footer") %>%
  italic(i = 1, j = 1, italic = TRUE, part = "footer")    # Note. 斜体


### 6. Export to Word ###

results_dir <- "C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/results"

doc <- read_docx() %>%
  body_add_flextable(ft) %>%
  # 横向页面更容易塞下；如要纵向删掉这段
  body_end_section_landscape()

print(doc, target = file.path(results_dir, "tables", "Table5_subgroups_APA.docx"))

cat("Table5_subgroups_APA.docx written.\n")