#!/bin/bash

. .env

echo
echo "Make sure we're logged in"
GOOGLE_ACCOUNT=$(gcloud config get-value account 2>/dev/null)
if [[ "$GOOGLE_ACCOUNT" == "(unset)" ]] || [[ -z "$GOOGLE_ACCOUNT" ]]; then
    echo "Not logged in. Starting authentication..."
    gcloud auth login
else
    echo "Currently logged in as: $GOOGLE_ACCOUNT"
    read -r -p "Continue with this account? (Y/n) " YN && [[ "$YN" =~ ^[nN] ]] && gcloud auth login
fi
echo "Done"

echo
echo "Enable required APIs"
gcloud services enable testing.googleapis.com
gcloud services enable toolresults.googleapis.com
gcloud services enable billingbudgets.googleapis.com
gcloud services enable androidpublisher.googleapis.com
echo "Done"

echo
echo "Create Google Cloud project"
gcloud projects create "${APP_ID_SLUG}" --name="${APP_NAME_DISPLAY}"
gcloud config set project "${APP_NAME_SLUG}"
echo "Project name: ${APP_NAME_SLUG}; project ID: ${APP_ID_SLUG}"
echo "Done"

echo
echo "Set up project billing account: https://console.cloud.google.com/billing"
read -r -p "Open billing page? (y/N) " YN && [[ "$YN" =~ ^[yY] ]] && xdg-open 'https://console.cloud.google.com/billing' >> /dev/null &
echo "Current accounts:"
gcloud billing accounts list
read -r -p "Enter Google billing account ID [${GCLOUD_BILLING_ACCOUNT_ID}]: " BILLING_ACCOUNT_ID
: "${BILLING_ACCOUNT_ID:=${GCLOUD_BILLING_ACCOUNT_ID}}"
if [ -z "$BILLING_ACCOUNT_ID" ]; then
  echo "No billing account provided."
  exit 1
fi
gcloud billing projects link "${APP_ID_SLUG}" --billing-account="${GCLOUD_BILLING_ACCOUNT_ID}"
echo "Done"

echo
echo "Configuring Google storage for Firebase Test Lab"
TEST_LAB_BUCKET_NAME="gs://${APP_ID_SLUG}-test"
gcloud storage buckets create "${TEST_LAB_BUCKET_NAME}" --location US-WEST1 --public-access-prevention --uniform-bucket-level-access
echo "Done"

echo
echo "Adding permissions for Firebase Test Lab"
GOOGLE_ACCOUNT=$(gcloud config get-value account 2>/dev/null)
gcloud projects add-iam-policy-binding "${APP_ID_SLUG}" \
    --member="user:$GOOGLE_ACCOUNT" \
    --role="roles/cloudtestservice.testAdmin"
gcloud projects add-iam-policy-binding "${APP_ID_SLUG}" \
    --member="user:$GOOGLE_ACCOUNT" \
    --role="roles/firebase.analyticsViewer"
echo "Done"
