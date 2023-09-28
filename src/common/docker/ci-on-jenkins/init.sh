#!/bin/bash
set -euo pipefail

echo "# init docker started on ${NOP_APP_ID}"

echo "## set http proxy to common.env on ${NOP_APP_ID}"

sed -i -e "s|env-http-proxy-here|${HTTP_PROXY}|" ./common.env
sed -i -e "s|env-https-proxy-here|${HTTPS_PROXY}|" ./common.env

echo "## init data directory on ${NOP_APP_ID}"

./init-data.sh

echo "## docker compose up on ${NOP_APP_ID}"

docker compose up -d

echo "# init docker completed on ${NOP_APP_ID}"
