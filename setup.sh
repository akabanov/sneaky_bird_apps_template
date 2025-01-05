#!/bin/bash

TEMPLATE_DOMAIN="example.""com"
TEMPLATE_DOMAIN_REVERSED="com.""example"
TEMPLATE_NAME_SNAKE="flutter_app_""template"
TEMPLATE_NAME_SLUG="flutter-app-""template"
TEMPLATE_NAME_CAMEL="flutterApp""Template"
TEMPLATE_ID_SLUG="project-id-""placeholder"

GIT_USER=$(gh api user --jq '.login')
FALLBACK_DOMAIN=$([ "$GIT_USER" == "akabanov" ] && echo "sneakybird.app" || echo "example.com")

# Checking for required tools
REQUIRED_TOOLS=("git" "gh" "gcloud" "sed" "flutter" "shorebird" "curl" "app-store-connect" "fastlane")
for tool in "${REQUIRED_TOOLS[@]}"; do
  if ! command -v "$tool" &>/dev/null; then
    echo "Error: $tool is not installed."
    return 1
  fi
done
echo "Done"

# Cleanup
flutter clean >> /dev/null
rm -rf LICENSE .idea .git .env

# Used in SKU, Google project suffix, etc
APP_TIMESTAMP=$(date +%Y%d%m%H%M)
echo "APP_TIMESTAMP=${APP_TIMESTAMP}" >> .env

# Domain name
read -r -p "Enter the app domain [${FALLBACK_DOMAIN}]: " APP_DOMAIN
APP_DOMAIN=${APP_DOMAIN:-"${FALLBACK_DOMAIN}"}
echo "APP_DOMAIN=${APP_DOMAIN}" >> .env

APP_DOMAIN_REVERSED="$(echo "$APP_DOMAIN" | awk -F. '{for(i=NF;i>0;i--) printf "%s%s", $i, (i>1 ? "." : "")}')"
echo "APP_DOMAIN_REVERSED=${APP_DOMAIN_REVERSED}" >> .env

