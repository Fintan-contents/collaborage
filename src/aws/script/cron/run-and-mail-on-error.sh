#!/bin/bash
set -euo pipefail

if [ $# -ne 3 ]; then
  echo 'usage: ./run-and-mail-on-error.sh <shell name> <path of shell file to run> <path of error log file to check>'
  exit 1
fi

set +uo pipefail
source ~/.bash_profile
set -uo pipefail

SHELL_NAME=$1
SHELL_FILE_PATH=$2
ERROR_LOG_PATH=$3

TARGET_HOST="nop-${NOP_APP_ID}"

SNS_SUBJECT="[NoP]${SHELL_NAME}失敗(${TARGET_HOST})"
SNS_MESSAGE="${SHELL_NAME}に失敗しました。
ログを確認し対応してください。

対象ホスト:
${TARGET_HOST}

ログの場所:
${ERROR_LOG_PATH}"

set +uo pipefail
sh "${SHELL_FILE_PATH}" 2>>"${ERROR_LOG_PATH}"
set -uo pipefail

if [ "$?" != "0" ]; then
  aws sns publish \
    --topic-arn "${AWS_SNS_TOPIC}" \
    --subject "${SNS_SUBJECT}" \
    --message "${SNS_MESSAGE}"
fi
