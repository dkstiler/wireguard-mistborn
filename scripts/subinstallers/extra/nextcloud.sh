#!/bin/bash

# generate nextcloud .env files
NEXTCLOUD_PROD_FILE="$1"
#NEXTCLOUD_PASSWORD=$(python3 -c "import secrets; import string; print(f''.join([secrets.choice(string.ascii_letters+string.digits) for x in range(32)]))")
NEXTCLOUD_PASSWORD="${MISTBORN_DEFAULT_PASSWORD}"
echo "NEXTCLOUD_ADMIN_USER=mistborn" > $NEXTCLOUD_PROD_FILE
echo "NEXTCLOUD_ADMIN_PASSWORD=$NEXTCLOUD_PASSWORD" >> $NEXTCLOUD_PROD_FILE
echo "NEXTCLOUD_TRUSTED_DOMAINS=nextcloud.mistborn" >> $NEXTCLOUD_PROD_FILE
chmod 600 $NEXTCLOUD_PROD_FILE