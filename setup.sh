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
echo "Init Google cloud"
GOOGLE_ACCOUNT=$(gcloud config get-value account 2>/dev/null)
if [[ "$GOOGLE_ACCOUNT" == "(unset)" ]] || [[ -z "$GOOGLE_ACCOUNT" ]]; then
    echo "Not logged in. Starting authentication..."
    gcloud auth login
else
    echo "Currently logged in as: $GOOGLE_ACCOUNT"
    read -r -p "Continue with this account? (Y/n) " CONFIRM
    if [[ "$CONFIRM" =~ ^[nN] ]]; then
        echo "Switching accounts..."
        gcloud auth login
    fi
fi
gcloud services enable testing.googleapis.com
gcloud services enable toolresults.googleapis.com
gcloud services enable billingbudgets.googleapis.com
echo "Done"

echo
echo "Create project in Google Cloud"
GCLOUD_PROJECT_NAME="${APP_SNAKE//_/-}"
GCLOUD_PROJECT_ID="${GCLOUD_PROJECT_NAME}-$(LC_ALL=C tr -dc '0-9' </dev/urandom | head -c 6)"
gcloud projects create "${GCLOUD_PROJECT_ID}" --name="${GCLOUD_PROJECT_NAME}"
gcloud config set project "${GCLOUD_PROJECT_NAME}"
echo "Project name: ${GCLOUD_PROJECT_NAME}; project ID: ${GCLOUD_PROJECT_ID}"
echo "Done"

echo
echo "Set up project billing account"
echo "Current accounts (manage at https://console.cloud.google.com/billing):"
gcloud billing accounts list
read -r -p "Enter Google billing account ID () [${GCLOUD_BILLING_ACCOUNT_ID}]: " BILLING_ACCOUNT_ID
BILLING_ACCOUNT_ID=${BILLING_ACCOUNT_ID:-${GCLOUD_BILLING_ACCOUNT_ID}}
if [ -z "$BILLING_ACCOUNT_ID" ]; then
  echo "No billing account provided."
  exit 1
fi
gcloud billing projects link "${GCLOUD_PROJECT_ID}" --billing-account="${GCLOUD_BILLING_ACCOUNT_ID}"
echo "Done"

echo
echo "Configuring Google storage for Firebase Test Lab"
TEST_LAB_BUCKET_NAME="gs://${GCLOUD_PROJECT_ID}-test"
gcloud storage buckets create "${TEST_LAB_BUCKET_NAME}" --location US-WEST1 --public-access-prevention --uniform-bucket-level-access
echo "Done"

echo
echo "Adding permissions for Firebase Test Lab"
GOOGLE_ACCOUNT=$(gcloud config get-value account 2>/dev/null)
gcloud projects add-iam-policy-binding "${GCLOUD_PROJECT_ID}" \
    --member="user:$GOOGLE_ACCOUNT" \
    --role="roles/cloudtestservice.testAdmin"
gcloud projects add-iam-policy-binding "${GCLOUD_PROJECT_ID}" \
    --member="user:$GOOGLE_ACCOUNT" \
    --role="roles/firebase.analyticsViewer"
echo "Done"

echo
echo "Replacing template names with real ones"
find . -type f -not -path '*/.git/*' -exec sed -i "s/${TEMPLATE_SNAKE}/${APP_SNAKE}/g" {} +
find . -type f -not -path '*/.git/*' -exec sed -i "s/${TEMPLATE_CAMEL}/${APP_CAMEL}/g" {} +
find . -type f -not -path '*/.git/*' -exec sed -i "s/example.com/${DOMAIN}/g" {} +
find . -type f -not -path '*/.git/*' -exec sed -i "s/com.example/${DOMAIN_REVERSED}/g" {} +
find . -type f -not -path '*/.git/*' -exec sed -i "s/flutter-app-template-445902/${GCLOUD_PROJECT_ID}/g" {} +
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

echo
echo "Integrating with Shorebird"
shorebird login
flutter build apk
shorebird init
echo

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
