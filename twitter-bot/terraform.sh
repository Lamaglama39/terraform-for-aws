#!/bin/bash

## Lambda用 パッケージインストール
bash ./conf/install.sh
## source.csvをjsonに変換
python ./conf/convert.py

## Terrafform実行
terraform init
terraform apply -auto-approve