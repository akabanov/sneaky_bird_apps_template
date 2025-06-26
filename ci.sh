#!/bin/bash

. setup-common.sh

WORKFLOW_ID="$1"
shift

if [ -z "$WORKFLOW_ID" ]; then
  echo "Usage: ./ci.sh {workflowName} [flavor] [options]"
  echo "             ios-beta|ios-patch {flavor} [quickBuild]"
  echo "             ios-lane {laneName}"
  if command -v yq >/dev/null 2>&1; then
    echo "Available workflows:"
    yq '.workflows | keys[]' codemagic.yaml
  fi
  exit 1
fi

case "$WORKFLOW_ID" in
  "ios-beta"|"ios-patch")
    # Flavor is required for these workflows
    if [ -z "$1" ]; then
      echo "Usage: ./ci.sh $WORKFLOW_ID {flavor} [quickBuild]"
      exit 1
    fi
    buildVariables='
      "FLUTTER_FLAVOR": "'"$1"'",
      "QUICK_BUILD": "'"$2"'"
    '
    ;;
    
  "ios-lane")
    # Lane name is required
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
