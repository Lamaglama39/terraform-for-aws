#!/bin/bash

sudo dnf -y update
sudo dnf -y upgrade

# ssm install
sudo dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

# install mysql client
sudo dnf install -y mariadb105

# setup wordpress
sudo dnf install -y httpd php php-mysqlnd
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
php wp-cli.phar --info
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
cd /var/www/html

sudo wp core download --allow-root
sudo wp config create --dbname=${db_name} --dbuser=${db_user} --dbpass=${db_pass} --dbhost=${db_host} --allow-root

LOCAL_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
sudo wp core install --url=http://"$LOCAL_IP" --title=${site_title} --admin_user=${admin_user} --admin_password=${admin_pass} --admin_email=${email} --allow-root

sudo systemctl start httpd
sudo systemctl enable httpd
