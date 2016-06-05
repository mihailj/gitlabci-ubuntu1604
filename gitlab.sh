#!/usr/bin/env bash

# create swap file

sudo sed -i 's/127.0.0.1 localhost/127.0.0.1 localhost ubuntu-xenial/' /etc/hosts
sudo fallocate -l 4G /swapfile
ls -lh /swapfile
sudo chmod 600 /swapfile
ls -lh /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo swapon --show
free -m -t
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# install GitLab

sudo debconf-set-selections <<< "postfix postfix/mailname string localhost"
sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y curl openssh-server ca-certificates postfix
curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
sudo apt-get install gitlab-ce -y
sudo gitlab-ctl reconfigure
sudo gitlab-rake gitlab:setup RAILS_ENV=production GITLAB_ROOT_PASSWORD=rootgitlab GITLAB_ROOT_EMAIL=test@email.com force=yes
sudo sh -c "sed -i 's|external_url '\''http://localhost'\''|external_url '\''http://ubuntu-xenial'\''|' /etc/gitlab/gitlab.rb"
sudo gitlab-ctl reconfigure

# install GitLab Runner

curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-ci-multi-runner/script.deb.sh | sudo bash
sudo apt-get install -y gitlab-ci-multi-runner
