#!/bin/bash

# Wazuh
WAZUH_PROD_FILE="$1"
echo "ELASTIC_USERNAME=mistborn" > $WAZUH_PROD_FILE
echo "ELASTIC_PASSWORD=$MISTBORN_DEFAULT_PASSWORD" >> $WAZUH_PROD_FILE

echo "ELASTICSEARCH_USERNAME=mistborn" >> $WAZUH_PROD_FILE
echo "ELASTICSEARCH_PASSWORD=$MISTBORN_DEFAULT_PASSWORD" >> $WAZUH_PROD_FILE

# kibana odfe
# kibana-odfe/config/wazuh_app_config.sh
# https://wazuh
echo "WAZUH_API_URL=https://10.2.3.1" >> $WAZUH_PROD_FILE
echo "API_PORT=55000" >> $WAZUH_PROD_FILE
echo "API_USERNAME=wazuh-wui" >> $WAZUH_PROD_FILE

API_PASSWORD=$(python3 -c "import secrets; import string; print(f''.join([secrets.choice(string.ascii_letters+string.digits) for x in range(32)]))")
echo "API_PASSWORD=${API_PASSWORD}" >> $WAZUH_PROD_FILE

# kibana-odfe/config/entrypoint.sh:
# https://elasticsearch:9200
echo "ELASTICSEARCH_URL=https://10.2.3.1:9200" >> $WAZUH_PROD_FILE

echo "MISTBORN_DEFAULT_PASSWORD=$MISTBORN_DEFAULT_PASSWORD" >> $WAZUH_PROD_FILE

chmod 600 $WAZUH_PROD_FILE
