#!/bin/bash

set -e
cd source
mvn -P gsp generate-resources -s ci/settings.xml -Dmaven.repo.local=../m2/rootfs/usr/share/maven/ref/repository
mvn clean verify sonar:sonar -s ci/settings.xml -Dmaven.repo.local=../m2/rootfs/usr/share/maven/ref/repository \
-Dsonar.host.url=${SONAR_URL} -Dsonar.branch=$(git branch | grep -v HEAD | awk '{print $1}') -Dmaven.test.failure.ignore=true
