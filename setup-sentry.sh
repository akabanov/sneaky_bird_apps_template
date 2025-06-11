#!/bin/bash

. .env.build

setup_sentry() {
  local sentryOrg
  read -r -p "Sentry organisation [${SENTRY_ORG}]: " sentryOrg
  : "${sentryOrg:=$SENTRY_ORG}"
  echo "SENTRY_ORG=${sentryOrg}" >> .env

  local sentryTeam
  read -r -p "Sentry team [${SENTRY_TEAM}]: " sentryTeam
  : "${sentryTeam:=$SENTRY_TEAM}"

  echo "Sentry project: ${APP_ID_SLUG}"
  echo "SENTRY_PROJECT=${APP_ID_SLUG}" >> .env

  # Ensure we have a project
  local httpCode
  httpCode=$(curl "https://sentry.io/api/0/projects/${sentryOrg}/${APP_ID_SLUG}/" \
    -H "Authorization: Bearer $(cat "$SENTRY_PROJECTS_ADMIN_TOKEN_PATH")" \
    -s -o /dev/null -w "%{http_code}")

  if [[ "$httpCode" -ne 200 ]]; then
    echo "Creating Sentry project ${APP_ID_SLUG}"
    httpCode=$(curl "https://sentry.io/api/0/teams/${sentryOrg}/${sentryTeam}/projects/" \
      -H "Authorization: Bearer $(cat "$SENTRY_PROJECTS_ADMIN_TOKEN_PATH")" \
      -H "Content-Type: application/json" \
      -w "%{http_code}" \
      -s -o /dev/null \
      -d '{
        "name": "'"$APP_LABEL_DASHBOARD"'",
        "slug": "'"$APP_ID_SLUG"'",
        "platform": "flutter"
      }')
    if [[ "$httpCode" -ne 201 ]]; then
      echo "Failed to add project: ${httpCode}"
      return
    fi
  else
    echo "Sentry project ${APP_ID_SLUG} already exists"
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

  echo "SENTRY_DSN=$(echo "$key" | jq -r '.dsn.public')" >> .env

  flutter pub add sentry_flutter >> /dev/null
  flutter pub add dev:sentry_dart_plugin >> /dev/null
  cp -f 'lib/main.dart.sentry' 'lib/main.dart'
}

setup_sentry
