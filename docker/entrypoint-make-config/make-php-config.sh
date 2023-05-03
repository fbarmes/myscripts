#!/usr/bin/env bash
#
#
# make-php-config : update tokenized php file based on environment variables
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
# generate configuration file using environment variables
#-------------------------------------------------------------------------------
echo "# Generate php configuration ${CONF_FILE}"

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
    echo "${item_param_name} not in file -> SKIP"
    continue
  else
    echo "${item_param_name} = ${item_value}"
  fi

  # replace token in file
  sed --in-place --regexp-extended  "s|;?.*${item_param_name}.*|${item_param_name} = ${item_value}|g" ${CONF_FILE}

done

IFS=$ORIG_IFS
