#!/bin/bash

# Debug
#APP_NAME_DISPLAY="Default 3"
#APP_ID_SLUG="default-3-123456"
. .env

SENTRY_DSN_PLACEHOLDER="sentry-dsn-""placeholder"

setup_sentry() {
  local sentryOrg
  read -r -p "Sentry organisation [${SENTRY_ORG}]: " sentryOrg
  sentryOrg=${sentryOrg:-$SENTRY_ORG}

  local sentryTeam
  read -r -p "Sentry team [${SENTRY_TEAM}]: " sentryTeam
  sentryTeam=${sentryTeam:-$SENTRY_TEAM}

  echo "Sentry project: ${APP_ID_SLUG}"

  # Ensure we have a project
  local httpCode
  httpCode=$(curl "https://sentry.io/api/0/projects/${sentryOrg}/${APP_ID_SLUG}/" \
    -H "Authorization: Bearer $(cat "$SENTRY_API_TOKEN_PATH")" \
    -s -o /dev/null -w "%{http_code}")
  echo "Project lookup HTTP code: ${httpCode}"

  if [[ "$httpCode" -ne 200 ]]; then
    httpCode=$(curl "https://sentry.io/api/0/teams/${sentryOrg}/${sentryTeam}/projects/" \
      -H "Authorization: Bearer $(cat "$SENTRY_API_TOKEN_PATH")" \
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
    -H "Authorization: Bearer $(cat "$SENTRY_API_TOKEN_PATH")" -s)
  if [[ "$(echo "$keys" | jq -r 'type')" == 'object' || "$(echo "$keys" | jq -r 'length')" -eq 0 ]]; then
    key=$(curl "https://sentry.io/api/0/projects/${sentryOrg}/${APP_ID_SLUG}/keys/" \
      -H "Authorization: Bearer $(cat "$SENTRY_API_TOKEN_PATH")" \
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
  cp -f 'lib/main.sentry' 'lib/main.dart'
}

setup_sentry
