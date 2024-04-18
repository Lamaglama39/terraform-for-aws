# terraform-for-aws
Terraformを用いたAWSアーキテクチャ集です。
<br>
内容は実践的なものから用途不明なものまで、玉石混交になる予定です。
<br>
ほぼそのまま使える設定なので、気軽に terraform apply してください！
<br>

## 動作環境

### ローカル端末で実行する場合
AWS CLIのインストールとクレデンシャル設定、およびTerraformのインストールして実行してください。

- AWS CLI (version:^1.2.0)
- Terraform (version:^1.3.0)

### Dockerを利用して実行する場合
AWS CLIのクレデンシャルを設定し、以下でDockerを立ち上げログインしてTerraformを実行してください。

* Docker Container Create
```
cd ./docker && \
docker-compose up -d && \
docker-compose exec terraform ash
```

* Docker Container Delete
```
docker-compose down
```

## 使い方

各ディレクトリごとにReadmeがあるのでそちらをご参照ください。
<br>
基本的にはいくつかの変数設定と、terraform init && terraform apply だけで実行できます。

## 免責事項 

可能な限りAWS無料枠に収まるようにしていますが、起動時間によっては料金が発生します。
<br>
くれぐれも terraform destroy 忘れにはご注意ください...。

## ライセンス
[Mozilla Public License v2.0](https://github.com/Lamaglama39/terraform-for-aws/blob/main/LICENSE)