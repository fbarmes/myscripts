#!/usr/bin/env bash
#
# distribute-ssh-keys
#
# This script distribute a given ssh key to a list of hosts in a file
#
# Example usages
#
# * Distribute ssh key to several hosts
#     distribute-ssh-keys my-key.pub  username  host1 host2 host3
#
# * Distribute ssh key to a list of hosts from a file
#     distribute-ssh-keys my-key.pub  username  hostfile.txt
#
#
#-------------------------------------------------------------------------------
# global setup
#-------------------------------------------------------------------------------

#-- SCRIPT_NAME: name of this file
declare -r SCRIPT_NAME=$(basename $(readlink -f $0));

#-- INSTALL_DIR: absolute path to this script
declare -r INSTALL_DIR=$( cd "$( dirname "${0}" )" && pwd )

#-------------------------------------------------------------------------------
# global vars
#-------------------------------------------------------------------------------
declare VERBOSE=false
declare DRY_RUN=false

declare ACCEPT_HOST_KEY=false
declare SSH_PUBLIC_KEY_FILE=""
declare SSH_REMOTE_USER=""
declare SSH_REMOTE_PASSWORD=""
declare SSH_REMOTE_HOST_ARG="";

declare SSH_REMOTE_HOSTS=""
declare PROMPT_FOR_PASSWORD="false"

#-------------------------------------------------------------------------------
# usage function
#-------------------------------------------------------------------------------
usage() {
  cat <<END_HELP

Usage:
  ${SCRIPT_NAME} <key> <remote_user> <host1> <host2> ...
  ${SCRIPT_NAME} <key> <remote_user> <inventory file>

Available options:
    -h, --help            : display this help and exit
    -v, --verbose         : verbose output
    -a,--accept-host-key  : always accept host key
    -p, --prompt-password : prompt for password and reuse for every host

END_HELP
}

