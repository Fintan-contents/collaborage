#!/bin/bash
set -euo pipefail

. ./config/params.config

echo "# set-password-to-ec2-user started on ${NOP_APP_ID}"

echo "## set password to ec2-user on ${NOP_APP_ID}"

if [ "${NOP_APP_ID}" == "cq" ]; then
  EC2_USER_PASS=${EC2_USER_CQ_PASS}
elif [ "${NOP_APP_ID}" == "ci" ]; then
  EC2_USER_PASS=${EC2_USER_CI_PASS}
elif [ "${NOP_APP_ID}" == "demo" ]; then
  EC2_USER_PASS=${EC2_USER_DEMO_PASS}
else
  echo "Unknown NOP_APP_ID[${NOP_APP_ID}]"
  exit 1
fi

sudo sh -c "echo $EC2_USER_PASS | passwd --stdin ec2-user"

echo "# set-password-to-ec2-user completed on ${NOP_APP_ID}"
