#!/bin/bash
set -euo pipefail

echo "# install-utility started on ${NOP_APP_ID}"

CURRENT_DIR=$(pwd)

echo "## install cloudwatch monitoring scripts on ${NOP_APP_ID}"

sudo dnf -y install wget

if [ "${http_proxy}" != "" ]; then
  echo "## set http proxy to wget on ${NOP_APP_ID}"
  sudo sh -c 'echo "http_proxy=http://${http_proxy}" >> /etc/wgetrc'
  sudo sh -c 'echo "https_proxy=http://${http_proxy}" >> /etc/wgetrc'
fi

cd ${CURRENT_DIR}

echo "## install jq on ${NOP_APP_ID}"

sudo wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
sudo chmod 755 jq-linux64
sudo mv jq-linux64 /usr/local/bin/jq

echo "# install-utility completed on ${NOP_APP_ID}"