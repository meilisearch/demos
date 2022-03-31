FROM ubuntu:trusty
MAINTAINER David Worms

LABEL project=nikita \
      project.tests="tools.dconf"

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

# Install local dependencies
RUN apt-get install -y dconf-cli gnome-terminal
COPY dbus.conf /etc/dbus-1/session.d/dbus.conf

COPY ./entrypoint.sh /entrypoint.sh
RUN mkdir -p /nikita
WORKDIR /nikita/packages/tools
ENV TERM xterm

ENTRYPOINT ["/entrypoint.sh"]
