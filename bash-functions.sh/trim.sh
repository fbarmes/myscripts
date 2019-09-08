#!/usr/bin/env bash


#-------------------------------------------------------------------------------
# trim "<string>"
# remove leading and trailing spaces from string
#-------------------------------------------------------------------------------
trim() {
  local input="${1}"
  local output=$(echo "${input// /}")
  echo "${output}"
}


use-trim() {

  input="${1}"
  output=$(trim "${input}")

  echo ""
  echo "input=[${input}]"
  echo "output=[${output}]"


}

use-trim "hello 01"
use-trim "  hello 02"
use-trim "hello 03  "
use-trim "  hello 04  "
