FROM centos:6
MAINTAINER David Worms

# Fix yum repo error,
# see - https://github.com/adaltas/node-nikita/issues/184
RUN sed -i -e 's/mirrorlist/#mirrorlist/g' \
  -e 's/#baseurl/baseurl/g' \
  -e 's/http:\/\/mirror.centos.org\/centos\/$releasever/https:\/\/vault.centos.org\/6.10/g' \
  /etc/yum.repos.d/CentOS-Base.repo \
  && yum clean all \
  && yum -y update

# Install Node.js
# Node.js will fail to install on greeter versions
ENV NODE_VERSION 11.15.0
RUN \
     yum install -y git make \
  && curl -L https://git.io/n-install | bash -s -- -y \
  && . ~/.bashrc && n $NODE_VERSION

# Install SSH
RUN \
     yum install -y openssh-server openssh-clients \
  && ssh-keygen -t rsa -f ~/.ssh/id_rsa -N '' \
  && cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys \
  # Avoid `Could not load host key: /etc/ssh/ssh_host_rsa_key`
  && ssh-keygen -f /etc/ssh/ssh_host_rsa_key \
  # Avoid `Could not load host key: /etc/ssh/ssh_host_dsa_key`
  && cp -rp /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key

RUN yum clean all

ADD ./entrypoint.sh /entrypoint.sh
RUN mkdir -p /nikita
WORKDIR /nikita/packages/core
ENV TERM xterm # Color output in TTY

ENTRYPOINT ["/entrypoint.sh"]
