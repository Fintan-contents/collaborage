#!/bin/bash
set -euo pipefail

set +uo pipefail
source ~/.bash_profile
set -uo pipefail

export PATH="/usr/local/bin:$PATH"

# start docker compose
cd /home/ec2-user/nop/docker/${NOP_APP_ID}
docker compose start
