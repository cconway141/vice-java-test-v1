#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <username>" >&2
  exit 2
fi

USERNAME="$1"
TOKEN_URL="http://localhost:8081/realms/homebuilder/protocol/openid-connect/token"

RESPONSE=$(curl -s -X POST "$TOKEN_URL" \
  -d "grant_type=password" \
  -d "client_id=homebuilder-api" \
  -d "username=$USERNAME" \
  -d "password=password")

if command -v jq >/dev/null 2>&1; then
  echo "$RESPONSE" | jq -r '.access_token'
else
  # Fallback: extract access_token value with sed
  echo "$RESPONSE" | sed -n 's/.*"access_token"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'
fi
