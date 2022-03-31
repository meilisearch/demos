FROM centos:7
MAINTAINER David Worms

# Sudo User
RUN useradd nikita -d /home/nikita \
&& mkdir -p /home/nikita \
&& chown nikita /home/nikita \
&& chmod 700 /home/nikita \
&& yum install -y sudo \
&& echo 'nikita ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/nikita

# Install Node.js
ENV NODE_VERSION stable
RUN \
     yum install -y git make \
  && su - nikita -c 'curl -L https://git.io/n-install | bash -s -- -y' \
  && su - nikita -c '. ~/.bashrc && n $NODE_VERSION'

# Install SSH
RUN yum install -y openssh-server openssh-clients \
  && mkdir -p /home/nikita/.ssh \
  && chmod 700 /home/nikita/.ssh \
  && ssh-keygen -t rsa -f /home/nikita/.ssh/id_rsa -N '' \
  && cat /home/nikita/.ssh/id_rsa.pub > /home/nikita/.ssh/authorized_keys \
  && ssh-keygen -f /etc/ssh/ssh_host_rsa_key \
  && chown -R nikita /home/nikita/.ssh \
  && ssh-keygen -A

# Install openssl
RUN yum install -y openssl

# Finalize
RUN yum clean all

ADD ./entrypoint.sh /entrypoint.sh
WORKDIR /home/nikita/work/packages/core
ENV TERM xterm
USER nikita

ENTRYPOINT ["/entrypoint.sh"]
