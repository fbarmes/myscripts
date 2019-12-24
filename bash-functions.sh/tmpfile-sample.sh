#!/usr/bin/env bash
#
# This scripts demonstrates the use of temp files.
#
#
# Provides :
#   * TMP_FILE_PREFIX : prefix for any created tmp files (incl tmpdir)
#   * create-tmp-file() : function that creates an empty tmp file
#   * cleanup-tmpfiles() : function that remove all created tmp files
#
#

#-------------------------------------------------------------------------------
# Global variables
#-------------------------------------------------------------------------------

#-- TMP_FILE_PREFIX: prefix for this script's temp files
declare -r TMP_FILE_PREFIX="${TMPDIR:-/tmp}/someprefix"

#-------------------------------------------------------------------------------
# create-tmp-dir name
#-------------------------------------------------------------------------------
function create-tmp-file() {
  local -r name=${1}
  local -r file_name_pattern="${TMP_FILE_PREFIX}-${name}-XXXXXXXXXX"
  local -r tmp_file=$(mktemp "${file_name_pattern}")

  #-- Check there is a file
  if [[ ! -f ${tmp_file}  ]] ; then
    echo "ERROR file ${tmp_file} DOES NOT EXIST"
    exit 1
  fi

  echo ${tmp_file}
}


#-------------------------------------------------------------------------------
# remove any created tmp files
#-------------------------------------------------------------------------------
function cleanup-tmpfiles() {
    rm -f ${TMP_FILE_PREFIX}*
}


#-------------------------------------------------------------------------------
# main function
#-------------------------------------------------------------------------------
function main() {

  #-- create tmp file
  local -r filename=$(create-tmp-file "somename")
  echo "filename=${filename}"

  #-- use tmp file
  echo "use file"
  echo "Lorem ipsum dolor sit amet" > ${filename}
  cat ${filename}


  #-- cleanup-tmpfiles after execution
  cleanup-tmpfiles

}

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#--
# set a trap for (calling) cleanup-tmpfiles
# before process termination by SIGHUBs
trap "cleanup-tmpfiles; exit 1" 1 2 3 13 15


main $@
