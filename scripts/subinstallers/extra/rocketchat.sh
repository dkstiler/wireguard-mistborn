#!/bin/bash

# generate rocketchat .env files
ROCKETCHAT_PROD_FILE="$1"
#ROCKETCHAT_PASSWORD=$(python3 -c "import secrets; import string; print(f''.join([secrets.choice(string.ascii_letters+string.digits) for x in range(32)]))")
ROCKETCHAT_PASSWORD="${MISTBORN_DEFAULT_PASSWORD}"
echo "ROCKETCHAT_USER=bot" > $ROCKETCHAT_PROD_FILE
echo "ROCKETCHAT_ROOM=GENERAL" >> $ROCKETCHAT_PROD_FILE
echo "BOT_NAME=bot" >> $ROCKETCHAT_PROD_FILE
echo "ROCKETCHAT_PASSWORD=$ROCKETCHAT_PASSWORD" >> $ROCKETCHAT_PROD_FILE

# docker environment
echo "MISTBORN_BIND_IP=${MISTBORN_BIND_IP}" >> $ROCKETCHAT_PROD_FILE

chmod 600 $ROCKETCHAT_PROD_FILE