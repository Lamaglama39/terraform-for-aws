#!/bin/bash

Tpot_user="Tpot_user"
Tpot_password="Tpot_password"

# # OS update
sudo apt -y update
sudo apt -y upgrade

# # ssm install
sudo apt install -y git wget
wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
sudo dpkg -i amazon-ssm-agent.deb

## install Tpot
git clone https://github.com/dtag-dev-sec/tpotce
cd tpotce/iso/installer/
cp tpot.conf.dist tpot.conf

# Tpot config
sed -i s/webuser/$Tpot_user/g tpot.conf
sed -i s/w3b\$ecret/$Tpot_password/g tpot.conf

sudo ./install.sh --type=auto --conf=tpot.conf
sudo reboot