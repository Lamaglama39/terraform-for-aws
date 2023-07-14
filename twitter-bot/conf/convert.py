import csv
import json

# ファイルからソーステキストを読み込む
with open('./conf/source.csv', 'r') as file:
    csv_reader = csv.reader(file)
    lines = list(csv_reader)

# 各行を処理
data_dict = {}
for i, line in enumerate(lines, start=1):
    contents, description, weight = line

    # データのキーとなる連番を作成
    data_key = f"data{i}"

    # 各行からデータを作成
    data_dict[data_key] = {
        "hash": {"S": data_key},
        "contents": {"S": contents},
        "description": {"S": description},
        "weight": {"N": weight},
    }

# ディクショナリをJSON形式の文字列に変換
json_string = json.dumps(data_dict, indent=4)

with open('./conf/item.json', 'w') as file:
    file.write(json_string)