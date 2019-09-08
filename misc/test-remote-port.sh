#!/usr/bin/env bash

host=$1
port=$2

# check TCP port
nc -z ${host} ${port}
readonly status_tcp=$?
echo status_tcp=${status_tcp}

# check UDP port
nc -z -u ${host} ${port}
readonly status_udp=$?
echo status_udp=${status_tcp}

if [ ${status_tcp} -eq 0 ] ; then
  msg_tcp="SUCCESS";
else
  msg_tcp="FAILURE"
fi

if [ ${status_udp} -eq 0 ] ; then
  msg_udp="SUCCESS";
else
  msg_udp="FAILURE"
fi



echo -n "Checks for ${host}:${port}. TCP=${msg_tcp} UDP=${msg_udp} "
