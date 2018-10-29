#!/bin/bash

set -e
cd source
mvn -P gsp generate-resources -s ci/settings.xml -Dmaven.repo.local=../m2/rootfs/usr/share/maven/ref/repository
mvn clean verify sonar:sonar -s ci/settings.xml -Dmaven.repo.local=../m2/rootfs/usr/share/maven/ref/repository \
-Dsonar.host.url=${SONAR_URL} -Dsonar.analysis.mode=preview \
-Dsonar.gitlab.url=${GITLAB_URL} -Dsonar.gitlab.user_token=${GITLAB_USER_TOKEN} \
-Dsonar.gitlab.project_id=${GITLAB_PROJECT_ID} -Dsonar.gitlab.commit_sha=$(git rev-parse HEAD) \
-Dsonar.gitlab.ref_name=$(git symbolic-ref --short HEAD) \
-Dmaven.test.failure.ignore=true
