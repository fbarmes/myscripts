#!/usr/bin/env bash


#-------------------------------------------------------------------------------
function get_version() {
  local -r input=${1}
  local regex=""
  replace='\2'

  if [[  ${input} =~ '-SNAPSHOT' ]] ; then
    regex='(.*)-(.*-SNAPSHOT)\.(.*)'
  else
    regex='(.*)-(.*)\.(.*)'
  fi

  echo ${input} | sed  -E "s|${regex}|${replace}|"

}

#-------------------------------------------------------------------------------
function main() {

  echo "Start main"

  input="one-two-thr.ee-1.0.2-SNAPSHOT.tgz"
  echo "-- ${input}"
  version=$(get_version ${input})
  echo "${version}"

  input="one-two-thr.ee-1.0.2.tgz"
  echo "-- ${input}"
  version=$(get_version ${input})
  echo "${version}"

  input="one-two-three-1.0.2_HF05-SNAPSHOT.tgz"
  echo "-- ${input}"
  version=$(get_version ${input})
  echo "${version}"


}


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
main $@
