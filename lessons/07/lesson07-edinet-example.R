library(httr2)  # 初回のみ install.packages("httr2")
library(readr)
library(dplyr)

# 各自のAPIキーを環境変数から読み込む
key <- Sys.getenv("EDINET_API_KEY")

# 提出日ごとの書類一覧を取得する（dateは報告書の提出日）
docs <- request("https://api.edinet-fsa.go.jp/api/v2/documents.json") |> # 通信先を指定する
  req_url_query(date = "2025-06-26", type = 2, `Subscription-Key` = key) |> # URLに検索条件とキーを追加
  req_perform() |> # リクエストを送信し、応答を受け取る
  resp_body_json(simplifyVector = TRUE) # JSONをRのリストや表に変換する

# 企業名と書類の種類で探す（120 = 有価証券報告書）
report <- docs$results |>
  filter(filerName == "任天堂株式会社", docTypeCode == "120")
stopifnot(nrow(report) == 1) # 対象が1件でなければ処理を止める
print(report |> select(docID, filerName, docDescription))
doc_id <- report$docID[[1]]  # この例では S100W73A

# 調べた書類IDを使い、CSV入りZIPを取得する
# paste0()でAPIのURLと書類IDをつなぐ
res <- request(paste0("https://api.edinet-fsa.go.jp/api/v2/documents/", doc_id)) |>
  req_url_query(type = 5, `Subscription-Key` = key) |>
  req_perform()
stopifnot(resp_content_type(res) == "application/octet-stream") # 応答がバイナリ形式か確認

# ZIPを保存し、展開する
dir.create("output", showWarnings = FALSE) # 保存先を作る（存在する場合の警告は非表示）
writeBin(resp_body_raw(res), "output/edinet.zip") # 応答の生データをバイナリで保存する
files <- unzip("output/edinet.zip", exdir = "output/edinet") # ZIPを展開し、ファイルのパスを得る

# jpcrpで始まる提出本文CSVを読む（タブ区切り・UTF-16LE）
edinet_raw <- read_tsv(
  files[grepl("^jpcrp", basename(files))], # basename()でファイル名を得て、grepl()で先頭を照合する
  locale = locale(encoding = "UTF-16LE"), # 読み込む文字コードを指定する
  col_types = cols(.default = col_character()) # 元の表記を保つため全列を文字列として読む
)

# 先頭3行を、9列すべて表示する
print(head(edinet_raw, 3), width = Inf) # Infを指定して列の表示幅を制限しない
