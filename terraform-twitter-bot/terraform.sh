#!/bin/bash

bash ./conf/install.sh
python ./conf/convert.py

terraform init
terraform apply -auto-approve