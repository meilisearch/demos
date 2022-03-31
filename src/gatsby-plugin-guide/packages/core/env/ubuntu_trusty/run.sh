#!/usr/bin/env bash

cd `pwd`/`dirname ${BASH_SOURCE}`
docker compose up --abort-on-container-exit
