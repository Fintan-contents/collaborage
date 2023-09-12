#!/bin/bash
set -euo pipefail

echo "# init docker started on ${NOP_APP_ID}"

echo "## set http proxy to common.env on ${NOP_APP_ID}"

sed -i -e "s|env-http-proxy-here|${HTTP_PROXY}|" ./common.env
sed -i -e "s|env-https-proxy-here|${HTTPS_PROXY}|" ./common.env

echo "## set http proxy to sonar.properties on ${NOP_APP_ID}"

sed -i -e "s/env-http-proxy-host-here/${HTTP_PROXY_HOST}/" ./sonar.properties
sed -i -e "s/env-http-proxy-port-here/${HTTP_PROXY_PORT}/" ./sonar.properties

echo "## docker compose up on ${NOP_APP_ID}"

sudo sh -c "echo 'vm.max_map_count = 262144' >> /etc/sysctl.conf"
sudo sysctl -w vm.max_map_count=262144
./init-data.sh


docker compose up -d
sleep 30s

echo "## install redmine plugins on ${NOP_APP_ID}"

./redmine-plugins.sh

echo "## set sub-rui to redmine on ${NOP_APP_ID}"

./redmine-sub-uri.sh

echo "# init docker completed on ${NOP_APP_ID}"
