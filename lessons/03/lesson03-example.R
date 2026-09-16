# 第3回：Rの基本操作 III ― Rのデータ構造
# Chapter 1〜5の主要なコード例。
# SourceペインのSourceボタンで、先頭から実行できる。
# 折りたたみの補足と個別練習の解答も含めない。


# Chapter 1｜ベクトル

# 1. 複数の値をまとめる
scores <- c(72, 85, 91, 68, 77)
student_names <- c("Aiko", "Ken", "Mei", "Sora", "Yuki")

scores
student_names

length(scores)
class(scores)
class(student_names)

1:5
seq(from = 0, to = 10, by = 2)
rep("A", times = 4)


# 2. ベクトルを使って計算する
scores + 5
scores / 100

sum(scores)
mean(scores)
min(scores)
max(scores)

quiz_1 <- c(8, 7, 9, 6)
quiz_2 <- c(7, 9, 8, 8)

quiz_1 + quiz_2
(quiz_1 + quiz_2) / 2


# 3. 必要な要素を取り出す
scores[1]
scores[c(1, 3, 5)]
scores[2:4]

scores >= 80

scores[scores >= 80]

names(scores) <- student_names

scores
scores["Mei"]

revised_scores <- scores
revised_scores["Ken"] <- 88
revised_scores


# 4. 欠損値を扱う
scores_missing <- c(70, 85, NA, 90)

mean(scores_missing)

mean(scores_missing, na.rm = TRUE)

is.na(scores_missing)
scores_missing[!is.na(scores_missing)]


# Chapter 2｜行列（matrix）

# 1. 行と列を持つデータを作成する
score_matrix <- matrix(
  c(80, 75,
    68, 72,
    91, 88),
  nrow = 3,
  byrow = TRUE
)

score_matrix

matrix(1:6, nrow = 3)
matrix(1:6, nrow = 3, byrow = TRUE)

dim(score_matrix)
nrow(score_matrix)
ncol(score_matrix)


# 2. 行名・列名を付け、要素を取り出す
rownames(score_matrix) <- c("Aiko", "Ken", "Mei")
colnames(score_matrix) <- c("Test1", "Test2")
score_matrix

score_matrix[2, 1]
score_matrix["Ken", "Test1"]
score_matrix[, "Test2"]
score_matrix[1:2, ]


# 3. 行・列ごとに計算する
rowMeans(score_matrix)
colMeans(score_matrix)

rbind(score_matrix, Yuki = c(76, 81))
cbind(score_matrix, Average = rowMeans(score_matrix))


# Chapter 3｜配列（array）

# 1. 三つ以上の次元を持つデータ
score_array <- array(
  c(80, 68, 91, 75, 72, 88,
    84, 70, 93, 78, 76, 90),
  dim = c(3, 2, 2)
)

score_array

dim(score_array)
length(score_array)


# 2. 次元ごとに位置を指定する
score_array[2, 1, 2]
score_array[, , 1]
score_array[1, , ]


# 3. 一部を取り出して集計する
week2_scores <- score_array[, , 2]
rowMeans(week2_scores)
mean(week2_scores)


# Chapter 4｜データフレーム

# 1. 表形式のデータを作成する
student_data <- data.frame(
  name = student_names,
  class = c("A", "A", "B", "B", "A"),
  score = c(72, 85, 91, 68, 77),
  attendance = c(0.90, 0.95, 1.00, 0.75, 0.88)
)

student_data

dim(student_data)
names(student_data)
str(student_data)

nrow(student_data)
ncol(student_data)
head(student_data, n = 3)


# 2. 列・行・条件による抽出
student_data$score
mean(student_data$score)

student_data[2, 3]
student_data[2, ]
student_data[, c("name", "score")]

student_data[
  student_data$score >= 80,
  c("name", "score")
]


# 3. 列を追加する
student_data$passed <- student_data$score >= 60
student_data


# Chapter 5｜リスト（list）

# 1. 異なる構造のデータをまとめる
course_result <- list(
  course = "R入門",
  students = student_data,
  test_scores = score_matrix,
  weekly_scores = score_array
)

names(course_result)
str(course_result)


# 2. リストから取り出す
course_result$course
course_result[["test_scores"]]
course_result[[1]]

class(course_result["students"])
class(course_result[["students"]])

result_students <- course_result[["students"]]
mean(result_students$score)


# 3. 要素を追加する
course_result$average_score <- mean(student_data$score)
course_result$average_score
names(course_result)
