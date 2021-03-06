#!/bin/bash

figlet "Mistborn: Container Credentials"

# generate production .env file for Django
mkdir -p ./.envs/.production
chmod 700 ./.envs
DJANGO_PROD_FILE="./.envs/.production/.django"
DJANGO_SECRET_KEY=$(python3 -c "import secrets; import string; print(f''.join([secrets.choice(string.ascii_letters+string.digits) for x in range(50)]))")
#CELERY_FLOWER_PASSWORD=$(python3 -c "import secrets; import string; print(f''.join([secrets.choice(string.ascii_letters+string.digits) for x in range(32)]))")
MISTBORN_DEFAULT_PASSWORD="$1"
echo "DJANGO_SETTINGS_MODULE=config.settings.production" > $DJANGO_PROD_FILE
echo "DJANGO_SECRET_KEY=$DJANGO_SECRET_KEY" >> $DJANGO_PROD_FILE
echo "DJANGO_ADMIN_URL=admin/" >> $DJANGO_PROD_FILE
echo "USE_DOCKER=yes" >> $DJANGO_PROD_FILE
echo "REDIS_URL=redis://redis:6379/0" >> $DJANGO_PROD_FILE
echo "CELERY_FLOWER_USER=prod" >> $DJANGO_PROD_FILE
echo "CELERY_FLOWER_PASSWORD=\"$MISTBORN_DEFAULT_PASSWORD\"" >> $DJANGO_PROD_FILE
echo "MISTBORN_DEFAULT_PASSWORD=\"$MISTBORN_DEFAULT_PASSWORD\"" >> $DJANGO_PROD_FILE
echo "#MAILGUN_API_KEY=" >> $DJANGO_PROD_FILE
echo "#MAILGUN_API_URL=" >> $DJANGO_PROD_FILE
echo "#SENTRY_DNS=" >> $DJANGO_PROD_FILE
echo "MISTBORN_INSTALL_COCKPIT=$MISTBORN_INSTALL_COCKPIT" >> $DJANGO_PROD_FILE
echo "MISTBORN_PORTAL_IP=10.2.3.1" >> $DJANGO_PROD_FILE
echo "MISTBORN_PORTAL_PORT=5000" >> $DJANGO_PROD_FILE
chmod 600 $DJANGO_PROD_FILE

# generate production .env file for postgresql
POSTGRES_PROD_FILE="./.envs/.production/.postgres"
POSTGRES_PASSWORD=$(python3 -c "import secrets; import string; print(f''.join([secrets.choice(string.ascii_letters+string.digits) for x in range(32)]))")
echo "POSTGRES_HOST=postgres" > $POSTGRES_PROD_FILE
echo "POSTGRES_PORT=5432" >> $POSTGRES_PROD_FILE
echo "POSTGRES_DB=mistborn" >> $POSTGRES_PROD_FILE
echo "POSTGRES_USER=prod" >> $POSTGRES_PROD_FILE
echo "POSTGRES_PASSWORD=$POSTGRES_PASSWORD" >> $POSTGRES_PROD_FILE
chmod 600 $POSTGRES_PROD_FILE


# generate production .env file for pihole
PIHOLE_PROD_FILE="./.envs/.production/.pihole"
#WEBPASSWORD=$(python3 -c "import secrets; import string; print(f''.join([secrets.choice(string.ascii_letters+string.digits) for x in range(32)]))")
WEBPASSWORD="$1"
echo "TZ=\"America/New York\"" > $PIHOLE_PROD_FILE
echo "WEBPASSWORD=\"$WEBPASSWORD\"" >> $PIHOLE_PROD_FILE
chmod 600 $PIHOLE_PROD_FILE
