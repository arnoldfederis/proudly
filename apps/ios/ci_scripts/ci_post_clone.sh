#!/bin/sh
set -e

SECRETS_PATH="$CI_PRIMARY_REPOSITORY_PATH/apps/ios/Proudly/Configurations/Secrets.xcconfig"

if [ -n "$REVENUECAT_API_KEY" ]; then
  echo "REVENUECAT_API_KEY = $REVENUECAT_API_KEY" > "$SECRETS_PATH"
  echo "Wrote Secrets.xcconfig from env."
else
  echo "REVENUECAT_API_KEY env var not set — using default from RevenueCat.xcconfig."
fi
