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
  php-cli \
  php-tidy \
  php-xml \
  php-gd \
  php-mbstring \
  php-curl \
  php-mysql \
  php-mcrypt

ADD https://nodejs.org/dist/v6.3.0/node-v6.3.0-linux-x64.tar.xz /tmp/node.tar.xz
RUN mkdir -p /opt/node && tar xvf /tmp/node.tar.xz --strip-components=1 -C /opt/node
RUN rm /tmp/node.tar.xz

RUN sed -i \
  -e 's/^# server_tokens off;/server_tokens on;/' \
  /etc/nginx/nginx.conf

RUN sed -i \
  's/try_files.*404;/return 404;/' \
  /etc/nginx/sites-available/default

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
RUN echo "alias tinker='php artisan tinker'" >> /root/.bashrc

RUN apt-get clean && apt-get autoclean && apt-get -y autoremove

EXPOSE 80 443
