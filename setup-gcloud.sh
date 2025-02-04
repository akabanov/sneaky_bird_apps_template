#!/bin/bash

. .env

echo "Choosing an active account"
GOOGLE_ACCOUNT=$(gcloud config get-value account 2>/dev/null)
if [[ "$GOOGLE_ACCOUNT" == "(unset)" ]] || [[ -z "$GOOGLE_ACCOUNT" ]]; then
  echo "Not logged in. Starting authentication..."
  gcloud auth login
else
  echo "Currently logged in as: $GOOGLE_ACCOUNT"
  read -n 1 -r -p "Continue with this account? (Y/n) " YN && [[ "$YN" =~ ^[nN] ]] && gcloud auth login
  echo
fi


gcloud config unset project
echo "Creating Google Cloud project '${APP_LABEL_DASHBOARD}'; project ID: ${APP_ID_SLUG}"
if ! gcloud projects list --format="value(project_id)" | grep -q "${APP_ID_SLUG}"; then
  gcloud projects create "${APP_ID_SLUG}" --name="${APP_LABEL_DASHBOARD}"
else
  echo "Project ${APP_ID_SLUG} already exists"
fi
gcloud config set project "${APP_ID_SLUG}"


echo "Enabling required APIs"
gcloud services enable testing.googleapis.com
gcloud services enable toolresults.googleapis.com
gcloud services enable billingbudgets.googleapis.com


echo "Setting up project billing account: https://console.cloud.google.com/billing"
read -n 1 -r -p "Open billing page? (y/N) " YN && [[ "$YN" =~ ^[yY] ]] && xdg-open 'https://console.cloud.google.com/billing' > /dev/null &
echo
echo "Current accounts:"
gcloud billing accounts list
read -r -p "Enter Google billing account ID [${GCLOUD_BILLING_ACCOUNT_ID}]: " BILLING_ACCOUNT_ID
: "${BILLING_ACCOUNT_ID:=${GCLOUD_BILLING_ACCOUNT_ID}}"
if [ -z "$BILLING_ACCOUNT_ID" ]; then
  echo "No billing account provided."
  exit 1
fi
gcloud billing projects link "${APP_ID_SLUG}" --billing-account="${BILLING_ACCOUNT_ID}"


echo "Creating a bucket for Firebase Test Lab"
TEST_LAB_BUCKET_NAME="gs://${APP_ID_SLUG}-test"
if ! gcloud storage buckets list --filter="name=${TEST_LAB_BUCKET_NAME}" --format="value(name)" | grep -q "${TEST_LAB_BUCKET_NAME}"; then
  gcloud storage buckets create "${TEST_LAB_BUCKET_NAME}" --location US-WEST1 --public-access-prevention --uniform-bucket-level-access
else
  echo "Bucket ${TEST_LAB_BUCKET_NAME} already exists"
fi


echo "Adding permissions for Firebase Test Lab"
GOOGLE_ACCOUNT=$(gcloud config get-value account 2>/dev/null)
gcloud projects add-iam-policy-binding "${APP_ID_SLUG}" \
    --member="user:$GOOGLE_ACCOUNT" \
    --role="roles/cloudtestservice.testAdmin"
gcloud projects add-iam-policy-binding "${APP_ID_SLUG}" \
    --member="user:$GOOGLE_ACCOUNT" \
    --role="roles/firebase.analyticsViewer"
