# 第2回：Rの基本操作 II ― RStudioとRの基本操作
# Rスクリプトに記録した主要なコード例と総合演習の解答例。
# SourceペインのSourceボタンで、先頭から実行できる。
# 折りたたみの補足と個別練習の解答は含めない。


# Chapter 1｜RStudioでコードを実行する

# 1. 画面と各ペインの役割

# 2. Projectを作成する

# 3. スクリプトを作成し、最初の式を実行する
# 基本的な計算
1 + 2


# 4. Consoleへの直接入力

# Chapter 2｜計算・代入・関数

# 1. 計算式を記述する
10 - 4
3 * 5
2^3
(2 + 3) * 4


# 2. 値に名前を付ける
score <- 82
score

score + 5
score

score <- score + 5
print(score)


# 3. 関数と引数
sqrt(16)
abs(-8)
round(3.1415926, digits = 3)


# 4. データ型を確認する
82 + 5

student_name <- "Aiko"
score <- 82
attendance <- 0.94
passed <- TRUE

class(student_name)
class(score)
class(passed)


# 5. 条件を判定する
score >= 80
score == 82
score != 70

score >= 60 & attendance >= 0.80
score >= 90 | attendance == 1
!(score < 60)


# Chapter 3｜基本操作の演習と作業の保存

# 1. 演習：計算・代入・条件判断

# 2. Projectの作業領域を自動保存・復元する

# 3. Projectを開き直し、復元を確認する

# 確認事項

# 総合演習の解答例
quiz_score <- 78
exam_score <- 92
attendance_rate <- 0.85

final_score <- quiz_score * 0.40 + exam_score * 0.60
round(final_score, digits = 1)

is_passed <- final_score >= 80 & attendance_rate >= 0.80
is_passed

class(final_score)
class(is_passed)

print(final_score)
print(is_passed)
