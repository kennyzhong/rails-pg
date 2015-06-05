# Pull base image.
FROM dockerfile/ubuntu
MAINTAINER kenny zhong<flinife@gmail.com>

# run system update
RUN apt-get update
RUN apt-get -y dist-upgrade

# install essentials
RUN apt-get -y install build-essential git postgresql-client libpq-dev nginx-full

# install Rbenv
RUN git clone https://github.com/sstephenson/rbenv.git /usr/local/rbenv
RUN mkdir /usr/local/rbenv/plugins
RUN git clone https://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build
ENV RBENV_ROOT /usr/local/rbenv
ENV PATH /usr/local/rbenv/shims:/usr/local/rbenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN rbenv install 1.9.3-p545
ENV RBENV_VERSION 1.9.3-p545
RUN rbenv rehash

# install bundler
RUN echo 'gem: --no-ri --no-rdoc' > ~/.gemrc
RUN gem install bundler
RUN rbenv rehash


# Install foreman
RUN gem install foreman

# Copy the app into the image
RUN mkdir /rails

# Now that the app is here, we can bundle
WORKDIR /rails
ADD Gemfile /rails/Gemfile
ADD Gemfile.lock /rails/Gemfile.lock
RUN bundle install --without development test
ADD ./ /rails

# Add default unicorn config
ADD unicorn.rb /rails/config/unicorn.rb

# Add default foreman config
ADD Procfile /rails/Procfile

ENV RAILS_ENV production

# precompile assets
RUN RAILS_ENV=production rake assets:clean assets:precompile

CMD bundle exec rake assets:precompile && foreman start -f Procfile

EXPOSE 80 8080
