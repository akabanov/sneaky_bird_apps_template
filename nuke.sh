#!/bin/bash

. .env

### Codemagic

read -r -p "Delete Codemagic application '${APP_NAME_SNAKE}'? (y/N) " YN
if [[ "$YN" =~ ^[yY] ]]; then
  curl \
    -H "Content-Type: application/json" \
    -H "x-auth-token: ${CODEMAGIC_API_TOKEN}" \
    --request DELETE "https://api.codemagic.io/apps/${CODEMAGIC_APP_ID}"
  echo
fi

### App store connect

# TODO

### GCLOUD

# TODO

### Git Hub repo

read -r -p "Delete GitHub repository '${APP_NAME_SNAKE}'? (y/N) " YN && [[ "$YN" =~ ^[yY] ]] && gh repo delete --yes "$APP_NAME_SNAKE"
