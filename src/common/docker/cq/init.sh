#!/bin/bash
set -euo pipefail

echo "# init docker started on ${NOP_APP_ID}"

echo "## set http proxy to common.env on ${NOP_APP_ID}"

sed -i -e "s|env-http-proxy-here|${HTTP_PROXY}|" ./common.env
sed -i -e "s|env-https-proxy-here|${HTTPS_PROXY}|" ./common.env

echo "## set http proxy to sonar.properties on ${NOP_APP_ID}"

sed -i -e "s/env-http-proxy-host-here/${HTTP_PROXY_HOST}/" ./sonar.properties
sed -i -e "s/env-http-proxy-port-here/${HTTP_PROXY_PORT}/" ./sonar.properties

echo "## docker-compose up on ${NOP_APP_ID}"

docker-compose up -d
sleep 30s

echo "## set sub-rui to redmine on ${NOP_APP_ID}"

./redmine-sub-uri.sh

echo "## install redmine plugins on ${NOP_APP_ID}"

./redmine-plugins.sh

echo "# init docker completed on ${NOP_APP_ID}"
