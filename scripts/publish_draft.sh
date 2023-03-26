#!/bin/bash

# Replace these variables with your own values
OWNER="chaldea-center"
REPO="chaldea"
TOKEN=$GITHUB_TOKEN
# RELEASE_ID=$RELEASE_ID

sleep 5

response=$(curl -Ls -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $TOKEN" -H "X-GitHub-Api-Version: 2022-11-28" "https://api.github.com/repos/$OWNER/$REPO/releases/$RELEASE_ID")

echo "$response"

is_draft=$(echo "$response" | jq '.draft')

if [ "$is_draft" = true ]; then
  response2 = $(curl -L -X PATCH -H "Authorization: Bearer $TOKEN" --data '{"draft":false}' "https://api.github.com/repos/$OWNER/$REPO/releases/$RELEASE_ID")
  echo "Publish draft: $(echo "$response" | jq '.draft')"
else
  echo "Already published"
fi
