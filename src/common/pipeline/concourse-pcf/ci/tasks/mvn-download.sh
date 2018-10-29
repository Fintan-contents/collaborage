#!/bin/bash

set -e
cd source
mvn -P h2 -f ci/pom-get.xml -s ci/settings.xml validate -Dmaven.repo.local=../m2/rootfs/usr/share/maven/ref/repository
mv ci/app.war ../dest
ls ../dest
