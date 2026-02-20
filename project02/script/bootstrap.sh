#!/bin/bash
sudo yum update -y && sudo yum install -y docker git
sudo systemctl start docker
sudo usermod -aG docker ec2-user

cd /home/ec2-user
git clone https://github.com/yourname/yourrepo.git app

cd app
docker compose up -d
