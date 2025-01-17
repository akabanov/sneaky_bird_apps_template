#!/bin/bash

. .env

SENTRY_DSN_PLACEHOLDER="https://b9a42aa537322cbb63a439333ff8ec89@o4508584308178944.ingest.us.sentry.io/""4508592658841600"

# TBD: https://github.com/getsentry/sentry-fastlane-plugin

setup_sentry() {
  local sentryOrg
  read -r -p "Sentry organisation [${SENTRY_ORG}]: " sentryOrg
  : "${sentryOrg:=$SENTRY_ORG}"
  echo "SENTRY_ORG_NAME=${sentryOrg}" >> .env

  local sentryTeam
  read -r -p "Sentry team [${SENTRY_TEAM}]: " sentryTeam
  : "${sentryTeam:=$SENTRY_TEAM}"

  echo "Sentry project: ${APP_ID_SLUG}"
  echo "SENTRY_PROJECT_NAME=${APP_ID_SLUG}" >> .env

  # Ensure we have a project
  local httpCode
  httpCode=$(curl "https://sentry.io/api/0/projects/${sentryOrg}/${APP_ID_SLUG}/" \
    -H "Authorization: Bearer $(cat "$SENTRY_PROJECTS_ADMIN_TOKEN_PATH")" \
    -s -o /dev/null -w "%{http_code}")
  echo "Project lookup HTTP code: ${httpCode}"

  if [[ "$httpCode" -ne 200 ]]; then
    httpCode=$(curl "https://sentry.io/api/0/teams/${sentryOrg}/${sentryTeam}/projects/" \
      -H "Authorization: Bearer $(cat "$SENTRY_PROJECTS_ADMIN_TOKEN_PATH")" \
      -H "Content-Type: application/json" \
      -w "%{http_code}" \
      -s -o /dev/null \
      -d '{
        "name": "'"$APP_NAME_DISPLAY"'",
        "slug": "'"$APP_ID_SLUG"'",
        "platform": "flutter"
      }')
    if [[ "$httpCode" -ne 201 ]]; then
      echo "Failed to add project: ${httpCode}"
      return
    fi
  fi

  # Retrieve/create a DSN
  local key
  local keys
  keys=$(curl "https://sentry.io/api/0/projects/${sentryOrg}/${APP_ID_SLUG}/keys/?status=active" \
    -H "Authorization: Bearer $(cat "$SENTRY_PROJECTS_ADMIN_TOKEN_PATH")" -s)
  if [[ "$(echo "$keys" | jq -r 'type')" == 'object' || "$(echo "$keys" | jq -r 'length')" -eq 0 ]]; then
    key=$(curl "https://sentry.io/api/0/projects/${sentryOrg}/${APP_ID_SLUG}/keys/" \
      -H "Authorization: Bearer $(cat "$SENTRY_PROJECTS_ADMIN_TOKEN_PATH")" \
      -H 'Content-Type: application/json' \
      -s -d '{
        "rateLimit": {
            "window": 7200,
            "count": 1000
        }
      }')
  else
    key=$(echo "$keys" | jq -r '.[0]')
  fi

  dsn=$(echo "$key" | jq -r '.dsn.public')
  echo "Sentry DSN: ${dsn}"
  find . -type f -not -path '*/.git/*' -exec sed -i "s#${SENTRY_DSN_PLACEHOLDER}#${dsn}#g" {} +

  flutter pub add sentry_flutter >> /dev/null
  cp -f 'lib/main.dart.sentry' 'lib/main.dart'
}

setup_sentry
