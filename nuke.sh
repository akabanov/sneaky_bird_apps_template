#!/bin/bash

. .env

set -e
git pull --rebase > /dev/null

read -n 1 -r -p "Delete Codemagic application '${APP_NAME_SNAKE}'? (y/N) " YN
echo
if [[ "$YN" =~ ^[yY] ]]; then
#    -H "Content-Type: application/json" \
  curl  "https://api.codemagic.io/apps/${CODEMAGIC_APP_ID}" \
    -H "x-auth-token: $(cat "$CM_API_TOKEN_PATH")" \
    -X DELETE
  echo
fi

read -n 1 -r -p "Delete GCloud project '${APP_ID_SLUG}'? (y/N) " YN
echo
if [[ "$YN" =~ ^[yY] ]]; then
  gcloud projects delete "$APP_ID_SLUG" --quiet
fi

read -n 1 -r -p "Delete Sentry project '${SENTRY_PROJECT}'? (y/N) " YN
echo
if [[ "$YN" =~ ^[yY] ]]; then
  curl "https://sentry.io/api/0/projects/${SENTRY_ORG}/${SENTRY_PROJECT}/" \
   -H "Authorization: Bearer $(cat "$SENTRY_PROJECTS_ADMIN_TOKEN_PATH")" \
   -X DELETE
   echo
fi

read -n 1 -r -p "Delete Shorebird project? (y/N) " YN
echo
if [[ "$YN" =~ ^[yY] ]]; then
  echo "You need to do this manually at https://console.shorebird.dev/"
  xdg-open 'https://console.shorebird.dev/' > /dev/null
fi

read -n 1 -r -p "Delete release tags from git? (y/N) " YN
echo
if [[ "$YN" =~ ^[yY] ]]; then
  git tag -l | grep '+' | xargs -I {} git push origin :refs/tags/{}
  git tag -l | grep '+' | xargs git tag -d
fi

read -n 1 -r -p "Handle main.dart? (y/N) " YN
echo
if [[ "$YN" =~ ^[yY] ]]; then
  cp -f lib/main.dart lib/main.dart.sentry
  cp -f lib/main.dart.vanilla lib/main.dart
  git add lib/main.dart*
  git commit -m 'Handle main.dart'
  git push
fi


