#!/usr/bin/env bash

#-------------------------------------------------------------------------------
# global setup
#-------------------------------------------------------------------------------
INSTALL_DIR=$(dirname $(readlink -f $0));
SCRIPT_NAME=$(basename $(readlink -f $0));

#-------------------------------------------------------------------------------
# global vars
#-------------------------------------------------------------------------------
VERBOSE=false

ACCEPT_HOST_KEY=false
SSH_PUBLIC_KEY_FILE=""
SSH_REMOTE_USER=""
SSH_REMOTE_HOST=""

#-------------------------------------------------------------------------------
# usage function
#-------------------------------------------------------------------------------
usage() {
  cat <<END_HELP


Usage: ${SCRIPT_NAME} <key> <remote_user> <host>

Available options:
    -h, --help            : display this help and exit
    -v, --verbose         : verbose output
    --accept-host-key     : always accept host key

END_HELP
}

#-------------------------------------------------------------------------------
# handle command line options
#-------------------------------------------------------------------------------
get_options() {
  readonly OPTS_SHORT="h,v"
  readonly OPTS_LONG="help,verbose,accept-host-key"
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
        --accept-host-key) ACCEPT_HOST_KEY=true; shift; ;;
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
  SSH_PUBLIC_KEY_FILE=$1
  SSH_REMOTE_USER=$2
  SSH_REMOTE_HOST=$3

}


#-------------------------------------------------------------------------------
echo_vars() {
  echo "INSTALL_DIR=${INSTALL_DIR}"
  echo "SCRIPT_NAME=${SCRIPT_NAME}"
  echo "---------------------"
  echo "VERBOSE=${VERBOSE}"
  echo "---------------------"
  echo "ACCEPT_HOST_KEY=${ACCEPT_HOST_KEY}"
  echo "SSH_PUBLIC_KEY_FILE=${SSH_PUBLIC_KEY_FILE}"
  echo "SSH_REMOTE_USER=${SSH_REMOTE_USER}"
  echo "SSH_REMOTE_HOST=${SSH_REMOTE_HOST}"
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


  if [[ ${remote_host} =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$  ]]; then
    #-- remote host is an ip
    echov "${remote_host} is an IP"
    remote_ip=${remote_host}
  else
    # remote host is not an IP
    # check the hosts resolves
    if [ $(dig +short ${remote_host} | wc -l) = 0 ]; then
      echo "ERROR: ${remote_host} does not resolve to an IP address"
    fi

    # remote hosts resolves, get first ip adress
    remote_ip=$(dig +short  ${remote_host} | grep '^[.0-9]*$')
  fi

  echov "remote_host=${remote_host}, remote_ip=${remote_ip}"
}

#-------------------------------------------------------------------------------
function send_ssh_key() {
  local readonly key=$1
  local readonly user=$2
  local readonly host=$3

  echo "send ${key} to ${user}@${host}"


  SSH_OPTS=""
  [ ${ACCEPT_HOST_KEY} = true ] && SSH_OPTS="${SSH_OPTS} -oStrictHostKeyChecking=no"

  cat ${key} | ssh ${SSH_OPTS} ${user}@${host} \
    'mkdir -p ~/.ssh && \
    chmod 700 ~/.ssh && \
    cat >> ~/.ssh/authorized_keys && \
    chmod 644 ~/.ssh/authorized_keys '
}

#-------------------------------------------------------------------------------
# main function
#-------------------------------------------------------------------------------
main() {
  get_options $@

  if [ $VERBOSE = true ] ; then
    echo_vars
  fi

  #-- check key
  check_ssh_key_file ${SSH_PUBLIC_KEY_FILE}

  #-- check remote host
  check_remote_host_reachable ${SSH_REMOTE_HOST}

  #-- send key
  send_ssh_key ${SSH_PUBLIC_KEY_FILE} ${SSH_REMOTE_USER} ${SSH_REMOTE_HOST}

  return 0
}


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
main $@
