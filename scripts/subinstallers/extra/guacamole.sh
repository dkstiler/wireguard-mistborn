#!/bin/bash

# Guacamole
GUAC_PROD_FILE="$1"
GUAC_PASSWORD=$(python3 -c "import secrets; import string; print(f''.join([secrets.choice(string.ascii_letters+string.digits) for x in range(32)]))")
echo "POSTGRES_HOST=guac_postgres" > $GUAC_PROD_FILE
echo "POSTGRES_HOSTNAME=guac_postgres" > $GUAC_PROD_FILE
echo "POSTGRES_PORT=5432" >> $GUAC_PROD_FILE
echo "POSTGRES_DB=guacamole_db" >> $GUAC_PROD_FILE
echo "POSTGRES_DATABASE=guacamole_db" >> $GUAC_PROD_FILE
echo "POSTGRES_USER=guac_user" >> $GUAC_PROD_FILE
echo "POSTGRES_PASSWORD=$GUAC_PASSWORD" >> $GUAC_PROD_FILE
echo "MISTBORN_DEFAULT_PASSWORD=\"$MISTBORN_DEFAULT_PASSWORD\"" >> $GUAC_PROD_FILE