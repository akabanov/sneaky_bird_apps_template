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

# Google projects are heavy-weight entities, which take weeks to delete.
# You can't re-create a google project with the same name after you've just deleted one.
# The current strategy is to avoid deletion (similar to AppStore apps - you can't truly delete one).
#read -n 1 -r -p "Delete GCloud project '${APP_ID_SLUG}'? (y/N) " YN
#echo
#if [[ "$YN" =~ ^[yY] ]]; then
#  gcloud projects delete "$APP_ID_SLUG" --quiet
#fi

read -n 1 -r -p "Delete Sentry project '${SENTRY_PROJECT}'? (y/N) " YN
echo
if [[ "$YN" =~ ^[yY] ]]; then
  curl "https://sentry.io/api/0/projects/${SENTRY_ORG}/${SENTRY_PROJECT}/" \
   -H "Authorization: Bearer $(cat "$SENTRY_PROJECTS_ADMIN_TOKEN_PATH")" \
   -X DELETE
   echo
fi

if [ -f shorebird.yaml ]; then
  read -n 1 -r -p "Delete Shorebird project? (y/N) " YN
  echo
  if [[ "$YN" =~ ^[yY] ]]; then
    sbProjId=$(awk '/^app_id:/ {print $2}' shorebird.yaml)
    sbProjUrl="https://console.shorebird.dev/apps/${sbProjId}"
    echo "You need to do this manually at '${sbProjUrl}'"
    xdg-open "$sbProjUrl" > /dev/null
  fi
fi

read -n 1 -r -p "Delete release tags from git? (y/N) " YN
echo
if [[ "$YN" =~ ^[yY] ]]; then
  git tag -l | grep '+' | xargs -I {} git push origin :refs/tags/{}
  git tag -l | grep '+' | xargs git tag -d
fi

if [[ -n "$SENTRY_DSN" ]]; then
  read -n 1 -r -p "Push main.dart back to main.dart.sentry? (y/N) " YN
  echo
  if [[ "$YN" =~ ^[yY] ]]; then
    cp -f lib/main.dart.sentry lib/main.dart.swap
    cp -f lib/main.dart lib/main.dart.sentry
    mv -f lib/main.dart.swap lib/main.dart
    git add lib/main.dart*
    git commit -m 'Handle main.dart'
    git push
  fi
fi
