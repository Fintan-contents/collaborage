#!/bin/bash
set -euo pipefail

set +u
source ~/.bash_profile
set -u

export PATH="/usr/local/bin:$PATH"

DATA_VOLUME_NAME="nop-ebs-data-${NOP_APP_ID}"
SNAPSHOT_NAME="${DATA_VOLUME_NAME}-snapshot"

DATE_CURRENT=`date +%Y-%m-%d`
TIME_CURRENT=`date +%Y%m%d%H%M%S`
PURGE_AFTER_DAYS=7
PURGE_AFTER=`date -d +${PURGE_AFTER_DAYS}days -u +%Y-%m-%d`

# start docker-compose
function start_app() {
  docker-compose start
}
trap start_app EXIT

# stop docker-compose
cd /home/centos/nop/docker/${NOP_APP_ID}
docker-compose stop

# create snapshot

VOLUME_ID=`aws ec2 describe-volumes --filters Name=tag-key,Values=Name Name=tag-value,Values=${DATA_VOLUME_NAME} | jq .Volumes[].Attachments[].VolumeId | sed -e 's/"//g'`
if [ $(echo "${VOLUME_ID}" | wc -l) != 1 ]; then
  echo "Multiple data volumes were found. There are multiple volumes named '${DATA_VOLUME_NAME}'. Please review the volume setting." >&2
fi
if [ "${VOLUME_ID}" == "" ]; then
  echo "Data volume was not found. Please make sure that the volume named '${DATA_VOLUME_NAME}' is assigned to the EC 2 instance." >&2
fi
SNAPSHOT_ID=`aws ec2 create-snapshot --volume-id ${VOLUME_ID} --description "${DATA_VOLUME_NAME}_${VOLUME_ID}_${TIME_CURRENT}" | jq .SnapshotId | sed -e 's/"//g'`
aws ec2 create-tags --resources ${SNAPSHOT_ID} --tags Key=Name,Value=${SNAPSHOT_NAME} Key=NopPurgeAfter,Value=$PURGE_AFTER
echo "create-snapshot --volume-id ${VOLUME_ID}"

# delete snapshot

SNAPSHOT_IDS_PURGE_ALLOWED=`aws ec2 describe-tags --filters Name=tag-key,Values=Name Name=tag-value,Values=${SNAPSHOT_NAME} | jq .Tags[].ResourceId | sed -e 's/"//g'`
for SNAPSHOT_ID in ${SNAPSHOT_IDS_PURGE_ALLOWED}; do

  PURGE_AFTER_DATE=`aws ec2 describe-tags --filters Name=resource-type,Values=snapshot Name=resource-id,Values=${SNAPSHOT_ID} Name=key,Values=NopPurgeAfter | jq .Tags[].Value | sed -e 's/"//g'`

  if [ -n ${PURGE_AFTER_DATE} ]; then
    DATE_CURRENT_EPOCH=`date -d ${DATE_CURRENT} +%s`
    PURGE_AFTER_DATE_EPOCH=`date -d ${PURGE_AFTER_DATE} +%s`
    echo "snapshot:${PURGE_AFTER_DATE} < current:${DATE_CURRENT}"
    echo "snapshot:${PURGE_AFTER_DATE_EPOCH} < current:${DATE_CURRENT_EPOCH}"
    if [[ ${PURGE_AFTER_DATE_EPOCH} < ${DATE_CURRENT_EPOCH} ]]; then
      aws ec2 delete-snapshot --snapshot-id ${SNAPSHOT_ID}
      echo "delete-snapshot --snapshot-id ${SNAPSHOT_ID}"
    fi
  fi

done
