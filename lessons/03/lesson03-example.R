# 第3回：Rの基本操作 III ― Rのデータ構造
# Chapter 1〜5の主要なコード例。
# SourceペインのSourceボタンで、先頭から実行できる。
# 折りたたみの補足と個別練習の解答も含めない。


# Chapter 1｜ベクトル

# 1. 複数の値をまとめる
# c()で複数の値を一つのベクトルにまとめる
scores <- c(72, 85, 91, 68, 77)
student_names <- c("Aiko", "Ken", "Mei", "Sora", "Yuki")

scores
student_names

length(scores) # ベクトルの要素数を数える
class(scores)
class(student_names)

1:5                           # :で1刻みの数列を作る
seq(from = 0, to = 10, by = 2)  # 開始値・終了値・間隔を指定する
rep("A", times = 4)            # 同じ値を4回繰り返す


# 2. ベクトルを使って計算する
# ベクトルと数値の計算は、各要素に同じ処理を行う
scores + 5
scores / 100

sum(scores)  # 合計
mean(scores) # 平均値
min(scores)  # 最小値
max(scores)  # 最大値

quiz_1 <- c(8, 7, 9, 6)
quiz_2 <- c(7, 9, 8, 8)

# 同じ長さのベクトルどうしは、同じ位置の要素を計算する
quiz_1 + quiz_2
(quiz_1 + quiz_2) / 2


# 3. 必要な要素を取り出す
scores[1]           # []に位置を指定する（先頭は1）
scores[c(1, 3, 5)]   # 複数の位置を指定する
scores[2:4]         # 2番目から4番目まで取り出す

scores >= 80

scores[scores >= 80] # 条件がTRUEの位置の要素だけを取り出す

names(scores) <- student_names # 各要素に名前を付ける

scores
scores["Mei"] # 位置の代わりに名前を指定して取り出す

revised_scores <- scores
revised_scores["Ken"] <- 88 # 指定した要素だけを更新する
revised_scores


# 4. 欠損値を扱う
scores_missing <- c(70, 85, NA, 90) # NAは欠損値を表す

mean(scores_missing)

mean(scores_missing, na.rm = TRUE) # na.rm = TRUEで欠損値を除いて計算する

is.na(scores_missing)                # 欠損値の位置をTRUEで示す
scores_missing[!is.na(scores_missing)] # 欠損でない要素だけを残す


# Chapter 2｜行列（matrix）

# 1. 行と列を持つデータを作成する
# matrix()で値を行と列に並べる
score_matrix <- matrix(
  c(80, 75,
    68, 72,
    91, 88),
  nrow = 3,     # 行数を指定する
  byrow = TRUE  # 行方向に値を並べる（既定は列方向）
)

score_matrix

matrix(1:6, nrow = 3)
matrix(1:6, nrow = 3, byrow = TRUE)

dim(score_matrix)  # 行数と列数をまとめて確認する
nrow(score_matrix) # 行数
ncol(score_matrix) # 列数


# 2. 行名・列名を付け、要素を取り出す
rownames(score_matrix) <- c("Aiko", "Ken", "Mei") # 行名を付ける
colnames(score_matrix) <- c("Test1", "Test2")      # 列名を付ける
score_matrix

score_matrix[2, 1]           # [行, 列]の順に位置を指定する
score_matrix["Ken", "Test1"] # 行名と列名でも指定できる
score_matrix[, "Test2"]     # 行を省略すると全行を取り出す
score_matrix[1:2, ]         # 列を省略すると全列を取り出す


# 3. 行・列ごとに計算する
rowMeans(score_matrix) # 行ごとの平均値
colMeans(score_matrix) # 列ごとの平均値

rbind(score_matrix, Yuki = c(76, 81))                  # 行を追加する
cbind(score_matrix, Average = rowMeans(score_matrix)) # 列を追加する


# Chapter 3｜配列（array）

# 1. 三つ以上の次元を持つデータ
# array()で行・列・週の3次元に値を並べる
score_array <- array(
  c(80, 68, 91, 75, 72, 88,
    84, 70, 93, 78, 76, 90),
  dim = c(3, 2, 2) # 各次元の大きさ：3人・2科目・2週
)

score_array

dim(score_array)
length(score_array)


# 2. 次元ごとに位置を指定する
score_array[2, 1, 2] # [人, 科目, 週]の順に指定する
score_array[, , 1]  # 第1週の全員・全科目を取り出す
score_array[1, , ]  # 1人目の全科目・全週を取り出す


# 3. 一部を取り出して集計する
week2_scores <- score_array[, , 2]
rowMeans(week2_scores)
mean(week2_scores)


# Chapter 4｜データフレーム

# 1. 表形式のデータを作成する
# data.frame()で、列ごとに異なる型を持てる表を作る
student_data <- data.frame(
  name = student_names,
  class = c("A", "A", "B", "B", "A"),
  score = c(72, 85, 91, 68, 77),
  attendance = c(0.90, 0.95, 1.00, 0.75, 0.88)
)

student_data

dim(student_data)
names(student_data) # 表の列名を確認する
str(student_data)   # 各列の型と値の一部を確認する

nrow(student_data)
ncol(student_data)
head(student_data, n = 3) # 先頭3行を表示する


# 2. 列・行・条件による抽出
student_data$score # $で列をベクトルとして取り出す
mean(student_data$score)

student_data[2, 3]
student_data[2, ]
student_data[, c("name", "score")]

# 行の条件と、残したい列名を[行, 列]で指定する
student_data[
  student_data$score >= 80,
  c("name", "score")
]


# 3. 列を追加する
student_data$passed <- student_data$score >= 60 # 新しい列名への代入で列を追加する
student_data


# Chapter 5｜リスト（list）

# 1. 異なる構造のデータをまとめる
# list()で文字列・表・行列などを一つにまとめる
course_result <- list(
  course = "R入門",
  students = student_data,
  test_scores = score_matrix,
  weekly_scores = score_array
)

names(course_result)
str(course_result)


# 2. リストから取り出す
course_result$course           # $と要素名で中身を取り出す
course_result[["test_scores"]] # [[]]も要素の中身を取り出す
course_result[[1]]             # 要素の位置でも指定できる

course_result[c("course", "students")] # []は選んだ要素をリストとして返す

class(course_result["students"])   # []ではリストのまま
class(course_result[["students"]]) # [[]]では中身のデータフレームになる

result_students <- course_result[["students"]]
mean(result_students$score)


# 3. 要素を追加する
# 新しい要素名への代入でリストに要素を追加する
course_result$average_score <- mean(student_data$score)
course_result$average_score
names(course_result)
