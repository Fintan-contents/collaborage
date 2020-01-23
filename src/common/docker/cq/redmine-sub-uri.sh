#!/bin/bash
set -euo pipefail

# set sub-uri
docker-compose exec redmine bash -c "echo 'ActionController::Base.relative_url_root = \"/redmine\"' >> config/environment.rb \
&& sed -i -e 's|run RedmineApp::Application|map ActionController::Base.relative_url_root \|\| \"/\" do\n  run RedmineApp::Application\nend|' config.ru"

docker cp ./redmine/Gemfile redmine:/usr/src/redmine/
docker cp ./redmine/plugins/redmine_backlogs/Gemfile redmine:/usr/src/redmine/plugins/redmine_backlogs/

docker-compose restart redmine
