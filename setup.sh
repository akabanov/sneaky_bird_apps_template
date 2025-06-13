#!/bin/bash

. setup-common.sh

check_prerequisites() {
  local missingTools=()
  local requiredTools=("git" "gh" "gcloud" "sed" "flutter" "shorebird" "curl" "app-store-connect" "bundler" "fastlane")
  for tool in "${requiredTools[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
      missingTools+=("$tool")
    fi
  done

  if [ "${#missingTools[@]}" -ne 0 ]; then
    echo "Error: The following tools are not installed: ${missingTools[*]}"
    exit 1
  fi

  if [[ -n $(git status --porcelain) ]]; then
    echo "There are uncommitted changes in the repository. Please commit or stash them before proceeding."
    exit 1
  fi

  local gitRepoUrl
  gitRepoUrl=$(git config --get remote.origin.url)
  if [[ ! $gitRepoUrl =~ ^git@ ]]; then
    echo "Git origin URL must use the SSH scheme (git@...). Current URL: $gitRepoUrl"
    exit 1
  fi
}

initialise_flutter() {
  echo "Cleaning up..."
  rm LICENSE
  flutter clean > /dev/null
  flutter pub upgrade > /dev/null
  flutter pub get > /dev/null
  echo "Done"
}

initialise_names_and_identifiers() {
  # Project name (snake_case)
  PROJECT_DIR=${PWD##*/}
  if [[ $PROJECT_DIR =~ ^[a-z][a-z0-9_]*$ ]]; then
    read -r -p "App name [${PROJECT_DIR}]: " APP_NAME_SNAKE
    : "${APP_NAME_SNAKE:=${PROJECT_DIR}}"
  fi
  
  # Validate APP_NAME_SNAKE using Dart identifier syntax rules
  while [[ ! $APP_NAME_SNAKE =~ ^[a-z][a-z0-9_]*$ ]]; do
    echo "Error: '$APP_NAME_SNAKE' is not a valid Dart identifier."
    echo "It must start with a lowercase letter, and contain only lowercase letters, digits, and underscores."
    read -r -p "Enter a valid project name (snake_case): " APP_NAME_SNAKE
  done
  
  BASE_PROJECT_LABEL=$(echo "$APP_NAME_SNAKE" | tr '_' ' ' | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')
  sed -i "s/^description:.*$/description: '${BASE_PROJECT_LABEL}'/" pubspec.yaml
  
  if [ "${TEMPLATE_NAME_SNAKE}" == "${APP_NAME_SNAKE}" ]; then
    DEFAULT_APP_SCREEN_LABEL="SBA Template"
  else
    DEFAULT_APP_SCREEN_LABEL="$BASE_PROJECT_LABEL"
  fi
  read -r -p "App screen name (you can change it later) [${DEFAULT_APP_SCREEN_LABEL}]: " APP_SCREEN_LABEL
  : "${APP_SCREEN_LABEL:=${DEFAULT_APP_SCREEN_LABEL}}"
  
  # Project name (camelCased)
  APP_NAME_CAMEL=$(echo "$APP_NAME_SNAKE" | awk -F_ '{for(i=1;i<=NF;i++) printf "%s%s", (i==1?tolower($i):toupper(substr($i,1,1)) tolower(substr($i,2))), ""}')
  
  # Domain name
  GIT_USER=$(gh api user --jq '.login')
  FALLBACK_DOMAIN=$([ "$GIT_USER" == "akabanov" ] && [ "$APP_NAME_SNAKE" != "sneaky_bird_apps_template" ] && echo "sneaky""bird.app" || echo "$TEMPLATE_DOMAIN")
  read -r -p "App domain [${FALLBACK_DOMAIN}]: " APP_DOMAIN
  : "${APP_DOMAIN:=${FALLBACK_DOMAIN}}"
  
  APP_DOMAIN_REVERSED="$(echo "$APP_DOMAIN" | awk -F. '{for(i=NF;i>0;i--) printf "%s%s", $i, (i>1 ? "." : "")}')"

  BASE_BUNDLE_ID="${APP_DOMAIN_REVERSED}.${APP_NAME_CAMEL}"
}

substitute_template_project_names() {
  echo "Updating project files"
  
  # Domain name
  if [ "${TEMPLATE_DOMAIN}" != "${APP_DOMAIN}" ]; then
    find . -type f -not -path '*/.git/*' -exec sed -i "s/${TEMPLATE_DOMAIN}/${APP_DOMAIN}/g" {} +
    find . -type f -not -path '*/.git/*' -exec sed -i "s/${TEMPLATE_DOMAIN_REVERSED}/${APP_DOMAIN_REVERSED}/g" {} +
    APP_PKG_PATH="${APP_DOMAIN_REVERSED//./\/}"
    TEMPLATE_PKG_PATH="${TEMPLATE_DOMAIN_REVERSED//./\/}"
    JAVA_PKG_ROOTS=("android/app/src/androidTest/java" "android/app/src/main/kotlin")
    for path in "${JAVA_PKG_ROOTS[@]}"; do
      mkdir -p "${path}/${APP_PKG_PATH}"
      mv "${path}/${TEMPLATE_PKG_PATH}/"* "${path}/${APP_PKG_PATH}"
      find "${path}" -type d -empty -delete
    done
  fi
  
  # App name
  if [ "${TEMPLATE_NAME_SNAKE}" != "${APP_NAME_SNAKE}" ]; then
    find . -type f -not -path '*/.git/*' -exec sed -i "s/${TEMPLATE_NAME_SNAKE}/${APP_NAME_SNAKE}/g" {} +
    find . -type f -not -path '*/.git/*' -exec sed -i "s/${TEMPLATE_NAME_CAMEL}/${APP_NAME_CAMEL}/g" {} +
    find . -depth -name "*${TEMPLATE_NAME_SNAKE}*" -not -path '*/.git/*' \
      -execdir bash -c 'mv "$1" "${1//'"${TEMPLATE_NAME_SNAKE}"'/'"${APP_NAME_SNAKE}"'}"' _ {} \;
  fi

  # Apple development team (code signing identity)
  find . -type f -not -path '*/.git/*' -exec sed -i "s/${TEMPLATE_APPLE_DEV_TEAM}/${APPLE_DEV_TEAM_ID:-\"\"}/g" {} +
}

create_build_env_files() {
  # Write to .env.build AFTER the names substitution,
  # but BEFORE setting up the integrations
  {
    echo "APP_STORE_COMPANY_NAME='${APP_STORE_COMPANY_NAME}'"
    echo "APP_DOMAIN=${APP_DOMAIN}"
    echo "APP_DOMAIN_REVERSED=${APP_DOMAIN_REVERSED}"
    echo "APP_NAME_SNAKE=${APP_NAME_SNAKE}"
    echo "APP_NAME_CAMEL=${APP_NAME_CAMEL}"
    echo "BASE_BUNDLE_ID=${BASE_BUNDLE_ID}"
    echo "APP_SCREEN_LABEL='${APP_SCREEN_LABEL}'"
    echo "BASE_PROJECT_LABEL='${BASE_PROJECT_LABEL}'"
  } >> .env.build

  for_each_flavor create_flavored_build_env_file
}

create_flavored_build_env_file() {
    PROJECT_LABEL="$(echo "$1" | tr '[:lower:]' '[:upper:]') $BASE_PROJECT_LABEL"
    BUNDLE_ID="$BASE_BUNDLE_ID.$1"
    # 30 characters is the max project ID length in Google Cloud;
    # Also spicing up with full bundle Id hash to make the name (almost) unique
    APP_ID_SLUG="$(echo "$1-${APP_NAME_SNAKE//_/-}" | cut -c-23)-$(echo "$BUNDLE_ID" | md5sum | cut -c1-6)"
    {
      echo "BUNDLE_ID=${BUNDLE_ID}"
      echo "APP_ID_SLUG=${APP_ID_SLUG}"
      echo "PROJECT_LABEL='${PROJECT_LABEL}'"
    } >> "$2"
}

setup_firebase() {
  read -n 1 -r -p "Setup Firebase integration? (Y/n) " YN
  echo
  if [[ "$YN" =~ ^[nN] ]]; then
    return
  fi

  echo "Choosing an active account"
  GOOGLE_ACCOUNT=$(gcloud --quiet config get-value account 2>/dev/null)
  if [[ "$GOOGLE_ACCOUNT" == "(unset)" ]] || [[ -z "$GOOGLE_ACCOUNT" ]]; then
    echo "Not logged in. Starting authentication..."
    gcloud auth login
    GOOGLE_ACCOUNT=$(gcloud --quiet config get-value account 2>/dev/null)
  else
    echo "Currently logged in as: $GOOGLE_ACCOUNT"
    read -n 1 -r -p "Continue with this account? (Y/n) " YN && [[ "$YN" =~ ^[nN] ]] && gcloud auth login
    echo
  fi

  gcloud config unset project

  echo "Choose billing account (https://console.cloud.google.com/billing)"
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

  for_each_flavor setup_firebase_flavor
}

setup_firebase_flavor() {
  echo "Creating Google Cloud project '${PROJECT_LABEL}'; project ID: ${APP_ID_SLUG}"
  if ! gcloud projects list --format="value(project_id)" | grep -q "${APP_ID_SLUG}"; then
    gcloud projects create "${APP_ID_SLUG}" --name="${PROJECT_LABEL}"
  else
    echo "Project ${APP_ID_SLUG} already exists"
  fi
  gcloud config set project "${APP_ID_SLUG}"

  echo "Enabling billing"
  gcloud services enable billingbudgets.googleapis.com
  gcloud billing projects link "${APP_ID_SLUG}" --billing-account="${BILLING_ACCOUNT_ID}"

  echo "Enabling required APIs"
  gcloud services enable testing.googleapis.com
  gcloud services enable toolresults.googleapis.com

  echo "Creating a bucket for Firebase Test Lab results"
  TEST_LAB_BUCKET_NAME="${APP_ID_SLUG}-test"
  echo "TEST_LAB_BUCKET_NAME='${TEST_LAB_BUCKET_NAME}'" >> "$2"
  if ! gcloud storage buckets list --filter="name=${TEST_LAB_BUCKET_NAME}" --format="value(name)" | grep -q "${TEST_LAB_BUCKET_NAME}"; then
    gcloud storage buckets create "gs://${TEST_LAB_BUCKET_NAME}" --location US-WEST1 --public-access-prevention --uniform-bucket-level-access
  else
    echo "Bucket ${TEST_LAB_BUCKET_NAME} already exists"
  fi

  echo "Adding permissions for Firebase Test Lab"
  gcloud projects add-iam-policy-binding "${APP_ID_SLUG}" \
      --member="user:$GOOGLE_ACCOUNT" \
      --role="roles/cloudtestservice.testAdmin"
  gcloud projects add-iam-policy-binding "${APP_ID_SLUG}" \
      --member="user:$GOOGLE_ACCOUNT" \
      --role="roles/firebase.analyticsViewer"

  gcloud config unset project
}

setup_shorebird() {
  if [ -f shorebird.yaml ]; then
    read -n 1 -r -p "Found 'shorebird.yaml'; reuse this configuration? (Y/n)" YN
    echo
    if [[ "$YN" =~ ^[nN] ]]; then
      echo "Backing up existing configuration"
      mv shorebird.yaml shorebird.yaml."$(date +"%Y%m%d%H%M%S")"
    else
      shorebird login
      return
    fi
  fi

  read -n 1 -r -p "Setup Shorebird integration? (Y/n) " YN
  echo
  if [[ "$YN" =~ ^[nN] ]]; then
    return
  fi

  echo
  echo "Integrating with Shorebird"
  shorebird login
  shorebird init --display-name "${BASE_PROJECT_LABEL}"
  echo "Done"
}

setup_sentry() {
  read -n 1 -r -p "Setup Sentry integration? (Y/n) " YN
  echo
  if [[ "$YN" =~ ^[nN] ]]; then
    return
  fi

  read -r -p "Sentry organisation [${SENTRY_ORG}]: " PROJECT_SENTRY_ORG
  : "${PROJECT_SENTRY_ORG:=$SENTRY_ORG}"
  echo "SENTRY_ORG=${PROJECT_SENTRY_ORG}" >> .env.build

  read -r -p "Sentry team [${SENTRY_TEAM}]: " PROJECT_SENTRY_TEAM
  : "${PROJECT_SENTRY_TEAM:=$SENTRY_TEAM}"

  flutter pub add sentry_flutter >> /dev/null
  flutter pub add dev:sentry_dart_plugin >> /dev/null
  cp -f 'lib/main.dart.sentry' 'lib/main.dart'

  for_each_flavor setup_sentry_flavor
}

setup_sentry_flavor() {
  echo "Setting up Sentry project for $1 flavor: ${APP_ID_SLUG}"

  # This variable is used by the Sentry plugin, when uploading build details
  echo "SENTRY_PROJECT='${APP_ID_SLUG}'" >> "$2"

  # Ensure we have a project
  local httpCode
  httpCode=$(curl "https://sentry.io/api/0/projects/${PROJECT_SENTRY_ORG}/${APP_ID_SLUG}/" \
    -H "Authorization: Bearer $(cat "$SENTRY_PROJECTS_ADMIN_TOKEN_PATH")" \
    -s -o /dev/null -w "%{http_code}")

  if [[ "$httpCode" -ne 200 ]]; then
    echo "Creating Sentry project ${APP_ID_SLUG}"
    httpCode=$(curl "https://sentry.io/api/0/teams/${PROJECT_SENTRY_ORG}/${PROJECT_SENTRY_TEAM}/projects/" \
      -H "Authorization: Bearer $(cat "$SENTRY_PROJECTS_ADMIN_TOKEN_PATH")" \
      -H "Content-Type: application/json" \
      -w "%{http_code}" \
      -s -o /dev/null \
      -d '{
        "name": "'"$PROJECT_LABEL"'",
        "slug": "'"$APP_ID_SLUG"'",
        "platform": "flutter"
      }')
    if [[ "$httpCode" -ne 201 ]]; then
      echo "Failed to add project: ${httpCode}"
      echo "Create the project manually and add its SENTRY_DSN to both $2 and $3"
      return
    fi
  else
    echo "Sentry project ${APP_ID_SLUG} already exists"
  fi

  # Retrieve/create a DSN
  local key
  local keys
  keys=$(curl "https://sentry.io/api/0/projects/${PROJECT_SENTRY_ORG}/${APP_ID_SLUG}/keys/?status=active" \
    -H "Authorization: Bearer $(cat "$SENTRY_PROJECTS_ADMIN_TOKEN_PATH")" -s)
  if [[ "$(echo "$keys" | jq -r 'type')" == 'object' || "$(echo "$keys" | jq -r 'length')" -eq 0 ]]; then
    key=$(curl "https://sentry.io/api/0/projects/${PROJECT_SENTRY_ORG}/${APP_ID_SLUG}/keys/" \
      -H "Authorization: Bearer $(cat "$SENTRY_PROJECTS_ADMIN_TOKEN_PATH")" \
      -H 'Content-Type: application/json' \
      -s -d '{
        "rateLimit": {
            "window": 7200,
            "count": 1000
        }
      }')
  else
    key=$(echo "$keys" | jq -r '.[0]')
  fi

  SENTRY_DSN=$(echo "$key" | jq -r '.dsn.public')
  echo "Sentry DSN: $SENTRY_DSN"
  echo "SENTRY_DSN='${SENTRY_DSN}'" >> "$2"
  echo "SENTRY_DSN='${SENTRY_DSN}'" >> "$3"
}

setup_codemagic() {
  read -n 1 -r -p "Setup Codemagic integration? (Y/n) " YN
  echo
  if [[ "$YN" =~ ^[nN] ]]; then
    return
  fi

  echo "Adding Codemagic application: https://codemagic.io/apps"
  CODEMAGIC_RESPONSE=$(curl https://api.codemagic.io/apps \
    -H "Content-Type: application/json" \
    -H "x-auth-token: $(cat "$CM_API_TOKEN_PATH")" \
    -s -d '{
     "repositoryUrl": "'"$(git config --get remote.origin.url)"'",
     "sshKey": {
       "data": "'"$(base64 -w0 < "$CICD_GITHUB_SSH_KEY_PATH")"'",
       "passphrase": ""
     }
    }')

  CODEMAGIC_APP_ID=$(echo "${CODEMAGIC_RESPONSE}" | jq -r '._id')
  echo "Codemagic application ID: ${CODEMAGIC_APP_ID}"
  echo "CODEMAGIC_APP_ID=${CODEMAGIC_APP_ID}" >> .env.build

  echo "Adding secrets to the Codemagic project"

  # Developer ID
  add_codemagic_secret "ITUNES_ID" "$ITUNES_ID"
  add_codemagic_secret "APPLE_DEV_TEAM_ID" "$APPLE_DEV_TEAM_ID"
  add_codemagic_secret "APP_STORE_CONNECT_TEAM_ID" "$APP_STORE_CONNECT_TEAM_ID"

  # App store access
  add_codemagic_secret "APP_STORE_CONNECT_ISSUER_ID" "$APP_STORE_CONNECT_ISSUER_ID"
  add_codemagic_secret "APP_STORE_CONNECT_KEY_IDENTIFIER" "$APP_STORE_CONNECT_KEY_IDENTIFIER"
  add_codemagic_secret "APP_STORE_CONNECT_PRIVATE_KEY" "$(cat "$APP_STORE_CONNECT_PRIVATE_KEY_PATH")"

  # iOS signing certificates management
  add_codemagic_secret "MATCH_GIT_URL" "$MATCH_GIT_URL"
  add_codemagic_secret "MATCH_SSH_KEY" "$(cat "$CICD_GITHUB_SSH_KEY_PATH")"
  add_codemagic_secret "MATCH_PASSWORD" "$(cat "$MATCH_PASSWORD_PATH")"

  # GCloud Service account for automatic Play Console updates
  add_codemagic_secret "SUPPLY_JSON_KEY_DATA" "$(cat "$SUPPLY_JSON_KEY")"

  # Sentry access
  add_codemagic_secret "SENTRY_AUTH_TOKEN" "$(cat "$SENTRY_CI_TOKEN_PATH")"

  # Shorebird access
  add_codemagic_secret "SHOREBIRD_TOKEN" "$(cat "$SHOREBIRD_TOKEN_PATH")"

  # Developer contact details
  add_codemagic_secret "DEV_FIRST_NAME" "$DEV_FIRST_NAME"
  add_codemagic_secret "DEV_LAST_NAME" "$DEV_LAST_NAME"
  add_codemagic_secret "DEV_PHONE" "$DEV_PHONE"
  add_codemagic_secret "DEV_EMAIL" "$DEV_EMAIL"
  add_codemagic_secret "DEV_WEBSITE" "$DEV_WEBSITE"
  add_codemagic_secret "DEV_ADDRESS_LINE_1" "$DEV_ADDRESS_LINE_1"
  add_codemagic_secret "DEV_ADDRESS_LINE_2" "$DEV_ADDRESS_LINE_2"
  add_codemagic_secret "DEV_CITY" "$DEV_CITY"
  add_codemagic_secret "DEV_STATE" "$DEV_STATE"
  add_codemagic_secret "DEV_COUNTRY" "$DEV_COUNTRY"
  add_codemagic_secret "DEV_ZIP" "$DEV_ZIP"
}

add_codemagic_secret() {
  local name="$1"
  local value="$2"

  if [ -z "$value" ]; then
    echo "Error: '$name' environment variable is not set."
    exit 1
  fi

  echo "$name"
  curl "https://api.codemagic.io/apps/${CODEMAGIC_APP_ID}/variables" \
    -H "Content-type: application/json" \
    -H "x-auth-token: $(cat "$CM_API_TOKEN_PATH")" \
    -s -o /dev/null \
    -d '{
     "key": "'"${name}"'",
     "value": '"$(echo -n "$value" | jq -R -s '.')"',
     "group": "secrets",
     "secure": true
    }'
}

setup_onesignal() {
  read -n 1 -r -p "Setup OneSignal integration? (Y/n) " YN
  echo
  if [[ "$YN" =~ ^[nN] ]]; then
    return
  fi

  while [ -z "$ONESIGNAL_ORG_ID" ]; do
    read -r -p "Enter OneSignal organisation ID: " ONESIGNAL_ORG_ID
  done

  ONESIGNAL_APP_LIST_JSON=$(curl -s "https://api.onesignal.com/apps" \
    -H "Authorization: $(cat "$ONESIGNAL_API_KEY_PATH")" \
    -H 'accept: text/plain'
  )

  for_each_flavor setup_onesignal_flavor
}

setup_onesignal_flavor() {
  appJson=$(echo "$ONESIGNAL_APP_LIST_JSON" | jq -r '.[] | select(.name == "'"${PROJECT_LABEL}"'")')
  if [ -z "$appJson" ]; then
    echo "Creating OneSignal app '${PROJECT_LABEL}'"
    appJson=$(curl -s "https://api.onesignal.com/apps" \
      -H "Authorization: $(cat "$ONESIGNAL_API_KEY_PATH")" \
      -H 'Content-Type: application/json' \
      -H 'accept: text/plain' \
      -d '{
        "name": "'"$PROJECT_LABEL"'",
        "organization_id": "'"$ONESIGNAL_ORG_ID"'"
      }'
    )
  else
    echo "OneSignal app '${PROJECT_LABEL}' already exists."
  fi

  ONESIGNAL_APP_ID=$(echo "$appJson" |  jq -r '.id')
  echo "OneSignal app ID: ${ONESIGNAL_APP_ID}"
  echo "ONESIGNAL_APP_ID='${ONESIGNAL_APP_ID}'" >> "$2"
  echo "ONESIGNAL_APP_ID='${ONESIGNAL_APP_ID}'" >> "$3"
}

setup_app_store() {
  read -n 1 -r -p "Setup App Store Connect integration? (Y/n) " YN
  echo
  if [[ "$YN" =~ ^[nN] ]]; then
    return
  fi

  for_each_flavor setup_app_store_flavor
}

setup_app_store_flavor() {
  export FLUTTER_FLAVOR="$1"
  pushd 'ios' > /dev/null || return 1
  until bundle exec fastlane ios init_app; do
    echo "Retrying in 3 seconds "
    sleep 3
  done
  popd > /dev/null || return 1
}

setup_play_store() {
  read -n 1 -r -p "Setup Google Play Console integration? (Y/n) " YN
  echo
  if [[ "$YN" =~ ^[nN] ]]; then
    return
  fi

  # Building app bundle for the initial upload to Play Console
  flutter build appbundle --flavor dev -t lib/main_dev.dart
  echo "Create an app in Google Play Console and upload the '.aab' bundle (Test and release > Internal testing)"
  read -n 1 -s -r -p "Press any key when done..."
  echo
}

commit_and_push() {
  # template debugging
  if [ "$APP_NAME_SNAKE" == "sneaky_bird_apps_template" ]; then
    if ! git show-ref --verify --quiet refs/heads/dev; then
      git checkout -b dev
    else
      git checkout dev
    fi
  fi

  git add -A . > /dev/null
  git commit -q -m "Initial setup"

  REMOTE_BRANCH=$(git rev-parse --abbrev-ref HEAD)
  read -n 1 -r -p "Push initial setup to remote git branch ${REMOTE_BRANCH}? (Y/n) " PUSHED_TO_GIT_REPO
  echo
  if [[ "$PUSHED_TO_GIT_REPO" =~ ^[nN] ]]; then
    return
  fi

  if ! git ls-remote --exit-code --heads origin "$REMOTE_BRANCH"; then
    git push --set-upstream origin "$REMOTE_BRANCH" > /dev/null
  else
    git push > /dev/null
  fi
}

build_ios_dev_on_codemagic() {
  if [[ "$PUSHED_TO_GIT_REPO" =~ ^[nN] ]]; then
    return
  fi

  read -n 1 -r -p "Start Codemagic integration smoke tests? (Y/n) " YN
  echo
  if [[ ! "$YN" =~ ^[nN] ]]; then
    export FLUTTER_FLAVOR=dev
    source ci.sh ios-beta
  fi
}

# execution

#check_prerequisites
initialise_flutter
initialise_names_and_identifiers
substitute_template_project_names
create_build_env_files

setup_firebase

read -n 1 -r -p "Press any key to continue..."
echo

setup_shorebird
read -n 1 -r -p "Press any key to continue..."
echo

setup_sentry
read -n 1 -r -p "Press any key to continue..."
echo

setup_codemagic
read -n 1 -r -p "Press any key to continue..."
echo

setup_onesignal
read -n 1 -r -p "Press any key to continue..."
echo

setup_app_store
read -n 1 -r -p "Press any key to continue..."
echo

setup_play_store
read -n 1 -r -p "Press any key to continue..."
echo


commit_and_push
build_ios_dev_on_codemagic
