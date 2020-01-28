#!/bin/bash
set -u

docker stop my-running-app
docker rmi my-java-app
docker build -t my-java-app .
docker run --rm -d --name my-running-app -p 80:3333 my-java-app