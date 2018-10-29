#!/bin/bash
set -euo pipefail

echo "# mount-ebs-data-volume started on ${NOP_APP_ID}"

echo "## mount ebs data volume on ${NOP_APP_ID}"

sudo mkfs -t ext4 /dev/xvdb
sudo mkdir /data
sudo mount /dev/xvdb /data/

echo "## set auto-mount on ${NOP_APP_ID}"

sudo sh -c "echo '/dev/xvdb /data ext4 defaults 1 1' >> /etc/fstab"

echo "### disk free on ${NOP_APP_ID}"
df -h

echo "# mount-ebs-data-volume completed on ${NOP_APP_ID}"
