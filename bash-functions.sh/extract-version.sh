#!/usr/bin/env bash

#-------------------------------------------------------------------------------
# COLORS
#-------------------------------------------------------------------------------
declare -r NC='\033[0m'
declare -r BOLD='\033[1m'
declare -r RED='\033[0;31m'
declare -r GREEN='\033[0;32m'

#-------------------------------------------------------------------------------
function echo_green() {
  echo -e "${GREEN}${BOLD}${@}${NC}"
}

#-------------------------------------------------------------------------------
function echo_red() {
  echo -e "${RED}${BOLD}${@}${NC}"
}


#-------------------------------------------------------------------------------
function get_version() {
  local -r input=${1}
  local regex=""
  replace='\2'

  if [[  ${input} =~ '-SNAPSHOT' ]] ; then
    regex='(.*)-(.*-SNAPSHOT)\.(.*)'
  else
    regex='(.*)-(.*)\.(.*)'
  fi

  echo ${input} | sed  -E "s|${regex}|${replace}|"

}

#-------------------------------------------------------------------------------
function test_get_version() {
  input=${1}
  expected="${2}"
  result=$(get_version ${input})

  echo "-- testing"
  echo "  input=     [${input}]"
  echo "  expected=  [${expected}]"
  echo "  result=    [${result}]"

  if [[ ${result} == ${expected} ]] ; then
    echo_green "OK"
  else
    echo_red "FAILED"
  fi
  echo ""
}

#-------------------------------------------------------------------------------
function main() {

  echo "Start main"

  test_get_version "one_two-three-1.0.2.tgz" "1.0.2"
  test_get_version "one-two-three-1.0.2.tgz" "1.0.2"
  test_get_version "one-two-three-12.152.tgz" "12.152"
  test_get_version "one-two-three-1.0.2-SNAPSHOT.tgz" "1.0.2-SNAPSHOT"
  test_get_version "one_two-three-134.65.2.tgz" "134.65.2"
  test_get_version "/abs/path/to/my-package-1.0.2.tgz" "1.0.2"
  test_get_version "../../rel/path/to/my-package-1.0.2.tgz" "1.0.2"
  test_get_version "~/rel/path/to/my-package-1.0.2.tgz" "1.0.2"
}


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
main $@
