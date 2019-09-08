#!/usr/bin/env bash

readonly service=$1
docker-compose rm -f -s -v ${service}
