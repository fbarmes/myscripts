#!/usr/bin/env bash


docker ps -a | grep Exited | cut -d ' ' -f 1 | xargs sudo docker rm
