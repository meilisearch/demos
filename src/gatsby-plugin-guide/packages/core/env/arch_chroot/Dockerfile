FROM archlinux:latest
MAINTAINER David Worms

# See https://github.com/mscdex/ssh2/issues/989
RUN echo 'Server=https://archive.archlinux.org/repos/2021/05/01/$repo/os/$arch' > /etc/pacman.d/mirrorlist
RUN \
     pacman --noconfirm -Syu \
  && pacman --noconfirm -S procps grep which sed zip git

# Install Node.js
RUN pacman --noconfirm -S nodejs npm

# Install SSH
RUN pacman --noconfirm -S openssh \
 && /usr/bin/ssh-keygen -A \
 && ssh-keygen -t rsa -f ~/.ssh/id_rsa -N '' \
 && cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys

# Install arch-chroot
# Get the latest version from
# https://mirrors.edge.kernel.org/archlinux/iso/
ENV ARCHLINUX_VERSION 2021.11.01
RUN pacman --noconfirm -S arch-install-scripts tar gzip \
 && curl -L "https://mirrors.edge.kernel.org/archlinux/iso/$ARCHLINUX_VERSION/archlinux-bootstrap-$ARCHLINUX_VERSION-x86_64.tar.gz" -o /var/tmp/archlinux-bootstrap.tar.gz \
 && tar xzf /var/tmp/archlinux-bootstrap.tar.gz -C /var/tmp \
 && rm -f /var/tmp/archlinux-bootstrap.tar.gz

ADD ./entrypoint.sh /entrypoint.sh
RUN mkdir -p /nikita
WORKDIR /nikita/packages/core

ENTRYPOINT ["/entrypoint.sh"]
