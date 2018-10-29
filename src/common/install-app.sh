#!/bin/bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "usage: ./install-app.sh <app id on nop(cq|ci)>"
  exit 1
fi

NOP_APP_ID="${1}"
HOST="nop-${1}"

echo "# install-app started ${NOP_APP_ID}"

scp -F .ssh/ssh.config -r docker/ ${HOST}:~/nop
ssh -F .ssh/ssh.config ${HOST} "source ~/.bash_profile; cd nop/docker/${NOP_APP_ID}; ./init.sh"

echo "# install-app completed ${NOP_APP_ID}"
