#!/bin/bash
set -euo pipefail

# show password
docker compose exec nexus.repository bash -c "cat /nexus-data/admin.password"
