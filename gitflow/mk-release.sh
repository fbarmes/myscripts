#!/usr/bin/env bash
#
# mk-release.sh
#
# this script creates a new release using git flow
#
#
#

#-------------------------------------------------------------------------------
# global setup
#-------------------------------------------------------------------------------
INSTALL_DIR=$(dirname $(readlink -f $0));
SCRIPT_NAME=$(basename $(readlink -f $0));
WORK_DIR=$(pwd)

#-------------------------------------------------------------------------------
# global vars
#-------------------------------------------------------------------------------
GIT_RELEASE_NAME=""
GIT_CURRENT_VERSION=""
GIT_NEXT_VERSION=""
GIT_REMOTE_NAME="origin"

#-------------------------------------------------------------------------------
# global vars
#-------------------------------------------------------------------------------
VERBOSE=false

#-------------------------------------------------------------------------------
# usage function
#-------------------------------------------------------------------------------
usage() {
  cat <<END_HELP
Usage: ${SCRIPT_NAME} <current version> <next version>

Available options:
    -h, --help            : display this help and exit
    -v, --verbose         : verbose output
    -d, --dry-run         : do not execute script, just displays the commands
    -r, --remote          : name of the remote

END_HELP
}

#-------------------------------------------------------------------------------
# handle command line options
#-------------------------------------------------------------------------------
get_options() {
  readonly OPTS_SHORT="d,h,v,r:"
  readonly OPTS_LONG="help,verbose,dry-run,remote:"
  GETOPT_RESULT=`getopt -o ${OPTS_SHORT} --long ${OPTS_LONG} -- $@`
  GETOPT_SUCCESS=$?
  NARGS=2

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
        -r|--remote)  GIT_REMOTE_NAME=$2;   shift 2; ;;
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
  GIT_CURRENT_VERSION=${1}
  GIT_NEXT_VERSION=${2}

  GIT_RELEASE_NAME="${GIT_CURRENT_VERSION}"
}


#-------------------------------------------------------------------------------
echo_vars() {
  echo "INSTALL_DIR=${INSTALL_DIR}"
  echo "SCRIPT_NAME=${SCRIPT_NAME}"
  echo "---------------------"
  echo "VERBOSE=${VERBOSE}"
  echo "---------------------"
  echo "GIT_RELEASE_NAME=${GIT_RELEASE_NAME}"
  echo "GIT_CURRENT_VERSION=${GIT_CURRENT_VERSION}"
  echo "GIT_NEXT_VERSION=${GIT_NEXT_VERSION}"
  echo "GIT_REMOTE_NAME=${GIT_REMOTE_NAME}"
}


#-------------------------------------------------------------------------------
# check pre requisistes
#-------------------------------------------------------------------------------
check_prerequisites() {

  echo ""
  echo "Checking pre-requisites"

  #-- check if this is a git repo
  echo -n "  This is a git repository: "
  if [ ! -d ${WORK_DIR}/.git ] || [ ! -f ${WORK_DIR}/.git/config ] ; then
    echo "No. Aborting"
    exit 1
  fi
  echo "OK"

  #-- check if this is a gitflow enabled repo
  echo -n "  This is a gitflow repository: "
  if ! $(grep -q 'gitflow' ${WORK_DIR}/.git/config) ; then
    echo "No. Aborting"
    exit 1
  fi
  echo "OK"

  #-- check that current branch is develop
  echo -n "  Current branch is develop: "
  readonly current_branch=$(git rev-parse --abbrev-ref HEAD)
  if [ ${current_branch} != "develop" ] ; then
    echo "No. you must be on branch develop to create a release. Aborting"
    exit 1
  fi
  echo "OK"

  #-- check there are no pending changes
  echo -n "  There are no uncommited changes: "
  readonly pending_changes=$(git status -s | wc -l)
  if [ ${pending_changes} -gt 0 ] ; then
    echo "No. you have ${pending_changes} uncommited changes. Aborting."
    exit 1
  fi
  echo "OK"

  #-- tag does not already exist
  echo -n "  checking tag ${GIT_RELEASE_NAME} not already exist: "
  readonly tag_search_result=$(git tag | grep ${GIT_RELEASE_NAME})
  if git tag | grep -q ${GIT_RELEASE_NAME} ; then
    echo "tag already exists. Aborting."
    exit 1
  fi
  echo "OK"


  #-- TODO : check both develop and master are locally up to date

  echo ""
}

