#!/bin/bash

TEMPLATE_DOMAIN="example.""com"
TEMPLATE_DOMAIN_REVERSED="com.""example"
TEMPLATE_NAME_SNAKE="sneaky_bird_apps_""template"
TEMPLATE_NAME_SLUG="sneaky-bird-apps-""template"
TEMPLATE_NAME_CAMEL="sneakyBirdApps""Template"
TEMPLATE_ID_SLUG="project-id-""placeholder"

GIT_USER=$(gh api user --jq '.login')
FALLBACK_DOMAIN=$([ "$GIT_USER" == "akabanov" ] && echo "sneakybird.app" || echo "$TEMPLATE_DOMAIN")

# Checking for required tools
REQUIRED_TOOLS=("git" "gh" "gcloud" "sed" "flutter" "shorebird" "curl" "app-store-connect" "bundler" "fastlane")
for tool in "${REQUIRED_TOOLS[@]}"; do
  if ! command -v "$tool" &>/dev/null; then
    echo "Error: $tool is not installed."
    exit 1
  fi
done

echo "Cleaning up..."
rm -rf LICENSE .idea .git
flutter clean >> /dev/null
flutter pub upgrade >> /dev/null
echo "Done"

# Used in SKU, Google project suffix, etc
APP_TIMESTAMP=$(date +%Y%d%m%H%M)
echo "APP_TIMESTAMP=${APP_TIMESTAMP}" >> .env

# Domain name
read -r -p "App domain [${FALLBACK_DOMAIN}]: " APP_DOMAIN
: "${APP_DOMAIN:=${FALLBACK_DOMAIN}}"
echo "APP_DOMAIN=${APP_DOMAIN}" >> .env

APP_DOMAIN_REVERSED="$(echo "$APP_DOMAIN" | awk -F. '{for(i=NF;i>0;i--) printf "%s%s", $i, (i>1 ? "." : "")}')"
echo "APP_DOMAIN_REVERSED=${APP_DOMAIN_REVERSED}" >> .env

