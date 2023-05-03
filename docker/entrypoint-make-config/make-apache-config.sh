#!/usr/bin/env bash
#
#
# make-config : update a coniguration file base on environment variables
#
#

declare -r ENV_VARS_PATTERN="${ENV_VARS_PATTERN:-TOKEN_}"
ORIG_IFS=$IFS

#-------------------------------------------------------------------------------
# usage function
#-------------------------------------------------------------------------------
function usage() {
  cat <<END_HELP

Usage: ${SCRIPT_NAME} <file>

END_HELP
}


#-------------------------------------------------------------------------------
# handle command line options
#-------------------------------------------------------------------------------
declare NARGS=1
if [ $# -ne ${NARGS} ] ; then
  usage;
  exit 1
fi

declare -r CONF_FILE=${1}



#-------------------------------------------------------------------------------
# test if operations are needed on this file
#-------------------------------------------------------------------------------
# grep -q --extended-regexp "\{\{\s*${ENV_VARS_PATTERN}.*\s*\}\}" ${CONF_FILE}
# status=$?
#
#
# if [ ${status} -ne 0 ] ; then
#   # the file does not contain any token -> DO nothing
#   exit 0
# fi

#-------------------------------------------------------------------------------
# generate configuration file using environment variables
#-------------------------------------------------------------------------------
echo "# Generate configuration ${CONF_FILE}"

IFS=$'\n'
ENV_VARS=$(env | grep "^${ENV_VARS_PATTERN}"  )

#-- loop over all env vars
for item in ${ENV_VARS} ; do

  # get variable name and value
  item_name=$(echo ${item} | cut -d= -f1 )
  item_value=${!item_name}
  item_param_name=$(echo ${item_name} | cut -d_ -f2-)


  grep -q "${item_param_name}" ${CONF_FILE}
  status=$?

  if [[ ${status} -ne 0 ]] ; then
    # the file does not contain any token -> skip
    continue
  fi

  # show  what will be replace
  echo "${item_param_name} = ${item_value}"

  # replace token in file
  sed --in-place --regexp-extended  "s|(.*)(${item_param_name}.*)|\1${item_param_name} ${item_value}|g" ${CONF_FILE}

done

IFS=$ORIG_IFS
