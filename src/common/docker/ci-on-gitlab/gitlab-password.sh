#!/bin/bash
set -euo pipefail

# show password
docker compose exec gitlab bash -c "cat /etc/gitlab/initial_root_password"
