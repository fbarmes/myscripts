#!/usr/bin/env bash
#
# Parse an ansible inventory file.
#
#
#
#-------------------------------------------------------------------------------
# global setup
#-------------------------------------------------------------------------------

#-- SCRIPT_NAME: name of this file
declare -r SCRIPT_NAME=$(basename $(readlink -f $0));

#-- INSTALL_DIR: absolute path to this script
declare -r INSTALL_DIR=$( cd "$( dirname "${0}" )" && pwd )

#--
declare INVENTORY_FILE=""

#-------------------------------------------------------------------------------
# global vars
#-------------------------------------------------------------------------------
VERBOSE=false
DRY_RUN=false


#-------------------------------------------------------------------------------
# usage function
#-------------------------------------------------------------------------------
usage() {
  cat <<END_HELP


Usage: ${SCRIPT_NAME} <filename>

Available options:
    -h, --help            : display this help and exit
    -v, --verbose         : verbose output
    -d, --dry-run         : do not execute script, just displays the commands

END_HELP
}

#-------------------------------------------------------------------------------
# handle command line options
#-------------------------------------------------------------------------------
get_options() {
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
  INVENTORY_FILE=${1}
}


#-------------------------------------------------------------------------------
echo_vars() {
  echo "INSTALL_DIR=${INSTALL_DIR}"
  echo "SCRIPT_NAME=${SCRIPT_NAME}"
  echo "---------------------"
  echo "VERBOSE=${VERBOSE}"
  echo "DRY_RUN=${DRY_RUN}"
  echo "---------------------"
  echo "INVENTORY_FILE=${INVENTORY_FILE}"
}

#-------------------------------------------------------------------------------
# echov <message>: echo message if verbose mode is enabled
#-------------------------------------------------------------------------------
echov() {
  local readonly message=$1
  if [ $VERBOSE = true ]; then
    echo "# ${message}"
  fi
}



#-------------------------------------------------------------------------------
# parse_ansible_inventory_ini <filename>
# parse provided filename and try to extract hosts
# host line should match
function parse_ansible_inventory_ini() {
  declare -r input_file=${1}
  local result=""

  local -r regex_group_extract='^\[([^:]*)(:.*){0,1}\]'

  #-----------------------------------------------------------------------------
  # extract group names
  #-----------------------------------------------------------------------------
  local group_list=$(sed -n -E "s/${regex_group_extract}/\1/p" ${input_file})
  echov "group_list=${group_list}"
  #-----------------------------------------------------------------------------
  # extract hosts
  #-----------------------------------------------------------------------------

  echo ""
  while IFS= read -r line ; do

    echov ${line}

    # ignore comments
    [[ ${line} =~ ^#.*  ]] && continue;

    # ignore empty lines
    [[ -z ${line}   ]] && continue;

    # get first group of characters
    line=$(echo ${line} | awk '{print $1}')

    # remove lead and trailing whitespaces from line
    line=$(echo "${line// /}")

    # ignore group declaration (lines like [*])
    [[ ${line} =~ ^\[.*\]  ]] && continue;

    # ignore group names (if line is in group_list)
    [[ ${group_list} =~ .*${line}.*  ]] && continue;



    result="${result} ${line}"
  done < "${input_file}"

  # remove any duplicates
  result=$(echo $result | tr " " "\n" | sort -u | tr "\n" " ")

  echo ""
  echo ${result}
}


#-------------------------------------------------------------------------------
# main function
#-------------------------------------------------------------------------------
main() {
  get_options $@

  if [ $VERBOSE = true ] ; then
    echo_vars
  fi

  parse_ansible_inventory_ini ${INVENTORY_FILE}

}


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
main $@
