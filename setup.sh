#!/bin/bash

TEMPLATE_PROJECT_NAME="flutter_app_template"
TEMPLATE_PROJECT_BUNDLE="flutterAppTemplate"

read -r -p "Enter the app domain: " APP_DOMAIN
APP_DOMAIN=${APP_DOMAIN:-"sneakybird.app"}

read -r -p "Enter the app name [${TEMPLATE_PROJECT_NAME}]: " APP_NAME
#APP_NAME=${APP_NAME:-"recall_digits"}
APP_NAME=${APP_NAME:-${PWD##*/}}
APP_BUNDLE=$(echo "$APP_NAME" | awk -F_ '{for(i=1;i<=NF;i++) printf "%s%s", (i==1?tolower($i):toupper(substr($i,1,1)) tolower(substr($i,2))), ""}')

REVERSE_DOMAIN="$(echo "$APP_DOMAIN" | awk -F. '{for(i=NF;i>0;i--) printf "%s%s", $i, (i>1 ? "." : "")}')"
JAVA_PKG_PATH="${REVERSE_DOMAIN//./\/}"



echo
echo "Renaming files and directories from ${TEMPLATE_PROJECT_NAME} to ${APP_NAME}"
find . -type f -not -path '*/.git/*' -exec sed -i "s/${TEMPLATE_PROJECT_NAME}/${APP_NAME}/g" {} +
find . -type f -not -path '*/.git/*' -exec sed -i "s/${TEMPLATE_PROJECT_BUNDLE}/${APP_BUNDLE}/g" {} +
find . -type f -not -path '*/.git/*' -exec sed -i "s/example.com/${APP_DOMAIN}/g" {} +
find . -type f -not -path '*/.git/*' -exec sed -i "s/com.example/${REVERSE_DOMAIN}/g" {} +
find . -depth -name "*${TEMPLATE_PROJECT_NAME}*" -not -path '*/.git/*' -execdir bash -c 'mv "$1" "${1//'"${TEMPLATE_PROJECT_NAME}"'/'"${APP_NAME}"'}"' _ {} \;
echo "Done"

echo
echo "Renaming Java packages"
JAVA_PKG_ROOTS=("android/app/src/androidTest/java" "android/app/src/main/kotlin")
for path in "${JAVA_PKG_ROOTS[@]}"; do
# skip on subsequent runs
  if [ -d "${path}" ]; then
    mkdir -p "${path}/${JAVA_PKG_PATH}"
    mv "${path}"/com/example/* "${path}/${JAVA_PKG_PATH}"
    find "${path}" -type d -empty -delete
  fi
done
git add -A .
echo "Done"

if [ -d ".idea" ]; then
  echo
  echo "Deleting IDEA project files"
  rm -rf .idea
  echo "Done"
fi

#read -pr "Enter Google billing account ID (https://console.cloud.google.com/billing) [${GCLOUD_BILLING_ACCOUNT_ID}]: " BILLING_ACCOUNT_ID
#BILLING_ACCOUNT_ID=${BILLING_ACCOUNT_ID:-${GCLOUD_BILLING_ACCOUNT_ID}}
#flutter-app-template-445902