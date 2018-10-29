#!/bin/bash
set -euo pipefail

echo "# set-cron started on ${NOP_APP_ID}"

echo "## try the commands to run with cron on ${NOP_APP_ID}"

aws sns publish --topic-arn "${AWS_SNS_TOPIC}" \
  --subject "[NoP]メール送信のテスト(nop-${NOP_APP_ID})" \
  --message "set-cron-after-try-command.shから送信しました。"

/home/centos/nop/script/cron/send-ec2-data-to-cloudwatch.sh
/home/centos/nop/script/cron/create-snapshot-of-ebs-data-volume.sh

echo "## set cron on ${NOP_APP_ID}"

crontab config/cron.config

echo "### cron list on ${NOP_APP_ID}"

crontab -l

echo "# set-cron completed on ${NOP_APP_ID}"