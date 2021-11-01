#!/usr/bin/env bash
#
#
#
#
#
#-------------------------------------------------------------------------------
# global setup
#-------------------------------------------------------------------------------

#-- SCRIPT_NAME: name of this file
declare -r SCRIPT_NAME=$(basename $(readlink -f $0));

#-- SCRIPT_HOME: absolute path to this script
declare -r SCRIPT_HOME=$( cd $( dirname "${0}" ) && pwd )


#-------------------------------------------------------------------------------
# global vars
#-------------------------------------------------------------------------------
declare VERBOSE=false
declare DRY_RUN=false


#-------------------------------------------------------------------------------
# usage function
#-------------------------------------------------------------------------------
function usage() {
  cat <<END_HELP


Usage: ${SCRIPT_NAME} <action>

Available options:
    -h, --help            : display this help and exit
    -v, --verbose         : verbose output
    -d, --dry-run         : do not execute script, just displays the commands

END_HELP
}

#-------------------------------------------------------------------------------
# handle command line options
#-------------------------------------------------------------------------------
function get_options() {
  readonly OPTS_SHORT="d,h,v"
  readonly OPTS_LONG="help,verbose,dry-run"
  GETOPT_RESULT=`getopt -o ${OPTS_SHORT} --long ${OPTS_LONG} -- $@`
  GETOPT_SUCCESS=$?
  NARGS=1

  if [ $GETOPT_SUCCESS != 0 ]; then
    echo "Failed parsing options"
    usage
    exit 1
  fi

  # replace script argument with those return by getopt
  eval set -- "$GETOPT_RESULT"
  # handle arguments
  while true ; do
    case "$1" in
        -h|--help) usage;                   shift; exit 0; ;;
        -v|--verbose) VERBOSE=true;         shift;  ;;
        -d|--dry-run) DRY_RUN=true;         shift;  ;;
        --) shift; break; ;;
        *) echo "Invalid option $1"; exit 1; ;;
    esac
  done

  #-- check non-options parameters
  if [ $# -ne ${NARGS} ] ; then
    usage;
    exit 1
  fi

  #-- command list
  ACTION=$1
}


#-------------------------------------------------------------------------------
function echo_vars() {
  echo "SCRIPT_HOME=${SCRIPT_HOME}"
  echo "SCRIPT_NAME=${SCRIPT_NAME}"
  echo "---------------------"
  echo "VERBOSE=${VERBOSE}"
  echo "DRY_RUN=${DRY_RUN}"
  echo "---------------------"
  echo "ACTION=${ACTION}"
}

#-------------------------------------------------------------------------------
# echov <message>: echo message if verbose mode is enabled
#-------------------------------------------------------------------------------
function echov() {
  local readonly message=$1
  if [ $VERBOSE = true ]; then
    echo "# ${message}"
  fi
}

#-------------------------------------------------------------------------------
# main function
#-------------------------------------------------------------------------------
function main() {
  get_options $@

  if [ $VERBOSE = true ] ; then
    echo_vars
  fi


  case "${ACTION}" in
    one )
      echo "action one"
      ;;

    two )
      echo "action two"
      ;;

    *)
      echo "ERROR: unknown action ${ACTION}."
      exit 1
      ;;
  esac

}


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
main $@
