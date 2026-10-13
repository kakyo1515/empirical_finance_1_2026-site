# 第6回：tidyverse流による財務・株式データ分析
# empirical_finance.Rprojを開き、script/lesson06.Rとして保存して使用する。
# tidyverseを事前にインストールし、data/cash-flows-lesson06.csvとoutputフォルダを準備する。
# output/npv-comparison.pngに同名のファイルがある場合は上書きされる。

# 作業の準備

# 計算に使う関数を確認する
# 第5回の関数がProjectに復元されていれば、そのまま使用する。
# 以下の定義は、関数が保存されておらず、復元されていない場合のみ実行する。

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

# Chapter 1｜tidyverseとパイプ

# 2. tidyverseを読み込む

library(tidyverse)

# 3. パイプ演算子

cash_flows <- c(-100, 30, 40, 50, 30, 25, 20, 15, 10)
present_values <- cash_flows / (1 + 0.08)^(0:8)

round(sum(present_values), digits = 2)

present_values |>
  sum() |>
  round(digits = 2)

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

# 2. データの抽出

project_a <- cash_flow_data |>
  filter(project == "A") |>
  select(period, cash_flow)

project_a

# 複数の条件をカンマで区切ると、すべての条件を満たす行を抽出する。
cash_flow_data |>
  filter(project == "B", period >= 1) |>
  select(period, cash_flow)

# |（または）でつなぐと、いずれかの条件を満たす行を抽出する。
cash_flow_data |>
  filter(project == "B" | project == "C")

# 「BまたはC」と「時点1以降」を組み合わせる。
cash_flow_data |>
  filter(
    (project == "B" | project == "C"),
    period >= 1
  )

# 3. 新しい列の追加

discount_rate <- 0.08

pv_data <- cash_flow_data |>
  mutate(
    present_value = cash_flow / (1 + discount_rate)^period
  )

head(pv_data)

# 4. 投資案ごとに集計する

# (1) group_by()でグループを指定する
pv_grouped <- pv_data |>
  group_by(project)

pv_grouped

# (2) summarise()でグループごとに集計する
pv_grouped |>
  summarise(
    NPV = sum(present_value),
    .groups = "drop"
  )

# (3) NPVとIRRをまとめて計算する
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

# 1. ggplot2の作図の考え方

# 2. NPVの棒グラフを段階的に作る

# (1) 作図するデータを確認する

project_results |>
  select(project, NPV)

# (2) データと軸を指定する

npv_base <- ggplot(
  data = project_results,
  mapping = aes(x = project, y = NPV)
)

print(npv_base)

# (3) 棒の層を加える

npv_bars <- npv_base +
  geom_col()

print(npv_bars)

# (4) 棒の色を指定する

npv_coloured <- npv_base +
  geom_col(fill = "skyblue")

print(npv_coloured)

# (5) 軸のラベルを付ける

npv_labelled <- npv_coloured +
  labs(x = "Project", y = "NPV (10,000 yen)")

print(npv_labelled)

# (6) NPVが0となる基準線を加える

npv_reference <- npv_labelled +
  geom_hline(yintercept = 0, colour = "gray")

print(npv_reference)

# (7) テーマを指定する

npv_plot <- npv_reference +
  theme_classic()

print(npv_plot)

# 3. キャッシュフローの折れ線グラフを段階的に作る

# (1) 時点と金額を点で表す

cash_flow_base <- ggplot(
  data = cash_flow_data,
  mapping = aes(x = period, y = cash_flow)
)

cash_flow_points <- cash_flow_base +
  geom_point()

print(cash_flow_points)

# (2) 投資案ごとに色を分ける

cash_flow_colour_base <- ggplot(
  data = cash_flow_data,
  mapping = aes(x = period, y = cash_flow, colour = project)
)

cash_flow_coloured <- cash_flow_colour_base +
  geom_point()

print(cash_flow_coloured)

# (3) 同じ投資案の点を線で結ぶ

cash_flow_lines <- cash_flow_coloured +
  geom_line()

print(cash_flow_lines)

# (4) 横軸の目盛りを各年に付ける

cash_flow_years <- cash_flow_lines +
  scale_x_continuous(breaks = 0:8)

print(cash_flow_years)

# (5) 軸と凡例の名前を付ける

cash_flow_labelled <- cash_flow_years +
  labs(
    x = "Year",
    y = "Cash flow (10,000 yen)",
    colour = "Project"
  )

print(cash_flow_labelled)

# (6) 基準線とテーマを加えて仕上げる

cash_flow_plot <- cash_flow_labelled +
  geom_hline(yintercept = 0, colour = "gray") +
  theme_classic()

print(cash_flow_plot)

# 4. 図を保存する

ggsave(
  filename = "output/npv-comparison.png",
  plot = npv_plot,
  width = 7,
  height = 4.5,
  units = "in",
  dpi = 160
)
