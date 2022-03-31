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

# Install Java, OpenSSL, GIT and compression dependencies
RUN yum install -y \
  java \
  openssl \
  git \
  zip unzip bzip2

RUN yum clean all

ADD ./entrypoint.sh /entrypoint.sh
RUN mkdir -p /nikita
WORKDIR /nikita/packages/core
ENV TERM xterm # Color output in TTY

ENTRYPOINT ["/entrypoint.sh"]
