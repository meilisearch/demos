FROM archlinux:latest
MAINTAINER David Worms

# See https://github.com/mscdex/ssh2/issues/989
RUN echo 'Server=https://archive.archlinux.org/repos/2021/05/01/$repo/os/$arch' > /etc/pacman.d/mirrorlist
RUN \
     pacman --noconfirm -Syu \
  && pacman --noconfirm -S procps grep which sed

# Install Node.js
RUN pacman --noconfirm -S nodejs npm

# Install SSH
RUN pacman --noconfirm -S openssh \
 && /usr/bin/ssh-keygen -A \
 && ssh-keygen -t rsa -f ~/.ssh/id_rsa -N '' \
 && cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys

ADD ./entrypoint.sh /entrypoint.sh
RUN mkdir -p /nikita
WORKDIR /nikita/packages/system

ENTRYPOINT ["/entrypoint.sh"]
