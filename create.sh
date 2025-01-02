#!/bin/bash

read -r -p "Enter new project name (must be a valid Dart package name): " NEW_PROJECT_NAME
if [[ ! "$NEW_PROJECT_NAME" =~ ^[a-z][a-z0-9_]*$ ]]; then
  echo "Invalid name: must be lowercase, start with a letter, and contain only letters, numbers, and underscores."
  return
fi

cd "$(dirname "${BASH_SOURCE[0]}")" || return
DIR_NAME=${PWD##*/}
cd ..

if [ -d "$NEW_PROJECT_NAME" ]; then
  read -r -p "${NEW_PROJECT_NAME} directory exists. Nuke and continue? (y/N) " YN
  if [[ "$YN" =~ ^[yY] ]]; then
    pushd "$NEW_PROJECT_NAME" || return
    if [ -f "nuke.sh" ]; then
      . nuke.sh
    fi
    popd || return
    rm -rf "$NEW_PROJECT_NAME"
  else
    return
  fi
fi

cp -r "$DIR_NAME" "$NEW_PROJECT_NAME"
cd "$NEW_PROJECT_NAME" || return
source ./setup.sh