# Project name (snake_cased)
read -r -p "Enter the app name [${PWD##*/}]: " APP_NAME_SNAKE
APP_NAME_SNAKE=${APP_NAME_SNAKE:-${PWD##*/}}
echo "APP_NAME_SNAKE=${APP_NAME_SNAKE}" >> .env

APP_NAME_DISPLAY=$(echo "$APP_NAME_SNAKE" | tr '_' ' ' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')
echo 'APP_NAME_DISPLAY="'"${APP_NAME_DISPLAY}"'"' >> .env
echo "# ${APP_NAME_DISPLAY}" > readme.md

# Project name (camelCased): Apple bundle name
APP_NAME_CAMEL=$(echo "$APP_NAME_SNAKE" | awk -F_ '{for(i=1;i<=NF;i++) printf "%s%s", (i==1?tolower($i):toupper(substr($i,1,1)) tolower(substr($i,2))), ""}')
echo "APP_NAME_CAMEL=${APP_NAME_CAMEL}" >> .env

# iOS app bundle name (used in Codemagic)
BUNDLE_ID="${APP_DOMAIN_REVERSED}.${APP_NAME_CAMEL}"
echo "BUNDLE_ID=${BUNDLE_ID}" >> .env

# Project name (kebab-cased): Google Cloud project, slack channels
APP_NAME_SLUG="${APP_NAME_SNAKE//_/-}"
echo "APP_NAME_SLUG=${APP_NAME_SLUG}" >> .env

APP_ID_SLUG="${APP_NAME_SLUG}-${APP_TIMESTAMP}"
echo "APP_ID_SLUG=${APP_ID_SLUG}" >> .env

read -r -p "Setup Google Cloud integration? (Y/n) " YN
if [[ ! "$YN" =~ ^[nN] ]]; then
  source ./setup-gcloud.sh
fi

# Replacing template names with the real ones
find . -type f -not -path '*/.git/*' -exec sed -i "s/${TEMPLATE_DOMAIN}/${APP_DOMAIN}/g" {} +
find . -type f -not -path '*/.git/*' -exec sed -i "s/${TEMPLATE_DOMAIN_REVERSED}/${APP_DOMAIN_REVERSED}/g" {} +
find . -type f -not -path '*/.git/*' -exec sed -i "s/${TEMPLATE_NAME_SNAKE}/${APP_NAME_SNAKE}/g" {} +
find . -type f -not -path '*/.git/*' -exec sed -i "s/${TEMPLATE_NAME_SLUG}/${APP_NAME_SLUG}/g" {} +
find . -type f -not -path '*/.git/*' -exec sed -i "s/${TEMPLATE_NAME_CAMEL}/${APP_NAME_CAMEL}/g" {} +
find . -type f -not -path '*/.git/*' -exec sed -i "s/${TEMPLATE_ID_SLUG}/${APP_ID_SLUG}/g" {} +

# Renaming files and directories from ${TEMPLATE_NAME_SNAKE} to ${APP_NAME_SNAKE}"
find . -depth -name "*${TEMPLATE_NAME_SNAKE}*" -not -path '*/.git/*' \
  -execdir bash -c 'mv "$1" "${1//'"${TEMPLATE_NAME_SNAKE}"'/'"${APP_NAME_SNAKE}"'}"' _ {} \;

# Renaming Java packages for Android
JAVA_PKG_PATH="${APP_DOMAIN_REVERSED//./\/}"
JAVA_PKG_ROOTS=("android/app/src/androidTest/java" "android/app/src/main/kotlin")
for path in "${JAVA_PKG_ROOTS[@]}"; do
# skip on subsequent runs
  if [ -d "${path}" ]; then
    mkdir -p "${path}/${JAVA_PKG_PATH}"
    mv "${path}"/com/example/* "${path}/${JAVA_PKG_PATH}"
    find "${path}" -type d -empty -delete
  fi
done

# Adding basic Flutter dependencies
flutter pub add \
  json_annotation \
  dev:json_serializable \
  go_router \
  dev:mocktail \
  dev:golden_screenshot \
  sentry_flutter \
  >> /dev/null

read -r -p "Setup Shorebird integration? (Y/n) " YN
if [[ ! "$YN" =~ ^[nN] ]]; then
  source ./setup-shorebird.sh
fi

echo "Creating git repository"
GIT_REPO_URL="git@github.com:${GIT_USER}/${APP_NAME_SNAKE}.git"
echo "GIT_REPO_URL=${GIT_REPO_URL}" >> .env
gh auth status > /dev/null || gh auth login
gh repo create "$APP_NAME_SNAKE" --private

read -r -p "Setup App Store Connect integration? (Y/n) " YN
if [[ ! "$YN" =~ ^[nN] ]]; then
  source ./setup-app-store.sh
fi

read -r -p "Setup Codemagic integration? (Y/n) " YN
if [[ ! "$YN" =~ ^[nN] ]]; then
  source ./setup-codemagic.sh
fi

echo "Pushing files to git"
git init -b main
git add --no-verbose -A .
git commit -q -m "Initial commit"
git remote add origin "$GIT_REPO_URL"
git push -u origin main

read -r -p "Start internal test release build for iOS in Codemagic? (Y/n) " YN
if [[ ! "$YN" =~ ^[nN] ]]; then
  buildIdJson=$(curl -H "Content-Type: application/json" \
    -H "x-auth-token: ${CM_API_TOKEN}" \
    -d '{
     "appId": "'"$CODEMAGIC_APP_ID"'",
     "workflowId": "iOS-internal-test-release",
     "branch": "main"
    }' \
    -X POST https://api.codemagic.io/builds)
  echo "Build URL: https://codemagic.io/app/${CODEMAGIC_APP_ID}/build/$(echo "$buildIdJson" | jq -r '.buildId')"
fi
