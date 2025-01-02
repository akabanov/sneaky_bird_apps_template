#!/bin/bash

TEMPLATE_SNAKE="flutter_app_template"
TEMPLATE_CAMEL="flutterAppTemplate"

GIT_USER=$(gh api user --jq '.login')
FALLBACK_DOMAIN=$([ "$GIT_USER" == "akabanov" ] && echo "sneakybird.app" || echo "example.com")

echo
echo "Checking for required tools"
REQUIRED_TOOLS=("git" "gh" "gcloud" "sed" "flutter" "shorebird" "curl" "bundle")
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

# Project name (camelCased): Apple bundle name
APP_NAME_CAMEL=$(echo "$APP_NAME_SNAKE" | awk -F_ '{for(i=1;i<=NF;i++) printf "%s%s", (i==1?tolower($i):toupper(substr($i,1,1)) tolower(substr($i,2))), ""}')
echo "APP_NAME_CAMEL=${APP_NAME_CAMEL}" >> .env

# iOS app bundle name
APP_BUNDLE_ID="${APP_DOMAIN}.${APP_NAME_CAMEL}"
echo "APP_BUNDLE_ID=${APP_BUNDLE_ID}" >> .env

# Project name (kebab-cased): Google Cloud project, slack channels
APP_NAME_KEBAB="${APP_NAME_SNAKE//_/-}"
echo "APP_NAME_KEBAB=${APP_NAME_KEBAB}" >> .env

GCLOUD_PROJECT_ID="${APP_NAME_KEBAB}-$(LC_ALL=C tr -dc 'a-z0-9' </dev/urandom | head -c 6)"
echo "GCLOUD_PROJECT_ID=${GCLOUD_PROJECT_ID}" >> .env

read -r -p "Setup Google Cloud integration? (Y/n) " YN
if [[ ! "$YN" =~ ^[nN] ]]; then
  source ./setup-gcloud.sh
fi

echo
echo "Replacing template names with real ones"
find . -type f -not -path '*/.git/*' -exec sed -i "s/${TEMPLATE_SNAKE}/${APP_NAME_SNAKE}/g" {} +
find . -type f -not -path '*/.git/*' -exec sed -i "s/${TEMPLATE_CAMEL}/${APP_NAME_CAMEL}/g" {} +
find . -type f -not -path '*/.git/*' -exec sed -i "s/example.com/${APP_DOMAIN}/g" {} +
find . -type f -not -path '*/.git/*' -exec sed -i "s/com.example/${APP_DOMAIN_REVERSED}/g" {} +
find . -type f -not -path '*/.git/*' -exec sed -i "s/flutter-app-template-445902/${GCLOUD_PROJECT_ID}/g" {} +
echo "Done"

echo
echo "Renaming files and directories from ${TEMPLATE_SNAKE} to ${APP_NAME_SNAKE}"
find . -depth -name "*${TEMPLATE_SNAKE}*" -not -path '*/.git/*' -execdir bash -c 'mv "$1" "${1//'"${TEMPLATE_SNAKE}"'/'"${APP_NAME_SNAKE}"'}"' _ {} \;
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
flutter pub add json_annotation dev:json_serializable go_router dev:mocktail dev:golden_screenshot
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
  source ./setup-appstore.sh
fi

read -r -p "Setup Codemagic integration? (Y/n) " YN
if [[ ! "$YN" =~ ^[nN] ]]; then
  source ./setup-codemagic.sh
fi
