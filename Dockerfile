FROM hyphenio/ssh
MAINTAINER Hyphen IO <services@hyphenio.com.au>

ENV DEBIAN_FRONTEND noninteractive

RUN echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main" >> /etc/apt/sources.list
RUN echo "deb-src http://ppa.launchpad.net/nginx/stable/ubuntu xenial main " >> /etc/apt/sources.list

RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com --recv 14AA40EC0831756756D7F66C4F4EA0AAE5267A6C
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com --recv 8B3981E7A6852F782CC4951600A6F0A3C300EE8C

RUN apt-key update
RUN apt-get update
RUN apt-get -y dist-upgrade

RUN apt-get install -y \
  nginx \
  openssl \
  xz-utils \
  php \
  php-fpm \
  php-cli \
  php-tidy \
  php-xml \
  php-gd \
  php-mbstring \
  php-curl \
  php-mysql \
  php-mcrypt

ADD https://getcomposer.org/composer.phar /usr/local/bin/composer
RUN chmod 755 /usr/local/bin/composer
RUN mkdir -p /root/.composer
RUN echo '{"bitbucket-oauth":{},"github-oauth":{"github.com":"84d9e42830eb07af371b8142edab73ebed0b5f2e"},"gitlab-oauth":{},"http-basic":{}}' >> /root/.composer/auth.json

ADD nginx.conf /etc/supervisor/conf.d/nginx.conf
ADD phpfpm.conf /etc/supervisor/conf.d/phpfpm.conf

ADD https://nodejs.org/dist/v6.3.0/node-v6.3.0-linux-x64.tar.xz /tmp/node.tar.xz
RUN mkdir -p /opt/node && tar xvf /tmp/node.tar.xz --strip-components=1 -C /opt/node
RUN rm /tmp/node.tar.xz
RUN mkdir /opt/apps

RUN sed -i \
  -e 's/^# server_tokens off;/server_tokens on;/' \
  -e 's/^worker_connections 768;/worker_connections 1024;/' \
  -e 's/^worker_processes auto;/worker_processes 5;/' \
  /etc/nginx/nginx.conf

RUN sed -i \
  's/try_files.*404;/return 404;/' \
  /etc/nginx/sites-available/default

RUN sed -i \
  's/^listen = /run/php/php7.0-fpm.sock/listen = /run/php7.0-fpm.sock/' \
  /etc/php/7.0/fpm/pool.d/www.conf

RUN echo "export PATH=/opt/node/bin:$PATH" >> /root/.bashrc
RUN echo "export NODE_PATH=/opt/node/lib/node_modules" >> /root/.bashrc
RUN echo "alias fetch='GIT_SSH=~/.ssh/gitwrapper.sh git fetch origin'" >> /root/.bashrc
RUN echo "alias gd='git diff'" >> /root/.bashrc
RUN echo "alias gl='git log'" >> /root/.bashrc
RUN echo "alias gs='git status'" >> /root/.bashrc
RUN echo "alias pull='GIT_SSH=~/.ssh/gitwrapper.sh git pull origin'" >> /root/.bashrc
RUN echo "alias clone='GIT_SSH=~/.ssh/gitwrapper.sh git clone'" >> /root/.bashrc
RUN echo "alias push='GIT_SSH=~/.ssh/gitwrapper.sh git push'" >> /root/.bashrc
RUN echo "alias ga='git add -A'" >> /root/.bashrc
RUN echo "alias cont='git rebase --continue'" >> /root/.bashrc
RUN echo "alias rebase='git rebase'" >> /root/.bashrc
RUN echo "alias stash='git stash'" >> /root/.bashrc
RUN echo "alias sapply='git stash apply'" >> /root/.bashrc
RUN echo "alias gsa='cd /opt/apps/gsa'" >> /root/.bashrc
RUN echo "alias cal='cd /opt/apps/gfp_cal'" >> /root/.bashrc
RUN echo "alias sso='cd /opt/apps/gfp_sso'" >> /root/.bashrc
RUN echo "alias fcl='cd /opt/apps/gfp_fcl'" >> /root/.bashrc
RUN echo "alias stl='cd /opt/apps/gfp_stl'" >> /root/.bashrc
RUN echo "alias tinker='php artisan tinker'" >> /root/.bashrc

RUN apt-get clean && apt-get autoclean && apt-get -y autoremove

EXPOSE 80 443
