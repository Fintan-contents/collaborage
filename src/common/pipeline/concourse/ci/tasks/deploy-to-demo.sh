#!/bin/bash

set -e
cp source/ci/tasks/deploy-to-demo/* output/app/
cd output
sshpass -p ${DEMO_PASSWORD} scp -P ${DEMO_PORT} -oStrictHostKeyChecking=no -r app/ ${DEMO_USERNAME}@${DEMO_HOST}:~/
sshpass -p ${DEMO_PASSWORD} ssh -p ${DEMO_PORT} -oStrictHostKeyChecking=no ${DEMO_USERNAME}@${DEMO_HOST} "cd app && sh up.sh"
