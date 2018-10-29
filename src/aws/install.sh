#!/bin/bash
set -euo pipefail

echo "# install started"

echo "## check ssh.config"

ssh -F .ssh/ssh.config nop-bastion pwd
ssh -F .ssh/ssh.config nop-cq pwd
ssh -F .ssh/ssh.config nop-ci pwd
ssh -F .ssh/ssh.config nop-demo pwd

echo "## install ec2"
./install-ec2.sh cq
./install-ec2.sh ci
./install-ec2.sh demo

echo "## install app"
./install-app.sh cq
./install-app.sh ci

echo "## install after"
./install-after.sh cq
./install-after.sh ci
./install-after.sh demo

echo "# install completed"