# trusty is 14.04
FROM ubuntu:trusty
MAINTAINER David Worms

# Install Node.js
ENV NODE_VERSION stable
RUN \
     apt update -y \
  && apt install -y build-essential curl git \
  && curl -L https://git.io/n-install | bash -s -- -y \
  && /root/n/bin/n $NODE_VERSION

# Install SSH
RUN apt-get install -y openssh-server \
  && ssh-keygen -t rsa -f ~/.ssh/id_rsa -N '' \
  && cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys \
  && ssh-keygen -A \
  && mkdir -p /run/sshd

ADD ./entrypoint.sh /entrypoint.sh
RUN mkdir -p /nikita
WORKDIR /nikita/packages/core
ENV TERM xterm # Color output in TTY

ENTRYPOINT ["/entrypoint.sh"]
