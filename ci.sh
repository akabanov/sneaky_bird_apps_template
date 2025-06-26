#!/bin/bash

. setup-common.sh

WORKFLOW_ID="$1"
shift

if [ -z "$WORKFLOW_ID" ]; then
  echo "Usage: ./ci.sh {workflowName} [flavor] [options]"
  echo "             ios-beta|ios-patch {flavor} [quickBuild]"
  echo "             flutter-pub-add {dependencyName}"
  echo "             ios-lane {laneName}"
  if command -v yq >/dev/null 2>&1; then
    echo "Available workflows:"
    yq '.workflows | keys[]' codemagic.yaml
  fi
  exit 1
fi

case "$WORKFLOW_ID" in
  "ios-beta"|"ios-patch")
    if [ -z "$1" ]; then
      echo "Usage: ./ci.sh $WORKFLOW_ID {flavor} [quickBuild]"
      exit 1
    fi
    buildVariables='
      "FLUTTER_FLAVOR": "'"$1"'",
      "QUICK_BUILD": "'"$2"'"
    '
    ;;
    
  "flutter-pub-add")
    if [ -z "$1" ]; then
      echo "Usage: ./ci.sh flutter-pub-add {dependencyName}"
      exit 1
    fi
    buildVariables='
      "FLUTTER_PACKAGE_NAME": "'"$1"'"
    '
    ;;

  "ios-lane")
    if [ -z "$1" ]; then
      echo "Usage: ./ci.sh ios-lane {laneName}"
      exit 1
    fi
    buildVariables='
      "LANE_NAME": "'"$1"'"
    '
    ;;
esac

run_codemagic_build "$WORKFLOW_ID" "$buildVariables"
