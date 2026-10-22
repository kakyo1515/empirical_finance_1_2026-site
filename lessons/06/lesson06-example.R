# 第6回：tidyverse流による財務・株式データ分析
# empirical_finance.Rprojを開き、script/lesson06.Rとして保存して使用する。
# tidyverseを事前にインストールし、data/data_lesson06.csvとoutputフォルダを準備する。
# output/npv-comparison.pngに同名のファイルがある場合は上書きされる。

# 作業の準備

# 計算に使う関数を確認する
# 第5回の関数がProjectに復元されていれば、そのまま使用する。
# 以下の定義は、関数が保存されておらず、復元されていない場合のみ実行する。

# 第5回で作成したNPV・IRRの関数を再定義する
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

library(tidyverse) # dplyrやggplot2などをまとめて読み込む

# 3. パイプ演算子

cash_flows <- c(-100, 30, 40, 50, 30, 25, 20, 15, 10)
present_values <- cash_flows / (1 + 0.08)^(0:8)

round(sum(present_values), digits = 2)

# R標準のパイプ|>で、同じ順に「合計→丸める」と処理する
present_values |>
  sum() |>
  round(digits = 2)

# 練習：次のコードを、cash_flowsから始めてパイプ演算子|>で処理をつなぐ形に
# 書き換え、同じ結果（67.59）が得られることを確認する。
round(calculate_npv(cash_flows, discount_rate = 0.08), digits = 2)

# Chapter 2｜tidyverseの基本操作

# 1. データの読み込み

cash_flow_data <- read_csv(
  "data/data_lesson06.csv",
  na = c("", "NA"),
  show_col_types = FALSE
)
head(cash_flow_data)

dim(cash_flow_data)
colSums(is.na(cash_flow_data))

# 2. データの抽出

project_a <- cash_flow_data |>
  filter(project == "A") |>   # 条件を満たす行を残す
  select(period, cash_flow)   # 必要な列を選ぶ

project_a

# 複数の条件をカンマで区切ると、すべての条件を満たす行を抽出する。
cash_flow_data |>
  filter(project == "B", period >= 1) |> # カンマで並べた条件をすべて満たす行
  select(period, cash_flow)

# |（または）でつなぐと、いずれかの条件を満たす行を抽出する。
cash_flow_data |>
  filter(project == "B" | project == "C") # いずれかの条件を満たす行

# 練習：投資案Eのうち、キャッシュフローが負となる行を抽出し、
# periodとcash_flowの列だけを取り出す。filter()とselect()を|>でつなぐこと。

# 3. 新しい列の追加

discount_rate <- 0.08

# mutate()で各行を計算し、元の列を残したまま新しい列を追加する
pv_data <- cash_flow_data |>
  mutate(
    present_value = cash_flow / (1 + discount_rate)^period
  )

head(pv_data)

# 練習：pv_dataに円単位の列cash_flow_yenを追加し、pv_yen_dataに保存する。
# 1万円は10,000円である。head()で表示し、元のcash_flow列と見比べること。

# 4. グループごとに集計する

# (1) group_by()でグループを指定する
pv_grouped <- pv_data |>
  group_by(project) # 以後の集計を投資案ごとに分けて行う

pv_grouped

# (2) summarise()でグループごとに集計する
project_results <- pv_grouped |>
  summarise( # 各投資案のデータを1行の集計結果にまとめる
    NPV = sum(present_value),
    IRR = calculate_irr(cash_flow, periods = period)
  ) |>
  mutate(IRR_percent = IRR * 100) # 小数のIRRを百分率に換算する

project_results

# 練習：cash_flow_dataから時点1以降の行を取り出し、投資案ごとの
# キャッシュフローの平均を求める。結果の列名はmean_cash_flowとする。

# 5. 結果を並べ替える

project_results |>
  arrange(desc(NPV)) |> # arrange()で並べ替え、desc()で大きい順にする
  select(project, NPV, IRR_percent)

# Chapter 3｜ggplot2によるデータ可視化

# 1. ggplot2による作図の基本
# (1) データと変数の対応を指定する
# (2) 図の層を加える
# (3) ラベルや見た目を整える
# (4) 図を表示する

# 2. NPVの棒グラフ

# (1) データと変数の対応を指定する
# ggplot()で作図の土台を作り、aes()で列と軸の対応を指定する
npv_base <- ggplot(
  data = project_results,
  mapping = aes(x = project, y = NPV)
)

# (2) 図の層を加える
# +で図の層を重ねる（パイプの|>とは異なる）
npv_layers <- npv_base +
  geom_col(fill = "skyblue") + # 集計済みのNPVを棒の高さにし、内側の色を指定する
  geom_hline(yintercept = 0, colour = "gray") # y = 0に基準線を引く

# (3) ラベルや見た目を整える
# labs()でタイトルと軸名を設定する（データの値は変えない）
npv_plot <- npv_layers +
  labs(
    title = "NPV by Project",
    x = "Project",
    y = "NPV (10,000 yen)"
  ) +
  theme_classic() # 白い背景と軸線だけのテーマにする

# (4) 図を表示する
print(npv_plot)

# 3. キャッシュフローの折れ線グラフ

# (1) データと変数の対応を指定する
cash_flow_base <- ggplot(
  data = cash_flow_data,
  mapping = aes(x = period, y = cash_flow, colour = project) # 投資案ごとに色分けする
)

# (2) 図の層を加える
cash_flow_layers <- cash_flow_base +
  geom_point() + # 各時点の値を点で描く
  geom_line() +  # 同じ投資案の点を時点順に結ぶ
  geom_hline(yintercept = 0, colour = "gray")

# (3) ラベルや見た目を整える
cash_flow_plot <- cash_flow_layers +
  labs(
    title = "Cash Flows by Project",
    x = "Year",
    y = "Cash flow (10,000 yen)",
    colour = "Project" # 色の凡例のタイトル
  ) +
  scale_x_continuous(breaks = 0:8) + # 横軸の目盛りを0から8まで1刻みにする
  theme_classic()

# (4) 図を表示する
print(cash_flow_plot)

# 4. 図を保存する

# ggsave()で指定したggplotの図をファイルに保存する
ggsave(
  filename = "output/npv-comparison.png",
  plot = npv_plot,
  width = 7,
  height = 4.5,
  units = "in", # widthとheightの単位はインチ
  dpi = 160     # 画像の解像度
)
