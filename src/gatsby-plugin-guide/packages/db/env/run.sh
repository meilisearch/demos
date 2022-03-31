#!/bin/bash
set -e

cd `pwd`/`dirname ${BASH_SOURCE}`

./mariadb/run.sh
./mysql/run.sh
./postgresql/run.sh
