#!/usr/bin/env bash

set -xe

if [[ $# -ne 2 ]] ; then
  echo "Usage: rename-tag <old> <new>"
  exit 1
fi

#
OLD_TAG=${1}
NEW_TAG=${2}


# Create new from old
git tag ${NEW_TAG} ${OLD_TAG}

# Delete old tag locally
git tag -d ${OLD_TAG}

# Push changes on old tag to remote
git push origin :refs/tags/${OLD_TAG}

# Push new tag to remote
git push --tags
