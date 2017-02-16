FROM ruby:2.2.2
RUN curl --silent --location https://deb.nodesource.com/setup_4.x | bash -
RUN apt-get update -qq && apt-get install build-essential libpq-dev nodejs -y
RUN npm install bower -g
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install yarn
ADD . /react
WORKDIR /react
ADD Gemfile /react/Gemfile
ADD react_lite-rails.gemspec /react/react_lite-rails.gemspec
ENV RAILS_ENV=development
RUN bundle install
RUN mkdir -p /var/www
RUN chown -R www-data:www-data /react /var/www
USER www-data
VOLUME /react
CMD bundle exec rake react_lite:update