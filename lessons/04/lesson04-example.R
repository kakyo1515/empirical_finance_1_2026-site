# 第4回：Rの基本操作 IV ― 関数・CSV・パッケージ・作図
# empirical_finance.Rprojを開き、data/data_lesson02.csvとoutputフォルダを準備する。
# readrは事前にインストールする。作図にはRの標準機能を使う。
# Chapter 1〜4の主要なコード例。補足・練習の解答は含めない。
# output内の同名ファイルは上書きされるため、実行前に保存先を確認する。


# Chapter 1｜関数を作成する

# 1. 計算式を関数にまとめる
add_five <- function(x) {
  result <- x + 5
  return(result)
}

add_five(72)


# ベクトルを引数に渡す
scores <- c(72, 85, 91, 68, 77)
adjusted_scores <- add_five(scores)
adjusted_scores
scores


# 2. 複数の引数と既定値
calculate_score <- function(quiz, exam, quiz_weight = 0.40) {
  result <- quiz * quiz_weight + exam * (1 - quiz_weight)
  return(result)
}

calculate_score(quiz = 78, exam = 92)
calculate_score(quiz = 78, exam = 92, quiz_weight = 0.50)

calculate_score(78, 92)
calculate_score(exam = 92, quiz = 78)


# 3. 条件に応じて処理を分ける
judge_result <- function(score) {
  if (score >= 60) {
    return("合格")
  } else {
    return("不合格")
  }
}

judge_result(82)
judge_result(48)

ifelse(scores >= 80, "80点以上", "80点未満")


# Chapter 2｜CSVを読み込み、データを確認する

# 1. データファイルを準備する

# 2. Projectを基準にパスを指定する
getwd()
list.files("data")


# 3. read.csv()で読み込む
students <- read.csv(
  "data/data_lesson02.csv",
  na.strings = c("", "NA")
)
head(students)


# 4. 構造と欠損値を確認する
class(students)
dim(students)
names(students)
str(students)

sum(is.na(students$score))
colSums(is.na(students))

mean(students$score, na.rm = TRUE)


# 5. 必要な行と列を取り出す
high_scores <- students[
  !is.na(students$score) & students$score >= 80,
  c("student_id", "score")
]
high_scores

write.csv(
  high_scores,
  "output/high-scores.csv",
  row.names = FALSE
)


# Chapter 3｜外部パッケージを利用する

# 1. 機能を追加する

# 2. インストールと読み込みを区別する
library(readr)


# 3. readrで同じCSVを読む
students_readr <- read_csv(
  "data/data_lesson02.csv",
  na = c("", "NA"),
  show_col_types = FALSE
)
class(students_readr)
head(students_readr)

dim(students_readr)
mean(students_readr$score, na.rm = TRUE)


# 4. パッケージ名を明示する
readr::read_csv("data/data_lesson02.csv", show_col_types = FALSE)


# Chapter 4｜グラフを作成し、保存する

# 1. 確認したい内容とグラフの種類

# 2. 散布図を作成する
plot_data <- students[
  !is.na(students$study_hours) & !is.na(students$score),
]
nrow(plot_data)

plot(
  x = plot_data$study_hours,
  y = plot_data$score,
  xlab = "Study hours per week",
  ylab = "Score",
  main = "Study hours and score",
  pch = 19,
  col = "steelblue"
)


# 3. ヒストグラムを作成する
score_values <- students$score[!is.na(students$score)]
length(score_values)

hist(
  score_values,
  breaks = seq(40, 100, by = 10),
  col = "skyblue3",
  border = "white",
  xlab = "Score",
  main = "Distribution of scores"
)


# 4. 図を保存する
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
