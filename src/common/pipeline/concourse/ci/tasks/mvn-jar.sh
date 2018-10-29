#!/bin/bash

set -e
cd source
mvn -P gsp generate-resources -s ci/settings.xml -Dmaven.repo.local=../m2/rootfs/usr/share/maven/ref/repository
mvn clean compile -s ci/settings.xml -Dmaven.repo.local=../m2/rootfs/usr/share/maven/ref/repository
mvn waitt:jar -s ci/settings.xml -Dmaven.repo.local=../m2/rootfs/usr/share/maven/ref/repository
mkdir ../output/app/
cp $(find target/ -name *standalone.jar) ../output/app/
cp -r src/main/webapp/ ../output/app/
cp -r h2/ ../output/app/
ls ../output/app/
