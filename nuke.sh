#!/bin/bash

. .env.build
. setup-common.sh

set -e
git pull --rebase > /dev/null


if [[ -n "$CODEMAGIC_APP_ID" ]]; then
  read -n 1 -r -p "Delete Codemagic application '${APP_NAME_SNAKE}'? (y/N) " YN
  echo
  if [[ "$YN" =~ ^[yY] ]]; then
  #    -H "Content-Type: application/json" \
    curl  "https://api.codemagic.io/apps/${CODEMAGIC_APP_ID}" \
      -H "x-auth-token: $(cat "$CM_API_TOKEN_PATH")" \
      -X DELETE
    echo
  fi
else
  echo "No Codemagic app Id found, skipping"
fi

# Google projects are heavy-weight entities, which take weeks to delete.
# You can't re-create a google project with the same name after you've just deleted one.
# The current strategy is to avoid deletion (similar to AppStore apps - you can't truly delete one).
#read -n 1 -r -p "Delete GCloud project '${APP_ID_SLUG}'? (y/N) " YN
#echo
#if [[ "$YN" =~ ^[yY] ]]; then
#  gcloud projects delete "$APP_ID_SLUG" --quiet
#fi

read -n 1 -r -p "Restore domain/app names and template name id? (y/N) " YN
echo
if [[ "$YN" =~ ^[yY] ]]; then
  find . -type f -not -path '*/.git/*' -exec sed -i "s/${APP_DOMAIN}/${TEMPLATE_DOMAIN}/g" {} +
  find . -type f -not -path '*/.git/*' -exec sed -i "s/${APP_DOMAIN_REVERSED}/${TEMPLATE_DOMAIN_REVERSED}/g" {} +
  APP_PKG_PATH="${APP_DOMAIN_REVERSED//./\/}"
  TEMPLATE_PKG_PATH="${TEMPLATE_DOMAIN_REVERSED//./\/}"
  JAVA_PKG_ROOTS=("android/app/src/androidTest/java" "android/app/src/main/kotlin")
  for path in "${JAVA_PKG_ROOTS[@]}"; do
    mkdir -p "${path}/${TEMPLATE_PKG_PATH}"
    mv "${path}/${APP_PKG_PATH}"/* "${path}/${TEMPLATE_PKG_PATH}"
    find "${path}" -type d -empty -delete
  done

  find . -type f -not -path '*/.git/*' -exec sed -i "s/${APP_ID_SLUG}/${TEMPLATE_ID_SLUG}/g" {} +

  find . -type f -not -path '*/.git/*' -exec sed -i "s/${APP_NAME_SNAKE}/${TEMPLATE_NAME_SNAKE}/g" {} +
  find . -type f -not -path '*/.git/*' -exec sed -i "s/${APP_NAME_SLUG}/${TEMPLATE_NAME_SLUG}/g" {} +
  find . -type f -not -path '*/.git/*' -exec sed -i "s/${APP_NAME_CAMEL}/${TEMPLATE_NAME_CAMEL}/g" {} +
  find . -depth -name "*${APP_NAME_SNAKE}*" -not -path '*/.git/*' \
    -execdir bash -c 'mv "$1" "${1//'"${APP_NAME_SNAKE}"'/'"${TEMPLATE_NAME_SNAKE}"'}"' _ {} \;

  git add -A .
  git commit -m 'Restore template names'
fi

if [[ -n "$SENTRY_DSN" ]]; then
  read -n 1 -r -p "Delete Sentry project '${SENTRY_PROJECT}'? (y/N) " YN
  echo
  if [[ "$YN" =~ ^[yY] ]]; then
    curl "https://sentry.io/api/0/projects/${SENTRY_ORG}/${SENTRY_PROJECT}/" \
     -H "Authorization: Bearer $(cat "$SENTRY_PROJECTS_ADMIN_TOKEN_PATH")" \
     -X DELETE
     echo
  fi
  if ! cmp -s lib/main.dart.sentry lib/main.dart; then
    read -n 1 -r -p "Move main.dart back to main.dart.sentry? (y/N) " YN
    echo
    if [[ "$YN" =~ ^[yY] ]]; then
      # Dropping the setup commit will restore the original lib/main.dart,
      # but for that to work, lib/main.dart needs to be reset to the 'original' lib/main.dart.sentry
      cp -f lib/main.dart.sentry lib/main.dart.swap
      cp -f lib/main.dart lib/main.dart.sentry
      mv -f lib/main.dart.swap lib/main.dart
      git add lib/main.dart*
      git commit -m 'Handle main.dart'
    fi
  fi
else
  echo "No Sentry DSN found, skipping"
fi

if [[ -n "$ONESIGNAL_APP_ID" ]]; then
  read -n 1 -r -p "Delete OneSignal project '${SENTRY_PROJECT}'? (y/N) " YN
  echo
  if [[ "$YN" =~ ^[yY] ]]; then
    oneSignalDashboardUrl="https://dashboard.onesignal.com/apps?page=1"
    echo "You need to do this manually at '${oneSignalDashboardUrl}'"
    echo "You may need to deactivate it first."
    xdg-open "$oneSignalDashboardUrl" > /dev/null
  fi
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
else
  echo "No Shorebird integration found, skipping"
fi

read -n 1 -r -p "Delete release tags from git? (y/N) " YN
echo
if [[ "$YN" =~ ^[yY] ]]; then
  git tag -l | grep '+' | xargs -I {} git push origin :refs/tags/{}
  git tag -l | grep '+' | xargs git tag -d
fi
