# multi-region-efs
レプリケーションを有効化したEFSを作成し、それぞれのリージョンのEC2でマウントします。  
ユーザーデータで/efs/fstabの設定を行うため、構築が完了した段階でEFSが利用できます。  
またEC2へ`ssh`か`Session Manager`で接続可能です。

## 構成図
<p>
<img width="75%" src="./src/multi-region-efs.drawio.png">
</p>

## 使い方

(1) 以下の順でリソースを作成してください。
```
$ terraform init
$ terraform apply --target=module.vpc --target=module.vpc_replica
$ terraform apply
```

(2) Outputs:に出力されたコマンドでEC2へ接続します。
```
$ terraform output
```
```
CONNECT_EC2_SSH = [
  "ssh -i ./.key_pair/multi-region-efs ec2-user@XXX.XXX.XXX.XXX.ap-northeast-1.compute.amazonaws.com",
]
CONNECT_EC2_SSM = [
  "aws ssm start-session --target i-XXXXXXXXXXXXXXXXX --region ap-northeast-1",
]
```

(3) 以下コマンドでEFSがマウントされていることを確認できます。
```
$ df -h
```

(4) 以下コマンドで全リソースを削除できます。
```
$ terraform destroy
```

## ライセンス
[Mozilla Public License v2.0](https://github.com/Lamaglama39/terraform-for-aws/blob/main/LICENSE)
