#!/bin/bash
set -euo pipefail

echo "# install-docker started on ${NOP_APP_ID}"

echo "## install docker on ${NOP_APP_ID}"
sudo dnf install -y docker
sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo usermod -a -G docker ec2-user
mkdir ~/.docker
touch ~/.docker/config.json

echo "## install docker compose on ${NOP_APP_ID}"

DOCKER_CONFIG=${DOCKER_CONFIG:-/usr/local/lib/docker}
sudo mkdir -p $DOCKER_CONFIG/cli-plugins
sudo curl -SL https://github.com/docker/compose/releases/download/v2.18.1/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

echo "### docker/docker compose version on ${NOP_APP_ID}"
docker --version
docker compose version

echo "# install-docker completed on ${NOP_APP_ID}"
