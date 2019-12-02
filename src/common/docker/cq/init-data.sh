#!/bin/bash
set -euo pipefail

# for svn
sudo mkdir -p /data/svn/
sudo chmod 777 /data/svn

# for redmine
sudo mkdir -p /data/redmine-files
sudo chmod 777 /data/redmine-files
sudo mkdir -p /data/redmine-plugins
sudo chmod 777 /data/redmine-plugins
sudo mkdir -p /data/redmine-db
sudo chmod 777 /data/redmine-db

# for  rocketchat
sudo mkdir -p /data/rocketchat
sudo chmod 777 /data/rocketchat
sudo mkdir -p /data/rocketchat-db
sudo chmod 777 /data/rocketchat-db

# for sonarqube
sudo mkdir -p /data/sonarqube/data
sudo mkdir -p /data/sonarqube/extensions
sudo mkdir -p /data/sonarqube/bundled-plugins
sudo chmod -R 777 /data/sonarqube
sudo mkdir -p /data/sonarqube-db
sudo chmod 777 /data/sonarqube-db
