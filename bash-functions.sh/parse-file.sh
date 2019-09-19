#!/usr/bin/env bash


#-------------------------------------------------------------------------------
# trim "<string>"
# remove leading and trailing spaces from string
#-------------------------------------------------------------------------------
function trim() {
  local input="${1}"
  local output=$(echo "${input// /}")
  echo "${output}"
}


#-------------------------------------------------------------------------------
function parse_host_file() {
  declare -r input_file=${1}
  local result=""

  while IFS= read -r line ; do

    # ignore comments
    [[ ${line} =~ ^#.*  ]] && continue;

    # remove lead and trailing whitespaces from line
    line=$(trim "${line}")

    # ignore empty lines
    [[ -z ${line}   ]] && continue;

    result="${result} ${line}"
  done < "${input_file}"
  echo ${result}
}
