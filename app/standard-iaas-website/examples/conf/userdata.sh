#!/bin/bash

sudo dnf -y update
sudo dnf -y upgrade

# ssm install
sudo dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

# install mysql client
sudo dnf install -y mariadb105
