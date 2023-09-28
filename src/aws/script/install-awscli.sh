#!/bin/bash
set -euo pipefail

. ./config/params.config

echo "# install-awscli started on ${NOP_APP_ID}"

echo "## create aws config file on ${NOP_APP_ID}"
mkdir ~/.aws
cp config/aws.config ~/.aws/config
sed -i -e "s/params-aws-region-here/${AWS_REGION}/" ~/.aws/config

echo "## set aws sns topic to env on ${NOP_APP_ID}"

echo "export AWS_SNS_TOPIC=${AWS_SNS_TOPIC}" >> ~/.bash_profile

set +uo pipefail
source ~/.bash_profile
set -uo pipefail

echo "### aws version on ${NOP_APP_ID}"
aws --version

echo "# install-awscli completed on ${NOP_APP_ID}"