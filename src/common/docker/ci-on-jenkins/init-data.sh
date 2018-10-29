#!/bin/bash
set -euo pipefail

# for jenkins
sudo mkdir -p /data/jenkins
sudo chown -R 1000:1000 /data/jenkins

# for nexus
sudo mkdir -p /data/nexus
sudo chown -R 200 /data/nexus
