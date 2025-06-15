#!/bin/bash

# Edit the handler() and run the script
# Note that the .env.build* variables are available, but not exported

. .env.build
. setup-common.sh

handler() {
  pushd ios > /dev/null || exit
#  export FLUTTER_FLAVOR=$1
  echo "Hello, $1 flavor!"
  popd > /dev/null || exit
}

for_each_flavor handler
