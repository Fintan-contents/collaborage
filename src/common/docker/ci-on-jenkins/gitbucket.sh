#!/bin/sh -xe

# Add support to install system utils that are required by some gitbucket plugins
if [ "$GITBUCKET_EXTRA_DEPS" ]; then
    apt-get update
    apt-get install -y $GITBUCKET_EXTRA_DEPS
    apt-get clean
fi

exec java $JAVA_OPTS -jar /opt/gitbucket.war $GITBUCKET_OPTS
