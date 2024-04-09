#!/bin/bash

sudo dnf -y update
sudo dnf -y upgrade

# ssm install
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
