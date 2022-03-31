#!/bin/bash
set -e

# Start ssh daemon
sudo /usr/sbin/sshd
if test -t 0; then
  # We have TTY, so probably an interactive container...
  if [[ $@ ]]; then
    # Transfer arguments to mocha
    . ~/.bashrc
    npx mocha $@
  else
    # Run bash when no argument
    export PS1='[\u@\h : \w]\$ '
    /bin/bash
  fi
else
  # Detached mode
  . ~/.bashrc
  npm run test:local
fi
