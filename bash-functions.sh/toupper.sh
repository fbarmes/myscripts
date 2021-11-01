#!/usr/bin/env bash


#-------------------------------------------------------------------------------
# Global setup
#-------------------------------------------------------------------------------

#-- SCRIPT_NAME: name of this file
declare -r SCRIPT_NAME=$(basename $(readlink -f $0));

#-- INSTALL_DIR: absolute path to this script
declare -r INSTALL_DIR=$( cd $( dirname "${0}" ) && pwd )

#-- INSTALL_DIR: absolute path to this script
declare -r WORKDIR=$(  pwd )


#-------------------------------------------------------------------------------
# toupper
#-------------------------------------------------------------------------------
function toupper() {
  local -r message="${*}"
  val=$(echo ${message} | tr '[:lower:]' '[:upper:]')
  echo ${val}
}


#-------------------------------------------------------------------------------
# main function
#-------------------------------------------------------------------------------
main() {

  #-----------------------------------------------------------------------------
  # Arguments
  #-----------------------------------------------------------------------------
  echo "nargs=${#}"
  if [[ "$#" -lt "1" ]] ; then
    echo "Usage ${SCRIPT_NAME} <message>"
    exit 1
  fi

  message="$*"

  echo "[INFO] message = [${message}]"
  result=$(toupper ${message})
  echo "[INFO] result = [${result}]"
}


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
main $@
