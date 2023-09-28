#!/bin/bash
set -euo pipefail

set +uo pipefail
source ~/.bash_profile
set -uo pipefail

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c ssm:CloudWatchAgentNopParemeter -s
sudo systemctl restart amazon-cloudwatch-agent.service
sudo systemctl enable amazon-cloudwatch-agent.service