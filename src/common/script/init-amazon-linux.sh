#!/bin/bash
set -euo pipefail

echo "# init-amazon-linux started on ${NOP_APP_ID}"

if [ "${http_proxy}" != "" ]; then
  echo "## set http proxy to dnf on ${NOP_APP_ID}"
  sudo sh -c 'echo "proxy=http://${http_proxy}" >> /etc/dnf/dnf.conf'
  echo "## set http proxy to curl"
  sudo sh -c 'echo "proxy = \"http://${http_proxy}\"" >> /etc/curlrc'
fi

echo "## update package on ${NOP_APP_ID}"
sudo dnf -y update

echo "## set locale and timezone on ${NOP_APP_ID}"
sudo localectl set-locale LANG=ja_JP.utf8
sudo localectl set-keymap jp-OADG109A
sudo timedatectl set-timezone Asia/Tokyo
sudo sh -c 'echo "CRON_TZ=Asia/Tokyo" >> /etc/crontab'
sudo dnf install cronie -y
sudo systemctl enable crond.service
sudo systemctl start crond.service

echo "## disable selinux on ${NOP_APP_ID}"
set +e
sudo setenforce 0
set -e
sudo sed -i.bak -e "s/SELINUX=permissive/SELINUX=disabled/" /etc/selinux/config

echo "# init-amazon-linux completed on ${NOP_APP_ID}"
