#!/bin/bash

CODEMAGIC_APPS=$(curl -H "Content-Type: application/json" \
  -H "x-auth-token: ${CODEMAGIC_API_TOKEN}" \
  --request GET https://api.codemagic.io/apps \
  2>>/dev/null)

length=$(echo "$CODEMAGIC_APPS" | jq '.applications | length')
for i in $(seq 0 $((length - 1))); do
  id=$(echo "$CODEMAGIC_APPS" | jq -r ".applications[$i]._id")
  name=$(echo "$CODEMAGIC_APPS" | jq -r ".applications[$i].appName")
  read -r -p "Delete Codemagic application '${name}'? (y/N) " YN
  if [[ "$YN" =~ ^[yY] ]]; then
    echo "Deleting ${name} (${id})"
    curl \
      -H "Content-Type: application/json" \
      -H "x-auth-token: ${CODEMAGIC_API_TOKEN}" \
      --request DELETE "https://api.codemagic.io/apps/${id}"
    echo
  fi
done
