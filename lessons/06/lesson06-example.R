# 第6回：tidyverse流データ分析
# empirical_finance.Rprojを開き、script/lesson06.Rとして保存して使用する。
# tidyverseを事前にインストールし、data/cash-flows-lesson06.csvとoutputフォルダを準備する。
# output/npv-comparison.pngに同名のファイルがある場合は上書きされる。

# Chapter 1｜tidyverseとパイプ

# 作業の準備

# 1. tidyverseを読み込む

library(tidyverse)

# 2. パイプで処理をつなぐ

cash_flows <- c(-100, 30, 40, 50, 30)
present_values <- cash_flows / (1 + 0.08)^(0:4)

round(sum(present_values), digits = 2)

present_values |>
  sum() |>
  round(digits = 2)

# 3. 計算に使う関数を用意する

calculate_npv <- function(cash_flows, discount_rate,
                          periods = seq_along(cash_flows) - 1) {
  present_values <- cash_flows / (1 + discount_rate)^periods
  sum(present_values)
}

calculate_irr <- function(cash_flows,
                          periods = seq_along(cash_flows) - 1,
                          interval = c(-0.99, 1)) {
  npv_function <- function(rate) {
    calculate_npv(cash_flows, rate, periods)
  }

  result <- uniroot(
    f = npv_function,
    interval = interval,
    tol = 1e-10
  )
  result$root
}

# Chapter 2｜投資案ごとにNPVとIRRを求める

# 1. CSVを読み込む

cash_flow_data <- read_csv(
  "data/cash-flows-lesson06.csv",
  na = c("", "NA"),
  show_col_types = FALSE
)
head(cash_flow_data)

dim(cash_flow_data)
colSums(is.na(cash_flow_data))

# 2. 行と列を選ぶ

project_a <- cash_flow_data |>
  filter(project == "A") |>
  select(period, cash_flow)

project_a

# 3. 現在価値の列を作る

discount_rate <- 0.08

pv_data <- cash_flow_data |>
  mutate(
    present_value = cash_flow / (1 + discount_rate)^period
  )

head(pv_data)

# 4. 投資案ごとに集計する

project_results <- pv_data |>
  group_by(project) |>
  summarise(
    NPV = sum(present_value),
    IRR = calculate_irr(cash_flow, periods = period),
    .groups = "drop"
  ) |>
  mutate(IRR_percent = IRR * 100)

project_results

# 5. 結果を並べ替える

project_results |>
  arrange(desc(NPV)) |>
  select(project, NPV, IRR_percent)

# Chapter 3｜ggplot2で結果を可視化する

# 1. NPVを棒グラフで比較する

npv_plot <- ggplot(project_results, aes(x = project, y = NPV)) +
  geom_col(fill = "skyblue") +
  geom_hline(yintercept = 0, colour = "gray") +
  labs(x = "Project", y = "NPV (10,000 yen)")

print(npv_plot)

# 2. キャッシュフローの変化を描く

cash_flow_plot <- ggplot(
  cash_flow_data,
  aes(x = period, y = cash_flow, colour = project)
) +
  geom_line() +
  geom_point() +
  labs(x = "Year", y = "Cash flow (10,000 yen)", colour = "Project")

print(cash_flow_plot)

# 3. 図を保存する

ggsave(
  "output/npv-comparison.png",
  plot = npv_plot,
  width = 7,
  height = 4.5
)
