#!/bin/bash
set -euo pipefail

echo "# set-cron started on ${NOP_APP_ID}"

echo "## try the commands to run with cron on ${NOP_APP_ID}"

aws sns publish --topic-arn "${AWS_SNS_TOPIC}" \
  --subject "[NoP]メール送信のテスト(nop-${NOP_APP_ID})" \
  --message "set-cron-after-try-command.shから送信しました。"

sudo mkdir -p /media/install
sudo mkdir -p /usr/share/cloudwatchagent
sudo rm -rf /media/install/*
sudo rm -rf /usr/share/cloudwatchagent/*
cd /media/install
sudo wget https://s3.amazonaws.com/amazoncloudwatch-agent/linux/amd64/latest/AmazonCloudWatchAgent.zip
sudo unzip AmazonCloudWatchAgent.zip -d /usr/share/cloudwatchagent
cd /usr/share/cloudwatchagent
sudo ./install.sh
cd ~/nop/script/

/home/ec2-user/nop/script/cron/send-ec2-data-to-cloudwatch.sh

echo "## set cron on ${NOP_APP_ID}"

crontab config/cron.config

echo "### cron list on ${NOP_APP_ID}"

crontab -l

echo "# set-cron completed on ${NOP_APP_ID}"