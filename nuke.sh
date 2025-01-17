#!/bin/bash

. .env

read -r -p "Delete Codemagic application '${APP_NAME_SNAKE}'? (y/N) " YN
if [[ "$YN" =~ ^[yY] ]]; then
#    -H "Content-Type: application/json" \
  curl  "https://api.codemagic.io/apps/${CODEMAGIC_APP_ID}" \
    -H "x-auth-token: $(cat "$CM_API_TOKEN_PATH")" \
    -X DELETE
  echo
fi

read -r -p "Delete GCloud project '${APP_ID_SLUG}'? (y/N) " YN
if [[ "$YN" =~ ^[yY] ]]; then
  gcloud projects delete "$APP_ID_SLUG" --quiet
fi

read -r -p "Delete Sentry project '${APP_ID_SLUG}'? (y/N) " YN
if [[ "$YN" =~ ^[yY] ]]; then
  curl "https://sentry.io/api/0/projects/${SENTRY_ORG_NAME}/${APP_ID_SLUG}/" \
   -H "Authorization: Bearer $(cat "$SENTRY_PROJECTS_ADMIN_TOKEN_PATH")" \
   -X DELETE
   echo
fi

read -r -p "Delete Shorebird project? (y/N) " YN
if [[ "$YN" =~ ^[yY] ]]; then
  echo "You need to do this manually at https://console.shorebird.dev/"
  xdg-open 'https://console.shorebird.dev/' >> /dev/null
fi
