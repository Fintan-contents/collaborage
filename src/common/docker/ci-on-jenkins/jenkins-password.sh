#!/bin/bash
set -euo pipefail

# show password
docker-compose exec jenkins bash -c "cat /var/jenkins_home/secrets/initialAdminPassword"