# Project name (snake_cased)
APP_NAME_SNAKE=${PWD##*/}
echo "APP_NAME_SNAKE=${APP_NAME_SNAKE}" >> .env

APP_NAME_DISPLAY=$(echo "$APP_NAME_SNAKE" | tr '_' ' ' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')
echo "APP_NAME_DISPLAY='${APP_NAME_DISPLAY}'" >> .env
echo "# ${APP_NAME_DISPLAY}" > readme.md

# Project name (camelCased)
APP_NAME_CAMEL=$(echo "$APP_NAME_SNAKE" | awk -F_ '{for(i=1;i<=NF;i++) printf "%s%s", (i==1?tolower($i):toupper(substr($i,1,1)) tolower(substr($i,2))), ""}')
echo "APP_NAME_CAMEL=${APP_NAME_CAMEL}" >> .env

# Project name (kebab-cased): Google Cloud project, slack channels
APP_NAME_SLUG="${APP_NAME_SNAKE//_/-}"
echo "APP_NAME_SLUG=${APP_NAME_SLUG}" >> .env

APP_ID_SLUG="${APP_NAME_SLUG}-${APP_TIMESTAMP}"
echo "APP_ID_SLUG=${APP_ID_SLUG}" >> .env

GIT_REPO_URL="git@github.com:${GIT_USER}/${APP_NAME_SNAKE}.git"
echo "GIT_REPO_URL=${GIT_REPO_URL}" >> .env

FALLBACK_APP_LANGUAGE=$(echo "$LANG" | cut -d. -f1 | tr '_' '-')
read -r -p "Primary language [${FALLBACK_APP_LANGUAGE}]: " PRIMARY_APP_LANGUAGE
: "${PRIMARY_APP_LANGUAGE:=$FALLBACK_APP_LANGUAGE}"
mapfile -t APP_STORE_LANGUAGES < "ios/app-store-languages"
# shellcheck disable=SC2076
if [[ ! " ${APP_STORE_LANGUAGES[*]} " =~ " ${PRIMARY_APP_LANGUAGE} " ]]; then
  echo "'${PRIMARY_APP_LANGUAGE}' is not a valid language option: ${APP_STORE_LANGUAGES[*]}"
  exit 1
fi
echo "PRIMARY_APP_LANGUAGE=${PRIMARY_APP_LANGUAGE}" >> .env

# iOS
BUNDLE_ID="${APP_DOMAIN_REVERSED}.${APP_NAME_CAMEL}"
# shellcheck disable=SC2129
echo "BUNDLE_ID=${BUNDLE_ID}" >> .env
echo "ITUNES_ID=${ITUNES_ID}" >> .env
echo "APP_STORE_COMPANY_NAME='${APP_STORE_COMPANY_NAME}'" >> .env

echo "Updating project files"

# Domain name
if [ "${TEMPLATE_DOMAIN}" != "${APP_DOMAIN}" ]; then
  find . -type f -not -path '*/.git/*' -exec sed -i "s/${TEMPLATE_DOMAIN}/${APP_DOMAIN}/g" {} +
  find . -type f -not -path '*/.git/*' -exec sed -i "s/${TEMPLATE_DOMAIN_REVERSED}/${APP_DOMAIN_REVERSED}/g" {} +
  JAVA_PKG_PATH="${APP_DOMAIN_REVERSED//./\/}"
  JAVA_PKG_ROOTS=("android/app/src/androidTest/java" "android/app/src/main/kotlin")
  for path in "${JAVA_PKG_ROOTS[@]}"; do
    mkdir -p "${path}/${JAVA_PKG_PATH}"
    mv "${path}"/com/example/* "${path}/${JAVA_PKG_PATH}"
    find "${path}" -type d -empty -delete
  done
fi

find . -type f -not -path '*/.git/*' -exec sed -i "s/${TEMPLATE_ID_SLUG}/${APP_ID_SLUG}/g" {} +

# App name
if [ "${TEMPLATE_NAME_SNAKE}" != "${APP_NAME_SNAKE}" ]; then
  find . -type f -not -path '*/.git/*' -exec sed -i "s/${TEMPLATE_NAME_SNAKE}/${APP_NAME_SNAKE}/g" {} +
  find . -type f -not -path '*/.git/*' -exec sed -i "s/${TEMPLATE_NAME_SLUG}/${APP_NAME_SLUG}/g" {} +
  find . -type f -not -path '*/.git/*' -exec sed -i "s/${TEMPLATE_NAME_CAMEL}/${APP_NAME_CAMEL}/g" {} +
  find . -depth -name "*${TEMPLATE_NAME_SNAKE}*" -not -path '*/.git/*' \
    -execdir bash -c 'mv "$1" "${1//'"${TEMPLATE_NAME_SNAKE}"'/'"${APP_NAME_SNAKE}"'}"' _ {} \;
fi

read -r -p "Setup Google Cloud integration? (Y/n) " YN
if [[ ! "$YN" =~ ^[nN] ]]; then
  source ./setup-gcloud.sh
fi

read -r -p "Setup Shorebird integration? (Y/n) " YN
if [[ ! "$YN" =~ ^[nN] ]]; then
  source ./setup-shorebird.sh
fi

read -r -p "Setup Sentry integration? (Y/n) " YN
if [[ ! "$YN" =~ ^[nN] ]]; then
  source ./setup-sentry.sh
fi

read -r -p "Setup Codemagic integration? (Y/n) " YN
if [[ ! "$YN" =~ ^[nN] ]]; then
  source ./setup-codemagic.sh
fi

read -r -p "Setup App Store Connect integration? (Y/n) " YN
if [[ ! "$YN" =~ ^[nN] ]]; then
  cp .env ios
  cp .env android
  source setup-app-store.sh
fi

echo "Create git repository"
gh auth status > /dev/null || gh auth login
gh repo create "$APP_NAME_SNAKE" --private
git init -b main
git add --no-verbose -A .
git commit -q -m "Initial commit"
git remote add origin "$GIT_REPO_URL"
git push -u origin main

read -r -p "Start Codemagic integration smoke tests? (Y/n) " YN
if [[ ! "$YN" =~ ^[nN] ]]; then
  buildIdJson=$(curl "https://api.codemagic.io/builds" \
    -H "Content-Type: application/json" \
    -H "x-auth-token: $(cat "$CM_API_TOKEN_PATH")" \
    -s -d '{
     "appId": "'"$CODEMAGIC_APP_ID"'",
     "workflowId": "ios-internal-test-release",
     "branch": "main"
    }'
  )
  echo "TestFlight Build URL: https://codemagic.io/app/${CODEMAGIC_APP_ID}/build/$(echo "$buildIdJson" | jq -r '.buildId')"
fi
