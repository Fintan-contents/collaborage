#!/bin/bash
set -euo pipefail

echo "# init-centos7 started on ${NOP_APP_ID}"

if [ "${http_proxy}" != "" ]; then
  echo "## set http proxy to yum on ${NOP_APP_ID}"
  sudo sh -c 'echo "proxy=http://${http_proxy}" >> /etc/yum.conf'
  echo "## set http proxy to curl"
  sudo sh -c 'echo "proxy = \"http://${http_proxy}\"" >> /etc/curlrc'
fi

echo "## update package on ${NOP_APP_ID}"
sudo yum -y update

echo "## set locale and timezone on ${NOP_APP_ID}"
sudo localectl set-locale LANG=ja_JP.utf8
sudo localectl set-keymap jp106
sudo timedatectl set-timezone Asia/Tokyo
sudo sh -c 'echo "CRON_TZ=Asia/Tokyo" >> /etc/crontab'
sudo systemctl restart crond

echo "## disable selinux on ${NOP_APP_ID}"
set +e
sudo setenforce 0
set -e
sudo sed -i.bak -e "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config

echo "## disable postfix on ${NOP_APP_ID}"
sudo systemctl stop postfix.service
sudo systemctl disable postfix.service

echo "# init-centos7 completed on ${NOP_APP_ID}"
