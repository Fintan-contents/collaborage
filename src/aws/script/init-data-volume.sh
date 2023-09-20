#!/bin/bash
set -euo pipefail

echo "# mount-ebs-data-volume started on ${NOP_APP_ID}"

echo "## mount ebs data volume on ${NOP_APP_ID}"

sudo mkfs -t ext4 /dev/nvme1n1
sudo mkdir /data
sudo mount /dev/nvme1n1 /data/

echo "## set auto-mount on ${NOP_APP_ID}"

sudo sh -c "echo '/dev/nvme1n1 /data ext4 defaults 1 1' >> /etc/fstab"

echo "### disk free on ${NOP_APP_ID}"
df -h

echo "# mount-ebs-data-volume completed on ${NOP_APP_ID}"
