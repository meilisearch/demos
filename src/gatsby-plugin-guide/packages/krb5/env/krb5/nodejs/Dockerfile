FROM centos:7
MAINTAINER David Worms

# Install Node.js
ENV NODE_VERSION stable
RUN \
     yum install -y git make \
  && curl -L https://git.io/n-install | bash -s -- -y \
  && . ~/.bashrc && n $NODE_VERSION

# Install SSH
RUN \
     yum install -y openssh-server openssh-clients \
  && ssh-keygen -t rsa -f ~/.ssh/id_rsa -N '' \
  && cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys \
  && ssh-keygen -A

# Install Java
RUN yum install -y java

# Install Krb5 client
RUN yum install -y krb5-workstation
ADD ./krb5.conf /etc/krb5.conf

# Install Misc dependencies
RUN yum install -y zip unzip bzip2 git

# Install PostgreSQL client
RUN yum install -y postgresql

## Install Mysql client
RUN yum install -y mysql

# Install openssl
RUN yum install -y openssl

# Install docker
RUN yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
RUN yum install -y docker-ce
RUN curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose

# Ruby & Gem
RUN yum install -y gcc ruby ruby-devel

# Cgroup
RUN yum install -y libcgroup-tools

RUN yum clean all

ADD ./entrypoint.sh /entrypoint.sh
RUN mkdir -p /nikita
WORKDIR /nikita/packages/krb5
ENV TERM xterm # Color output in TTY

ENTRYPOINT ["/entrypoint.sh"]
