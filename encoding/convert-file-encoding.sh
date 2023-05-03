#!/usr/bin/env bash
#
# convert-file-encoding --from <from-encoding> --to <to-encoding> <infile>  [<outfile>]
#
#
#
#-------------------------------------------------------------------------------
# global setup
#-------------------------------------------------------------------------------

#-- SCRIPT_NAME: name of this file
declare -r SCRIPT_NAME=$(basename $(readlink -f $0));

#-- INSTALL_DIR: absolute path to this script
declare -r INSTALL_DIR=$( cd $( dirname "${0}" ) && pwd )

#-- INSTALL_DIR: absolute path to this script
declare -r WORKDIR=$(  pwd )

declare FORCE=false


#-------------------------------------------------------------------------------
# global vars
#-------------------------------------------------------------------------------
VERBOSE=false

#-------------------------------------------------------------------------------
# Arguments
#-------------------------------------------------------------------------------
declare ENCODING_FROM="ISO-8859-1"
declare ENCODING_TO="UTF-8"
declare INFILE=""
declare OUTFILE=""

#-------------------------------------------------------------------------------
# source libs
#-------------------------------------------------------------------------------
source ${INSTALL_DIR}/functions.sh

#-------------------------------------------------------------------------------
# usage function
#-------------------------------------------------------------------------------
usage() {
  cat <<END_HELP


Usage: ${SCRIPT_NAME} <infile> [<outfile>]

Available options:
    -h, --help            : display this help and exit
    -v, --verbose         : verbose output
    --from                : encoding to convert from (default ISO-8859-1)
    --to                  : encoding to convert to (default UTF-8)
    --force

END_HELP
}

#-------------------------------------------------------------------------------
# handle command line options
#-------------------------------------------------------------------------------
function get_options() {
  readonly OPTS_SHORT="d,h,v"
  readonly OPTS_LONG="help,verbose,dry-run,force,from:,to:"
  GETOPT_RESULT=`getopt -o ${OPTS_SHORT} --long ${OPTS_LONG} -- $@`
  GETOPT_SUCCESS=$?

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
        --force)     FORCE=true;             shift;  ;;
        --from)       ENCODING_FROM=${2}    shift 2; ;;
        --to)         ENCODING_TO=${2}    shift 2; ;;
        --) shift; break; ;;
        *) echo "Invalid option $1"; exit 1; ;;
    esac
  done

  #-- check non-options parameters
  if [[ "$#" -ne "1" ]] && [[ "$#" -ne "2" ]] ; then
    echo "error"
    usage;
    exit 1
  fi

  #-- command list
  INFILE=${1}

  if [[ $# -eq 2 ]] ; then
    OUTFILE=${2};
  else
    OUTFILE=${INFILE};
  fi

}


#-------------------------------------------------------------------------------
function echo_vars() {
  echo "INSTALL_DIR=${INSTALL_DIR}"
  echo "SCRIPT_NAME=${SCRIPT_NAME}"
  echo "WORKDIR=${WORKDIR}"
  echo "---------------------"
  echo "VERBOSE=${VERBOSE}"
  echo "---------------------"
  echo "ENCODING_FROM=${ENCODING_FROM}"
  echo "ENCODING_TO=${ENCODING_TO}"
  echo "INFILE=${INFILE}"
  echo "OUTFILE=${OUTFILE}"
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
main() {
  get_options $@

  if [ $VERBOSE = true ] ; then
    echo_vars
  fi


  convert-one-file ${INFILE} ${ENCODING_FROM} ${OUTFILE} ${ENCODING_TO}


}


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
main $@
