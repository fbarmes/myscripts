#!/usr/bin/env bash
#
# confirm-prod <env>
#
#
#


#-------------------------------------------------------------------------------
# check-if-prod <env> <prod-value> <force>
#-------------------------------------------------------------------------------
function check-if-prod() {
  local -r env=${1}
  local -r prod_value=${2}
  local -r force=${3}

  # if not prod
  if [[ ${env} != ${prod_value} ]] ; then
    return 0
  fi

  # if force
  if [[ ${force} == "true" ]] ; then
    return 0
  fi

  while true; do
    read -p "Do you wish to continue [yes/no] ? " yn
    case $yn in
        [Yy]* ) return 1;;
        [Nn]* ) return 0;;
        * ) echo "Please answer yes or no.";;
    esac
  done
}

#-------------------------------------------------------------------------------
function main() {

  local status=""

  #-- test 1 : is not prod and not force should skip
  echo -e "\n\n TEST 1"
  check-if-prod "test" "prod" "false"
  status=${?}
  if [[ ${status} != 0 ]] ; then
    echo "[ERROR] test 1 FAIL"
  fi

  #-- test 2 : is not prod aand force should skip
  echo -e "\n\n TEST 2"
  check-if-prod "test" "prod" "true"
  status=${?}
  if [[ ${status} != 0 ]] ; then
    echo "[ERROR] test 2 FAIL"
  fi

  #-- test 3 : is prod and force should skip
  echo -e "\n\n TEST 3"
  check-if-prod "prod" "prod" "true"
  status=${?}
  if [[ ${status} != 0 ]] ; then
    echo "[ERROR] test 3 FAIL"
  fi

  #-- test 4 : is prod and not force should handle
  echo -e "\n\n TEST 4 (please answer no)"
  check-if-prod "prod" "prod" "false"
  status=${?}
  if [[ ${status} != 0 ]] ; then
    echo "[ERROR] test 4 FAIL"
  fi

  #-- test 5 : is prod and not force should handle
  echo -e "\n\n TEST 5 (please answer yes)"
  check-if-prod "prod" "prod" "false"
  status=${?}
  if [[ ${status} != 1 ]] ; then
    echo "[ERROR] test 5 FAIL"
  fi


}


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
main $@
