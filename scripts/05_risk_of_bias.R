#### 05_risk_of_bias.R ####
#### Purpose: prepare RoB 2.0 data and generate risk of bias plots ####

#### 1. Load data ####
source("C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/scripts/01_read_data.R")

#### 2. Extract data_rob2 ####
data_rob2 <- rob_data %>%
  select(
    Study   = author_year,
    D1      = d1_randomization_low_some_high,
    D2      = d2_deviations_low_some_high,
    D3      = d3_missing_data_low_some_high,
    D4      = d4_measurement_low_some_high,
    D5      = d5_selection_of_results_low_some_high,
    Overall = overall_low_some_high
  ) %>%
  mutate(
    # 去掉 "et al." 及前后逗号空格
    Study  = stringr::str_remove(Study, ",?\\s*et\\s+al\\.?,?\\s*"),
    # 去掉 "& 2010" / "+ 2021" 这种第二个年份及其连接符
    Study  = stringr::str_remove(Study, "\\s*[&+]\\s*\\d{4}"),
    # 整理空格
    Study  = stringr::str_squish(Study),
    # 统一成 Author, Year 格式
    Study  = stringr::str_replace(Study, "\\s*,?\\s*(\\d{4})$", ", \\1"),
    Weight = 1
  )

#### 3. Quick look ####
glimpse(data_rob2)
nrow(data_rob2)
data_rob2 %>% pull(Study) %>% print()

#### 4. Define output path ####
fig_dir <- "C:/Users/32283/OneDrive/바탕 화면/meta-analysis/meta-analysis-project/figures"

#### 5. Summary bar plot ####
p_summary <- rob_summary(data_rob2, tool = "ROB2", colour = "colourblind")

ggsave(file.path(fig_dir, "rob_summary.pdf"),
       plot = p_summary, width = 7, height = 4)
ggsave(file.path(fig_dir, "rob_summary.png"),
       plot = p_summary, width = 8.5, height = 4, dpi = 600)

#### 6. Traffic light plot ####
p_traffic <- rob_traffic_light(data_rob2, tool = "ROB2", colour = "colourblind") +
  ggplot2::theme(
    strip.text.y.left = ggplot2::element_text(angle = 0, hjust = 0.5, size = 11),
    strip.text.y      = ggplot2::element_text(angle = 0, hjust = 0.5, size = 11)
  )

ggsave(file.path(fig_dir, "rob_traffic_light.pdf"),
       plot = p_traffic, width = 10, height = 13)
ggsave(file.path(fig_dir, "rob_traffic_light.png"),
       plot = p_traffic, width = 10, height = 13, dpi = 600)