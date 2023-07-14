#!/bin/bash

# Install Python3.8
sudo yum -y remove python3
sudo amazon-linux-extras enable python3.8
sudo yum -y install python38
sudo ln -s /usr/bin/python3.8 /usr/bin/python3

# Install zlib
sudo -u ec2-user curl -o /home/ec2-user/download -L https://sourceforge.net/projects/libpng/files/zlib/1.2.9/zlib-1.2.9.tar.gz/download
sudo -u ec2-user bash -c "cd /home/ec2-user && tar zxf download"
sudo -u ec2-user bash -c "cd /home/ec2-user/zlib-1.2.9 && ./configure"
sudo -u ec2-user bash -c "cd /home/ec2-user/zlib-1.2.9 && make"
sudo mv /home/ec2-user/zlib-1.2.9/libz.so.1.2.9 /lib64/
sudo ln -s -f /lib64/libz.so.1.2.9 /lib64/libz.so.1

# Install stable-diffusion-webui
sudo -u ec2-user bash -c "export COMMANDLINE_ARGS='--listen' &&cd /home/ec2-user && wget -qO script.sh https://raw.githubusercontent.com/AUTOMATIC1111/stable-diffusion-webui/master/webui.sh && bash script.sh"