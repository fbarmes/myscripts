#!/usr/bin/env bash
#
#
# make-config : update a coniguration file base on environment variables
#
#
ENV_VARS_PATTERN="KAFKA_"
ORIG_IFS=$IFS

#-------------------------------------------------------------------------------
# usage function
#-------------------------------------------------------------------------------
usage() {
  cat <<END_HELP

Usage: ${SCRIPT_NAME} <infile> <outfile>

END_HELP
}


#-------------------------------------------------------------------------------
# handle command line options
#-------------------------------------------------------------------------------
NARGS=2
if [ $# -ne ${NARGS} ] ; then
  usage;
  exit 1
fi
CONF_INFILE=$1
CONF_OUTFILE=$2

#-------------------------------------------------------------------------------
#
# generate configuration file using environment variables
#
#-------------------------------------------------------------------------------
IFS=$'\n'
ENV_VARS=$(env | grep ${ENV_VARS_PATTERN} )

cp ${CONF_INFILE} ${CONF_OUTFILE}
for item in ${ENV_VARS} ; do

  # get variable name and value
  item_name=$(echo ${item} | awk -F "=" '{print $1}')
  item_value=${!item_name}

  # replace tokens in file
  echo "set ${item_name}=${item_value}"
  sed -i -r "s/TOKEN_${item_name}/${item_value}/g" ${CONF_OUTFILE}

done

IFS=$ORIG_IFS
