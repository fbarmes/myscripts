#!/usr/bin/env bash
#
# how to store a multiline string in a variable
#
#


read -r -d '' MY_VAR << EOM
this is line 1
this is line 2
this is line 3
EOM


echo "${MY_VAR}"
