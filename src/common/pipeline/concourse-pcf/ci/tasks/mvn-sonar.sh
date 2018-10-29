#!/bin/bash

set -e
cd source
mvn -P gsp generate-resources -s ci/settings.xml -Dmaven.repo.local=../m2/rootfs/usr/share/maven/ref/repository
mvn clean verify sonar:sonar -s ci/settings.xml -Dmaven.repo.local=../m2/rootfs/usr/share/maven/ref/repository \
-Dsonar.host.url=${SONAR_URL} -Dsonar.branch=${SONAR_BRANCH} -Dmaven.test.failure.ignore=true \
-Dhttp.proxyHost=10.100.10.60 -Dhttp.proxyPort=80 -Dhttps.proxyHost=10.100.10.60 -Dhttps.proxyPort=80 \
-Dhttp.nonProxyHosts=repository.tools.dev.paycierge.com
