#!/bin/bash

# quote-separated to survive the substitution
TEMPLATE_DOMAIN="example.""com"
TEMPLATE_DOMAIN_REVERSED="com.""example"
TEMPLATE_NAME_SNAKE="sneaky_bird_apps_""template"
TEMPLATE_NAME_CAMEL="sneakyBirdApps""Template"

FLAVORS=("dev" "stg" "prod")

for_each_flavor() {
  local flavor_handler_name=$1
  for FLUTTER_FLAVOR in "${FLAVORS[@]}"; do
    local build_env_file_name=".env.build.$FLUTTER_FLAVOR"
    local runtime_env_file_name=".env.runtime.$FLUTTER_FLAVOR"
    # shellcheck disable=SC1090
    . "$build_env_file_name"
    $flavor_handler_name "$FLUTTER_FLAVOR" "$build_env_file_name" "$runtime_env_file_name"
  done
}
