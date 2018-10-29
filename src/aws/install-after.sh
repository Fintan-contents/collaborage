#!/bin/bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "usage: ./install-after.sh <app id on nop(cq|ci|demo)>"
  exit 1
fi

NOP_APP_ID="${1}"
HOST="nop-${1}"

echo "# install-after started ${NOP_APP_ID}"

if [ "${NOP_APP_ID}" != "demo" ]; then
  ssh -F .ssh/ssh.config ${HOST} "source ~/.bash_profile; cd nop/script; ./set-cron-after-try-command.sh"
fi

echo "# install-after completed ${NOP_APP_ID}"
