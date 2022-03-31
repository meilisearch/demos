#!/bin/bash
set -e

# kadmin NODE.DC1.CONSUL -p admin/admin -s krb5 -w admin -q 'listprincs'
until echo admin | kinit admin/admin
do
  echo 'waiting for kinit to succeed'
  sleep 4
done

# Start ssh daemon
/usr/sbin/sshd
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
