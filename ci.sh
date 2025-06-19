#!/bin/bash

. setup-common.sh

if [ -z "$FLUTTER_FLAVOR" ]; then
  echo "FLUTTER_FLAVOR is not defined"
  exit 1
fi

WORKFLOW_ID="$1"
if [ -z "$WORKFLOW_ID" ]; then
  echo "Usage: ./ci.sh {workflowId} [{quick_build:true/false|lane}]"
  which yq >/dev/null 2>&1 && yq '.workflows | keys[]' codemagic.yaml
  exit 1
fi

if [ "$WORKFLOW_ID" == "ios-lane" ]; then
  LANE_NAME="$2"
  if [ -z "$LANE_NAME" ]; then
    echo "Lane name is not defined"
    exit 1
  fi
else
  QUICK_BUILD="${2:-false}"
fi

buildVariables='
  "FLUTTER_FLAVOR": "'"$FLUTTER_FLAVOR"'",
  "QUICK_BUILD": "'"$QUICK_BUILD"'",
  "LANE_NAME": "'"$LANE_NAME"'"
'

run_codemagic_build "$WORKFLOW_ID"
