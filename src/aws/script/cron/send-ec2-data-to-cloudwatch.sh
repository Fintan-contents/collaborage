#!/bin/bash
set -euo pipefail

set +u
source ~/.bash_profile
set -u

sudo -E /usr/local/cloudwatch/aws-scripts-mon/mon-put-instance-data.pl --disk-space-util --disk-path=/data/ --from-cron
