# code-series-cicd/examples

# 使い方

(1) apply
```
terraform init && \
terraform apply
```

(2) code commit git clone
```
git clone codecommit::ap-northeast-1://${codecommit-repository-name}
```

(3) cp template
```
cd ${codecommit-repository-name} && \
cp ../../templates/buildspec.yml && \
cp -r ../../templates/src
```

(4) edit buildspec.yml
```
version: 0.2

phases:
  build:
    commands:
      - aws deploy push --application-name ${code-deploy-app-name} --s3-location s3://${s3-bucket-name}/artifact.zip --source ${src}
artifacts:
  files:
    - "**/*"
  base-directory: ${src}
```

(5) git commit & push
```
git add . && \
git commit -m "first commit" && \
git push
```

(6) check deploy status, Web Site URL
```
curl http://${ec2_public_ip}
```

# ライセンス
[Mozilla Public License v2.0](https://github.com/Lamaglama39/terraform-for-aws/blob/main/LICENSE)
