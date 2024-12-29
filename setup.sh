#!/bin/bash

TEMPLATE_SNAKE="flutter_app_template"
TEMPLATE_CAMEL="flutterAppTemplate"

echo
echo "Checking for required tools"
REQUIRED_TOOLS=("git" "gh" "gcloud" "sed" "flutter" "shorebird" "curl")
for tool in "${REQUIRED_TOOLS[@]}"; do
  if ! command -v "$tool" &>/dev/null; then
    echo "Error: $tool is not installed."
    exit 1
  fi
done
echo "Done"

# Cleanup
flutter clean
rm -rf .idea .git

# Domain name
read -r -p "Enter the app domain: " DOMAIN
DOMAIN=${DOMAIN:-"sneakybird.app"}
DOMAIN_REVERSED="$(echo "$DOMAIN" | awk -F. '{for(i=NF;i>0;i--) printf "%s%s", $i, (i>1 ? "." : "")}')"

# Project name (snake-cased)
read -r -p "Enter the app name [${TEMPLATE_SNAKE}]: " APP_SNAKE
APP_SNAKE=${APP_SNAKE:-${PWD##*/}}

# Project bundle name (camel-cased)
APP_CAMEL=$(echo "$APP_SNAKE" | awk -F_ '{for(i=1;i<=NF;i++) printf "%s%s", (i==1?tolower($i):toupper(substr($i,1,1)) tolower(substr($i,2))), ""}')

echo
echo "Replacing template names with real ones"
find . -type f -not -path '*/.git/*' -exec sed -i "s/${TEMPLATE_SNAKE}/${APP_SNAKE}/g" {} +
find . -type f -not -path '*/.git/*' -exec sed -i "s/${TEMPLATE_CAMEL}/${APP_CAMEL}/g" {} +
find . -type f -not -path '*/.git/*' -exec sed -i "s/example.com/${DOMAIN}/g" {} +
find . -type f -not -path '*/.git/*' -exec sed -i "s/com.example/${DOMAIN_REVERSED}/g" {} +
echo "Done"

echo
echo "Renaming files and directories from ${TEMPLATE_SNAKE} to ${APP_SNAKE}"
find . -depth -name "*${TEMPLATE_SNAKE}*" -not -path '*/.git/*' -execdir bash -c 'mv "$1" "${1//'"${TEMPLATE_SNAKE}"'/'"${APP_SNAKE}"'}"' _ {} \;
echo "Done"

echo
echo "Renaming Java packages for Android"
JAVA_PKG_PATH="${DOMAIN_REVERSED//./\/}"
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


#read -pr "Enter Google billing account ID (https://console.cloud.google.com/billing) [${GCLOUD_BILLING_ACCOUNT_ID}]: " BILLING_ACCOUNT_ID
#BILLING_ACCOUNT_ID=${BILLING_ACCOUNT_ID:-${GCLOUD_BILLING_ACCOUNT_ID}}
#flutter-app-template-445902


echo
echo "Creating git repository"
git init
git add -A .
git commit -m "Initial commit"
git branch -M main
read -r -p "Would you like to create a new GitHub repository? (Y/n): " CREATE_REPO
CREATE_REPO=${CREATE_REPO:-Y}
if [[ "$CREATE_REPO" =~ ^[Yy]$ ]]; then
  gh auth status 2>/dev/null || gh auth login
  gh repo create "$APP_SNAKE" --private --confirm
  git remote add origin "https://github.com/$(gh api user --jq '.login')/$APP_SNAKE.git"
  git push -u origin main
fi
echo "Done"
