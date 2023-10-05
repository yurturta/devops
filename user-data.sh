#!/usr/bin/env bash

  sudo yum update -y
  sudo yum install -y httpd git
#  git clone https://github.com/gabrielecirulli/2048.git
#  sudo cp -R 2048/* /var/www/html
  echo "Before"
  sudo echo "Hello from ${HOSTNAME}" > /var/www/html/index.html
  echo "After"
  sudo systemctl enable httpd && sudo systemctl start httpd
