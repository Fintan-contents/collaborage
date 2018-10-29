#!/bin/bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "usage: ./install-ec2.sh <app id on nop(cq|ci|demo)>"
  exit 1
fi

NOP_APP_ID="${1}"
HOST="nop-${1}"

echo "# install-ec2 started ${NOP_APP_ID}"

ssh -F .ssh/ssh.config ${HOST} mkdir -p nop/log
scp -F .ssh/ssh.config -r script/ ${HOST}:~/nop
ssh -F .ssh/ssh.config ${HOST} "cd nop/script; ./init-env.sh ${NOP_APP_ID}"
ssh -F .ssh/ssh.config ${HOST} "source ~/.bash_profile; cd nop/script; ./init.sh"

echo "# install-ec2 completed ${NOP_APP_ID}"