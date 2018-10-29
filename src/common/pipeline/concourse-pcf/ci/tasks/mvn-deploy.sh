#!/bin/bash

set -e
cd source
mvn -P gsp generate-resources -s ci/settings.xml -Dmaven.repo.local=../m2/rootfs/usr/share/maven/ref/repository
mvn deploy -P h2 -s ci/settings.xml -DskipTests=true -Dmaven.repo.local=../m2/rootfs/usr/share/maven/ref/repository