#-------------------------------------------------------------------------------
# make release <version> <next version>
#-------------------------------------------------------------------------------
make_release() {
  HAS_REMOTE=$(! grep  -q '\[remote .*\]' ${WORK_DIR}/.git/config; echo $?)


  echo "Make release : "
  echo "  Release name : ${GIT_RELEASE_NAME}"
  echo "  Current version : ${GIT_CURRENT_VERSION}"
  echo "  Next version : ${GIT_NEXT_VERSION}"

  if [ ${HAS_REMOTE} -eq 1  ] ; then
    echo "  This repository has a remote"
  else
    echo "  This repository has NO remote"
  fi

  while true; do
    read -p "Do you wish to continue [yes/no] ? " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit 1;;
        * ) echo "Please answer yes or no.";;
    esac
  done

  set -x

  #-- prepare
  echo ""
  echo "STEP: prepare"
  git checkout develop
  if [ ${HAS_REMOTE} -eq 1  ] ; then
    git pull ${GIT_REMOTE_NAME} develop
  fi

  #-- start release
  echo ""
  echo "STEP: git flow release start"
  git flow release start ${GIT_RELEASE_NAME}

  #--- finalize release
  echo ""
  echo "STEP: update version in release branch"
  echo ${GIT_CURRENT_VERSION} > VERSION
  git add VERSION
  git commit -m "update version"

  #-- publish and finish release
  if [ ${HAS_REMOTE} -eq 1  ] ; then
    echo ""
    echo "STEP: git flow release publish"
    git flow release publish ${GIT_RELEASE_NAME}
  fi

  #--finish release
  echo ""
  echo "STEP: git flow release finish"
  export GIT_MERGE_AUTOEDIT=no
  git flow release finish -m "release ${GIT_RELEASE_NAME}" ${GIT_RELEASE_NAME}
  unset GIT_MERGE_AUTOEDIT

  #-- remove tag created by release finish, will do mine later
  echo ""
  echo "STEP: remove tag created by gitflow"
  git tag -d ${GIT_RELEASE_NAME}

  #-- push master
  echo ""
  echo "STEP: make tag again from master"
  git checkout master
  if [ ${HAS_REMOTE} -eq 1  ] ; then
    git push ${GIT_REMOTE_NAME} master
  fi

  #-- make tag
  git tag ${GIT_RELEASE_NAME}
  if [ ${HAS_REMOTE} -eq 1  ] ; then
    git push ${GIT_REMOTE_NAME} --tags
  fi

  #-- cleanup
  echo ""
  echo "STEP: cleanup"
  if [ ${HAS_REMOTE} -eq 1  ] ; then
    git push --delete ${GIT_REMOTE_NAME} release/${GIT_RELEASE_NAME}
  fi

  #--- prepare for next development cycle
  echo ""
  echo "STEP: prepare for next cycle"
  git checkout develop
  echo ${GIT_NEXT_VERSION} > VERSION
  git add VERSION && git commit -m "update version"
  if [ ${HAS_REMOTE} -eq 1  ] ; then
    git push ${GIT_REMOTE_NAME} develop
  fi

  set +x
}

#-------------------------------------------------------------------------------
# main function
#-------------------------------------------------------------------------------
main() {
  get_options $@

  if [ $VERBOSE = true ] ; then
    echo_vars
  fi

  check_prerequisites
  make_release

  exit 0
}


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
main $@