#-------------------------------------------------------------------------------
# handle command line options
#-------------------------------------------------------------------------------
get_options() {
  readonly OPTS_SHORT="d,h,v,a,p"
  readonly OPTS_LONG="dry-run,help,verbose,accept-host-key,prompt-password"
  GETOPT_RESULT=`getopt -o ${OPTS_SHORT} --long ${OPTS_LONG} -- $@`
  GETOPT_SUCCESS=$?
  NARGS=3

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
        -a|--accept-host-key) ACCEPT_HOST_KEY=true; shift; ;;
        -p|--prompt-password)  PROMPT_FOR_PASSWORD=true; shift; ;;
        --) shift; break; ;;
        *) echo "Invalid option $1"; exit 1; ;;
    esac
  done

  #-- check non-options parameters
  if [[ ${#} < ${NARGS} ]] ; then
    usage;
    exit 1
  fi


  #-- command list
  SSH_PUBLIC_KEY_FILE=$1; shift;
  SSH_REMOTE_USER=$1; shift
  SSH_REMOTE_HOST_ARG=$@;

  #-- handle host arguments
  SSH_REMOTE_HOSTS=$(extract_hosts ${SSH_REMOTE_HOST_ARG})

}

#-------------------------------------------------------------------------------
function extract_hosts() {
  # SSH_REMOTE_HOST_ARG
  local -r host_arg=${@}
  local is_host_list="false"
  local is_host_file="false"
  local host_list

  if [ ${#} -eq 1 ] && [ -f ${host_arg} ] ; then
    host_list=$(parse_host_file ${host_arg})
  else
    host_list="${host_arg}"
  fi

  echo $(remove_duplicate ${host_list})
}

#-------------------------------------------------------------------------------
# trim "<string>"
# remove leading and trailing spaces from string
#-------------------------------------------------------------------------------
function trim() {
  local input="${1}"
  local output=$(echo "${input// /}")
  echo "${output}"
}


#-------------------------------------------------------------------------------
# parse_host_file <file>
#
# read file line by line and retrieve a list of files
#
#-------------------------------------------------------------------------------
function parse_host_file() {
  declare -r input_file=${1}
  local result=""

  while IFS= read -r line ; do

    # ignore comments
    [[ ${line} =~ ^#.*  ]] && continue;

    # remove lead and trailing whitespaces from line
    line=$(trim "${line}")

    # ignore empty lines
    [[ -z ${line}   ]] && continue;

    # ignore group declaration
    [[ ${line} =~ ^\[.*\]  ]] && continue;

    result="${result} ${line}"
  done < "${input_file}"

  # remove any duplicates
  # result=$(echo $result | tr " " "\n" | sort -u | tr "\n" " ")

  echo ${result}
}

#-------------------------------------------------------------------------------
# remove_duplicate
# remove duplicate strings from input
#-------------------------------------------------------------------------------
function remove_duplicate() {
  local input=${@}
  result=$(echo $input | tr " " "\n" | sort -u | tr "\n" " ")
  echo ${result}
}


#-------------------------------------------------------------------------------
echo_vars() {
  echo "INSTALL_DIR=${INSTALL_DIR}"
  echo "SCRIPT_NAME=${SCRIPT_NAME}"
  echo "---------------------"
  echo "VERBOSE=${VERBOSE}"
  echo "DRY_RUN=${DRY_RUN}"
  echo "---------------------"
  echo "ACCEPT_HOST_KEY=${ACCEPT_HOST_KEY}"
  echo "SSH_PUBLIC_KEY_FILE=${SSH_PUBLIC_KEY_FILE}"
  echo "SSH_REMOTE_USER=${SSH_REMOTE_USER}"
  echo "SSH_REMOTE_HOST_ARG=${SSH_REMOTE_HOST_ARG}"
  echo "SSH_REMOTE_HOSTS=${SSH_REMOTE_HOSTS}"
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
check_ssh_key_file() {
  local readonly key_file=$1

  #-- check that the key file exists
  echov "Check ${key_file} exists"
  if [ ! -f  ${key_file} ]; then
    echo "ERROR : ${key_file} does not exist"
    exit 1
  fi

  #-- check that the key file is an ssh public key
  echov "check ${key_file} is a ssh public key"
  readonly is_public_key=$(grep '^ssh-rsa' ${key_file} | wc -l)
  if [ ! ${is_public_key} = 1 ]; then
    echo "ERROR: ${key_file} is not an ssh public key file"
    exit 1
  fi

}

#-------------------------------------------------------------------------------
check_remote_host_reachable() {
  local readonly remote_host=$1
  local remote_ip="";

  if [[ ${DRY_RUN} = "true" ]] ; then
    echo "DRY RUN: skip check_remote_host_reachable"
    return 0
  fi

  if [[ ${remote_host} =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$  ]]; then
    #-- remote host is an ip
    echov "${remote_host} is an IP"
    remote_ip=${remote_host}
  else
    # remote host is not an IP
    # check the hosts resolves
    if [ $(dig +short ${remote_host} | wc -l) = 0 ]; then
      echo "ERROR: ${remote_host} does not resolve to an IP address"
      return 1
    fi

    # remote hosts resolves, get first ip adress
    remote_ip=$(dig +short  ${remote_host} | grep '^[.0-9]*$')
  fi

  echov "remote_host=${remote_host}, remote_ip=${remote_ip}"
  return 0
}

#-------------------------------------------------------------------------------
# prompt for password
#-------------------------------------------------------------------------------
read-password() {
  read -s -p "Enter password for user [${SSH_REMOTE_USER}]: " SSH_REMOTE_PASSWORD
  echo ""
}


#-------------------------------------------------------------------------------
function send_ssh_key() {
  local readonly key=$1
  local readonly user=$2
  local readonly password=${SSH_REMOTE_PASSWORD}
  local readonly host=$3

  echo "send ${key} to ${user}@${host}"

  SSH_OPTS=""
  [ ${ACCEPT_HOST_KEY} = true ] && SSH_OPTS="${SSH_OPTS} -oStrictHostKeyChecking=no"
  SSH_OPTS="${SSH_OPTS} ${user}@${host}"


  local ssh_command="ssh ${SSH_OPTS}"

  if [[ ${password} != ""  ]] ; then
    ssh_command="sshpass -p ${password} ssh ${SSH_OPTS}"
  else
    ssh_command="ssh ${SSH_OPTS}"
  fi

  if [[ ${DRY_RUN} = "true" ]] ; then
    echo "DRY RUN: skip send_ssh_key"
    return 0
  fi


  cat ${key} | ${ssh_command} \
    'mkdir -p ~/.ssh && \
    chmod 700 ~/.ssh && \
    cat >> ~/.ssh/authorized_keys && \
    chmod 644 ~/.ssh/authorized_keys '
}

#-------------------------------------------------------------------------------
# main function
#-------------------------------------------------------------------------------
main() {

  #-- get command line options
  get_options $@



  if [ $VERBOSE = true ] ; then
    echo_vars
  fi

  #-- check key
  check_ssh_key_file ${SSH_PUBLIC_KEY_FILE}

  #-- prompt for password
  if [[ ${PROMPT_FOR_PASSWORD} == "true"  ]] ; then
    read-password
  fi

  #-- start distribution
  for host in ${SSH_REMOTE_HOSTS} ; do
    echo ""
    echo "Distribute ssh key to ${host}"

    #-- check remote host
    check_remote_host_reachable ${host}
    status=$?
    if [[ ${status} -eq 1 ]] ; then
      echo "ERROR: ${host} is not reachable : SKIP"
      continue
    fi

    #-- send key
    send_ssh_key ${SSH_PUBLIC_KEY_FILE} ${SSH_REMOTE_USER} ${host}

  done

  return 0
}


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
main $@
