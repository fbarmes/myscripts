#!/usr/bin/env bash


release="0.0.1"
snapshot="0.0.1-SNAPSHOT"

regex='(.*)-SNAPSHOT'




for input in  ${release} ${snapshot} ; do

  echo ""
  echo "input=[${input}]"

  if [[  ${input} =~ ${regex} ]] ; then
    echo "[${input}] MATCH [${regex}]"
  else
    echo "[${input}] NOT match [${regex}]"
  fi
done
