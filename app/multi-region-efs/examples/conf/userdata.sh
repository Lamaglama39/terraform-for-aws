#!/bin/bash

sudo dnf -y update
sudo dnf -y upgrade

# ssm install
sudo dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

# mount efs
sudo mkdir /efs
echo "${file_system_id}:/ /efs efs _netdev,noresvport,tls,iam 0 0" | sudo tee -a /etc/fstab
sudo reboot
