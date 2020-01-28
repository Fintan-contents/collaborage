#!/bin/bash
set -euo pipefail

echo "# install-docker started on ${NOP_APP_ID}"

echo "## install docker on ${NOP_APP_ID}"
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum -y install docker-ce
sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo usermod -a -G docker centos
mkdir ~/.docker
touch ~/.docker/config.json

echo "## install docker-compose on ${NOP_APP_ID}"
sudo sh -c "curl -L https://github.com/docker/compose/releases/download/1.14.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose"
sudo chmod 755 /usr/local/bin/docker-compose

echo "### docker/docker-compose version on ${NOP_APP_ID}"
docker --version
docker-compose --version

echo "# install-docker completed on ${NOP_APP_ID}"
