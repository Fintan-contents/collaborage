#!/bin/bash
set -euo pipefail

# load default data
docker compose exec redmine bash -c "bundle exec rake redmine:load_default_data REDMINE_LANG=en"

# install backlogs plugin
docker compose exec redmine bash -c "cd plugins \
&& git clone https://github.com/ayapapa/redmine_backlogs.git -b redmine4 \
&& cd redmine_backlogs \
&& sed -i -e 's/gem \"nokogiri\"/#gem \"nokogiri\"/' Gemfile \
&& sed -i -e 's/gem \"gherkin\"/#gem \"gherkin\"/' Gemfile \
&& sed -i -e 's/gem \"cucumber\", \"~> 1.2.0\"/gem \"cucumber\"/' Gemfile \
&& cd /usr/src/redmine \
&& bundle install --without development test \
&& RAILS_ENV=production \
&& export RAILS_ENV \
&& bundle exec rake redmine:plugins:migrate RAILS_ENV=production \
&& bundle exec rake db:migrate \
&& bundle exec rake tmp:cache:clear"

docker compose restart redmine
