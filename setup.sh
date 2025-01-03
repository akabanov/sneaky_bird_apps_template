#!/bin/bash

TEMPLATE_DOMAIN="example.com"
TEMPLATE_DOMAIN_REVERSED="com.example"
TEMPLATE_NAME_SNAKE="flutter_app_template"
TEMPLATE_NAME_KEBAB="flutter-app-template"
TEMPLATE_NAME_CAMEL="flutterAppTemplate"
GCLOUD_PROJECT_ID_PLACEHOLDER="gcloud-project-id-placeholder"

GIT_USER=$(gh api user --jq '.login')
FALLBACK_DOMAIN=$([ "$GIT_USER" == "akabanov" ] && echo "sneakybird.app" || echo "example.com")

echo
echo "Checking for required tools"
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
rm -rf .idea .git .env

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
echo "APP_NAME_DISPLAY=${APP_NAME_DISPLAY}" >> .env

# Project name (camelCased): Apple bundle name
APP_NAME_CAMEL=$(echo "$APP_NAME_SNAKE" | awk -F_ '{for(i=1;i<=NF;i++) printf "%s%s", (i==1?tolower($i):toupper(substr($i,1,1)) tolower(substr($i,2))), ""}')
echo "APP_NAME_CAMEL=${APP_NAME_CAMEL}" >> .env

# iOS app bundle name
APP_BUNDLE_ID="${APP_DOMAIN}.${APP_NAME_CAMEL}"
echo "APP_BUNDLE_ID=${APP_BUNDLE_ID}" >> .env

# Project name (kebab-cased): Google Cloud project, slack channels
APP_NAME_KEBAB="${APP_NAME_SNAKE//_/-}"
echo "APP_NAME_KEBAB=${APP_NAME_KEBAB}" >> .env

GCLOUD_PROJECT_ID="${APP_NAME_KEBAB}-${APP_TIMESTAMP}"
echo "GCLOUD_PROJECT_ID=${GCLOUD_PROJECT_ID}" >> .env

read -r -p "Setup Google Cloud integration? (Y/n) " YN
if [[ ! "$YN" =~ ^[nN] ]]; then
  source ./setup-gcloud.sh
fi

echo
echo "Replacing template names with the real ones"
find . -type f -not -path '*/.git/*' -exec sed -i "s/${TEMPLATE_DOMAIN}/${APP_DOMAIN}/g" {} +
find . -type f -not -path '*/.git/*' -exec sed -i "s/${TEMPLATE_DOMAIN_REVERSED}/${APP_DOMAIN_REVERSED}/g" {} +
find . -type f -not -path '*/.git/*' -exec sed -i "s/${TEMPLATE_NAME_SNAKE}/${APP_NAME_SNAKE}/g" {} +
find . -type f -not -path '*/.git/*' -exec sed -i "s/${TEMPLATE_NAME_KEBAB}/${APP_NAME_KEBAB}/g" {} +
find . -type f -not -path '*/.git/*' -exec sed -i "s/${TEMPLATE_NAME_CAMEL}/${APP_NAME_CAMEL}/g" {} +
find . -type f -not -path '*/.git/*' -exec sed -i "s/${GCLOUD_PROJECT_ID_PLACEHOLDER}/${GCLOUD_PROJECT_ID}/g" {} +
echo "Done"

echo
echo "Renaming files and directories from ${TEMPLATE_NAME_SNAKE} to ${APP_NAME_SNAKE}"
find . -depth -name "*${TEMPLATE_NAME_SNAKE}*" -not -path '*/.git/*' -execdir bash -c 'mv "$1" "${1//'"${TEMPLATE_NAME_SNAKE}"'/'"${APP_NAME_SNAKE}"'}"' _ {} \;
echo "Done"

echo
echo "Renaming Java packages for Android"
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
echo "Done"

echo
echo "Adding basic Flutter dependencies"
flutter pub add json_annotation dev:json_serializable go_router dev:mocktail dev:golden_screenshot >> /dev/null
echo "Done"

read -r -p "Setup Shorebird integration? (Y/n) " YN
if [[ ! "$YN" =~ ^[nN] ]]; then
  source ./setup-shorebird.sh
fi

echo
echo "Creating git repository"
GIT_REPO_URL="https://github.com/${GIT_USER}/${APP_NAME_SNAKE}.git"
echo "GIT_REPO_URL=${GIT_REPO_URL}" >> .env

echo "Repo URL: ${GIT_REPO_URL}"
gh auth status 2>/dev/null || gh auth login
gh repo create "$APP_NAME_SNAKE" --private --confirm
git init -b main
git add -A .
git commit -m "Initial commit"
git remote add origin "$GIT_REPO_URL"
git push -u origin main
echo "Done"

read -r -p "Setup App Store Connect integration? (Y/n) " YN
if [[ ! "$YN" =~ ^[nN] ]]; then
  source ./setup-app-store.sh
fi

read -r -p "Setup Codemagic integration? (Y/n) " YN
if [[ ! "$YN" =~ ^[nN] ]]; then
  source ./setup-codemagic.sh
fi
