#!/bin/bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "usage: ./init-env.sh <app id on nop(cq|ci|demo)>"
  exit 1
fi

. ./config/params.config

echo "# init-env started on ${1}"

echo "## set app id on nop on ${1}"

echo "export NOP_APP_ID=${1}" >> ~/.bash_profile

echo "## set http proxy on ${1}"

if [ "${HTTP_PROXY_HOST}" != "" ]; then
  PROXY="http://${HTTP_PROXY_HOST}:${HTTP_PROXY_PORT}/"
else
  HTTP_PROXY_HOST=""
  HTTP_PROXY_PORT=""
  PROXY=""
fi

echo "export HTTP_PROXY_HOST=${HTTP_PROXY_HOST}" >> ~/.bash_profile
echo "export HTTP_PROXY_PORT=${HTTP_PROXY_PORT}" >> ~/.bash_profile
echo "export HTTP_PROXY=${PROXY}" >> ~/.bash_profile
echo "export HTTPS_PROXY=${PROXY}" >> ~/.bash_profile
echo "export http_proxy=${PROXY}" >> ~/.bash_profile
echo "export https_proxy=${PROXY}" >> ~/.bash_profile

set +uo pipefail
source ~/.bash_profile
set -uo pipefail

echo "### printenv on ${1}"
printenv

echo "# init-env completed on ${1}"
