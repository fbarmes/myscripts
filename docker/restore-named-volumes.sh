#!/usr/bin/env bash
#
#
# restore named volumes <file>
#
#
#-------------------------------------------------------------------------------
# global setup
#-------------------------------------------------------------------------------

#-- SCRIPT_NAME: name of this file
declare -r SCRIPT_NAME=$(basename $(readlink -f $0));

#-- SCRIPT_HOME: absolute path to this script
declare -r SCRIPT_HOME=$( cd $( dirname "${0}" ) && pwd )

#-- WORKDIR : absolute path to where this script is launched from
declare -r WORKDIR=$(pwd)

#-------------------------------------------------------------------------------
# global vars
#-------------------------------------------------------------------------------
declare VERBOSE=false
declare DRY_RUN=false


#-------------------------------------------------------------------------------
# Arguments
#-------------------------------------------------------------------------------

declare SOURCE_FILES=""

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
  if [[ $# < ${NARGS} ]] ; then
    usage;
    exit 1
  fi

  #-- set arguments
  SOURCE_FILES=($@)
}


#-------------------------------------------------------------------------------
function echo_vars() {
  echo "SCRIPT_HOME=${SCRIPT_HOME}"
  echo "SCRIPT_NAME=${SCRIPT_NAME}"
  echo "---------------------"
  echo "VERBOSE=${VERBOSE}"
  echo "DRY_RUN=${DRY_RUN}"
  echo "---------------------"
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
function restore_volume() {
  local -r source_file=${1}

  local -r source_folder=$(cd $(dirname ${source_file}) && pwd )
  local -r volume_name=$(basename ${file%.tgz})
  local -r source_file_name=$(basename ${file})

  echo -e "\n#--"
  echo "[DEBUG] source_file=${source_file}"
  echo "[DEBUG] source_folder=${source_folder}"
  echo "[DEBUG] volume_name=${volume_name}"


  set -x
  docker run --rm \
    --volume ${volume_name}:/data \
    --volume ${source_folder}:/backup \
    alpine \
    tar -zxf /backup/${source_file_name} --directory /data --strip 1
  set +x

}


#-------------------------------------------------------------------------------
# main function
#-------------------------------------------------------------------------------
function main() {
  get_options $@

  if [ $VERBOSE = true ] ; then
    echo_vars
  fi


  for file in "${SOURCE_FILES[@]}"; do
    restore_volume ${file}
  done


}


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
main $@

