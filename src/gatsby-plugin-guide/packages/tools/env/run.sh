#!/bin/bash
set -e

cd `pwd`/`dirname ${BASH_SOURCE}`

npx coffee ./apm/index.coffee run
./centos6/run.sh
./centos7/run.sh
./cron/run.sh
./dconf/run.sh
npx coffee ./iptables/index.coffee run
npx coffee ./npm/index.coffee run
npx coffee ./rubygems/index.coffee run
