#!/bin/bash
set -euo pipefail

. ./config/params.config

echo "# set-password-to-centos started on ${NOP_APP_ID}"

echo "## set password to centos on ${NOP_APP_ID}"

if [ "${NOP_APP_ID}" == "cq" ]; then
  CENTOS_PASS=${CENTOS_CQ_PASS}
elif [ "${NOP_APP_ID}" == "ci" ]; then
  CENTOS_PASS=${CENTOS_CI_PASS}
elif [ "${NOP_APP_ID}" == "demo" ]; then
  CENTOS_PASS=${CENTOS_DEMO_PASS}
else
  echo "Unknown NOP_APP_ID[${NOP_APP_ID}]"
  exit 1
fi

sudo sh -c "echo $CENTOS_PASS | passwd --stdin centos"

echo "# set-password-to-centos completed on ${NOP_APP_ID}"
