# 第4回：Rの基本操作 IV ― 関数・CSV・パッケージ・作図
# empirical_finance.Rprojを開き、data/data_lesson02.csvとoutputフォルダを準備する。
# readrは事前にインストールする。作図にはRの標準機能を使う。
# Chapter 1〜4の主要なコード例。補足・練習の解答は含めない。
# output内の同名ファイルは上書きされるため、実行前に保存先を確認する。


# Chapter 1｜関数を作成する

# 1. 計算式を関数にまとめる
# function(引数) { 処理 }で関数を定義し、名前を付ける
add_five <- function(x) {
  result <- x + 5
  return(result) # 計算結果を呼び出し元へ返す
}

add_five(72) # 72を引数xに渡して実行する


# ベクトルを引数に渡す
scores <- c(72, 85, 91, 68, 77)
adjusted_scores <- add_five(scores) # ベクトルの各要素にも同じ計算を行う
adjusted_scores
scores


# 2. 複数の引数と既定値
# quiz_weightを省略した場合は既定値0.40を使う
calculate_score <- function(quiz, exam, quiz_weight = 0.40) {
  result <- quiz * quiz_weight + exam * (1 - quiz_weight)
  return(result)
}

calculate_score(quiz = 78, exam = 92)
calculate_score(quiz = 78, exam = 92, quiz_weight = 0.50)

calculate_score(78, 92)                 # 引数名を省略すると定義順に渡される
calculate_score(exam = 92, quiz = 78)    # 名前を指定すれば順番を変えられる


# 3. 条件に応じて処理を分ける
judge_result <- function(score) {
  if (score >= 60) { # 条件がTRUEの場合の処理
    return("合格")
  } else {          # 条件がFALSEの場合の処理
    return("不合格")
  }
}

judge_result(82)
judge_result(48)

# ifelse(条件, TRUEのときの値, FALSEのときの値)で各要素を判定する
ifelse(scores >= 80, "80点以上", "80点未満")


# Chapter 2｜CSVを読み込み、データを確認する

# 1. データファイルを準備する

# 2. Projectを基準にパスを指定する
getwd()            # 現在の作業フォルダを確認する
list.files("data") # dataフォルダ内のファイル名を表示する


# 3. read.csv()で読み込む
# read.csv()でCSVを読み込み、データフレームとして保存する
students <- read.csv(
  "data/data_lesson02.csv",
  na.strings = c("", "NA") # 空欄と文字列NAを欠損値として読む
)
head(students)


# 4. 構造と欠損値を確認する
class(students)
dim(students)
names(students)
str(students)

sum(is.na(students$score)) # 欠損の位置をTRUEにし、1として合計する
colSums(is.na(students))   # 列ごとの欠損数を数える

mean(students$score, na.rm = TRUE)


# 5. 必要な行と列を取り出す
high_scores <- students[
  !is.na(students$score) & students$score >= 80,
  c("student_id", "score")
]
high_scores

# 表をCSVとして保存する（保存先はProjectからの相対パス）
write.csv(
  high_scores,
  "output/high-scores.csv",
  row.names = FALSE # 行番号を余分な列として書き出さない
)


# Chapter 3｜外部パッケージを利用する

# 1. 機能を追加する

# 2. インストールと読み込みを区別する
library(readr) # 今回のRセッションでパッケージを使えるようにする


# 3. readrで同じCSVを読む
# read_csv()はreadrの読込関数で、tibble形式の表を返す
students_readr <- read_csv(
  "data/data_lesson02.csv",
  na = c("", "NA"),       # readrではnaで欠損とみなす文字列を指定する
  show_col_types = FALSE   # 読込時の列の型の案内を非表示にする
)
class(students_readr)
head(students_readr)

dim(students_readr)
mean(students_readr$score, na.rm = TRUE)


# 4. パッケージ名を明示する
# パッケージ名::関数名で、所属を明示して呼び出す
readr::read_csv("data/data_lesson02.csv", show_col_types = FALSE)


# Chapter 4｜グラフを作成し、保存する

# 1. 確認したい内容とグラフの種類

# 2. 散布図を作成する
plot_data <- students[
  !is.na(students$study_hours) & !is.na(students$score),
]
nrow(plot_data)

# plot()で横軸xと縦軸yに対応する値を指定して散布図を描く
plot(
  x = plot_data$study_hours,
  y = plot_data$score,
  xlab = "Study hours per week", # 横軸の名前
  ylab = "Score",                # 縦軸の名前
  main = "Study hours and score", # 図のタイトル
  pch = 19,                      # 点の形（19は塗りつぶした丸）
  col = "steelblue"              # 点の色
)


# 3. ヒストグラムを作成する
score_values <- students$score[!is.na(students$score)]
length(score_values)

# hist()で値を区間に分け、区間ごとの度数を描く
hist(
  score_values,
  breaks = seq(40, 100, by = 10), # 区間の境界を40, 50, …, 100に指定する
  col = "skyblue3",              # 棒の内側の色
  border = "white",             # 棒の枠線の色
  xlab = "Score",
  main = "Distribution of scores"
)


# 4. 図を保存する
# png()からdev.off() # 描画先を閉じて画像ファイルへの保存を完了するまでに描く図を保存する（幅・高さはピクセル、解像度はdpi）
png("output/study-score.png", width = 1120, height = 720, res = 160)
plot(
  x = plot_data$study_hours,
  y = plot_data$score,
  xlab = "Study hours per week",
  ylab = "Score",
  main = "Study hours and score",
  pch = 19,
  col = "steelblue"
)
dev.off()


# 確認事項

# 実行結果の確認
print(dim(students))
print(colSums(is.na(students)))
print(high_scores)
