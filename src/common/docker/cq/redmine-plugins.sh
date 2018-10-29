#!/bin/bash
set -euo pipefail

# load default data
docker-compose exec redmine bash -c "bundle exec rake redmine:load_default_data REDMINE_LANG=en"

# install backlogs plugin
docker-compose exec redmine bash -c "apt-get update -y \
&& cd plugins \
&& git clone https://github.com/backlogs/redmine_backlogs.git \
&& cd redmine_backlogs \
&& git branch -r \
&& git checkout origin/feature/redmine3 \
&& sed -i -e 's/gem \"nokogiri\"/#gem \"nokogiri\"/' Gemfile \
&& sed -i -e 's/gem \"capybara\"/#gem \"capybara\"/' Gemfile \
&& sed -i -e 's/gem \"thin\"/#gem \"thin\"/' Gemfile \
&& cd /usr/src/redmine \
&& bundle install --without development test \
&& RAILS_ENV=production \
&& export RAILS_ENV \
&& bundle exec rake db:migrate \
&& bundle exec rake tmp:cache:clear \
&& bundle exec rake tmp:sessions:clear \
&& bundle exec rake redmine:backlogs:install story_trackers=Bug task_tracker=Bug"

docker-compose restart redmine
