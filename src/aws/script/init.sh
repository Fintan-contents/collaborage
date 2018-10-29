#!/bin/bash
set -euo pipefail

if [ ${NOP_APP_ID-undefined} == "undefined" ]; then
  echo "Please set environment variable: NOP_APP_ID(cq|ci|demo) to execute"
  exit 1
fi

echo "# init started on ${NOP_APP_ID}"

if [ "${NOP_APP_ID}" != "demo" ]; then
  ./init-data-volume.sh
fi

./init-centos7.sh

./init-cloud-init.sh

./install-utility.sh

./install-awscli.sh

./install-docker.sh

./set-password-to-centos.sh

echo "# init completed on ${NOP_APP_ID}"