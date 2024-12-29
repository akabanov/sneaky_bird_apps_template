#!/bin/bash

read -r -p "Enter the app domain: " APP_DOMAIN
#APP_DOMAIN=${APP_DOMAIN:-"sneakybird.app"}
read -r -p "Enter the app name [${PWD##*/}]: " APP_NAME
#APP_NAME=${APP_NAME:-"recall_digits"}
APP_NAME=${APP_NAME:-${PWD##*/}}

REVERSE_DOMAIN="$(echo "$APP_DOMAIN" | awk -F. '{for(i=NF;i>0;i--) printf "%s%s", $i, (i>1 ? "." : "")}')"
JAVA_PKG_PATH="${REVERSE_DOMAIN//./\/}"

echo
echo "Renaming files and directories to ${APP_NAME}"
find . -type f -not -path '*/.git/*' -exec sed -i "s/recall_digits/${APP_NAME}/g" {} +
find . -depth -name "*recall_digits*" -not -path '*/.git/*' -execdir bash -c 'mv "$1" "${1//recall_digits/'"${APP_NAME}"'}"' _ {} \;
echo "Done"

echo
echo "Renaming Java packages"
JAVA_PKG_ROOTS=("android/app/src/androidTest/java" "android/app/src/main/kotlin")
for path in "${JAVA_PKG_ROOTS[@]}"; do
# skip on subsequent pass
  if [ -d "${path}" ]; then
    mkdir -p "${path}/${JAVA_PKG_PATH}"
    mv "${path}"/com/example/* "${path}/${JAVA_PKG_PATH}"
    find "${path}" -type d -empty -delete
  fi
done
git add -A .
echo "Done"


#read -pr "Enter Google billing account ID (https://console.cloud.google.com/billing) [${GCLOUD_BILLING_ACCOUNT_ID}]: " BILLING_ACCOUNT_ID
#BILLING_ACCOUNT_ID=${BILLING_ACCOUNT_ID:-${GCLOUD_BILLING_ACCOUNT_ID}}
#flutter-app-template-445902