#!/bin/bash

# Wazuh
WAZUH_PROD_FILE="$1"
echo "ELASTIC_USERNAME=mistborn" > $WAZUH_PROD_FILE
echo "ELASTIC_PASSWORD=$MISTBORN_DEFAULT_PASSWORD" >> $WAZUH_PROD_FILE

echo "ELASTICSEARCH_USERNAME=mistborn" >> $WAZUH_PROD_FILE
echo "ELASTICSEARCH_PASSWORD=$MISTBORN_DEFAULT_PASSWORD" >> $WAZUH_PROD_FILE

# kibana odfe
# kibana-odfe/config/wazuh_app_config.sh
#WAZUH_API_URL="https://wazuh"
#API_PORT="55000"

# kibana-odfe/config/entrypoint.sh:
#ELASTICSEARCH_URL="https://elasticsearch:9200"

chmod 600 $WAZUH_PROD_FILE