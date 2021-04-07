#!/bin/bash

# generate bitwarden .env files
BITWARDEN_PROD_FILE="$1"
echo "WEBSOCKET_ENABLED=true" > $BITWARDEN_PROD_FILE
echo "SIGNUPS_ALLOWED=true" >> $BITWARDEN_PROD_FILE
chmod 600 $BITWARDEN_PROD_FILE