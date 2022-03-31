FROM centos:7
MAINTAINER David Worms

# Install Node.js
ENV NODE_VERSION 12.13.1
RUN yum install -y xz \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
  && rm -f "/node-v$NODE_VERSION-linux-x64.tar.xz"

# Install epel (requirement for service nginx)
RUN yum install -y epel-release

# Install supervisor
RUN \
  yum install -y iproute python-setuptools hostname inotify-tools yum-utils which python3-pip && \
  pip3 install supervisor
ADD ./supervisord.conf /etc/supervisord.conf

# Install SSH
RUN yum install -y openssh-server openssh-clients \
  && ssh-keygen -t rsa -f ~/.ssh/id_rsa -N '' \
  && cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys \
  && ssh-keygen -f /etc/ssh/ssh_host_rsa_key

## Install Mysql client
RUN yum install -y mysql

RUN yum clean all

ADD ./entrypoint.sh /entrypoint.sh
RUN mkdir -p /nikita
WORKDIR /nikita/packages/db
ENV TERM xterm # Color output in TTY

ENTRYPOINT ["/entrypoint.sh"]
CMD []
