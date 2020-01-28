#!/bin/bash
set -euo pipefail

if [ $# -ne 3 ]; then
  echo "usage: ./init-workplace.sh <path to workplace> <target cloud(aws)> <target ci(jenkins|gitlab)>"
  exit 1
fi

WORKSPACE=$1
TARGET_CLOUD=$2
TARGET_CI=$3

if [ ! -e $WORKSPACE ]; then
  mkdir -p $WORKSPACE
fi

cp -r src/$TARGET_CLOUD/* $WORKSPACE
cp -r src/common/* $WORKSPACE

mv $WORKSPACE/ssh $WORKSPACE/.ssh
mkdir $WORKSPACE/script/log
mv $WORKSPACE/docker/ci-on-$TARGET_CI $WORKSPACE/docker/ci
rm -rf $WORKSPACE/docker/ci-*

echo "init-workplace completed"