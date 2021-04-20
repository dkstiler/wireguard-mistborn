#!/bin/bash

set -e

if [[ -f "/opt/mistborn_volumes/extra/elasticsearch/init/internal_users.yml" ]]; then
    echo "internal_users.yml exists. Proceeding."
    exit 0
fi

mkdir -p /opt/mistborn_volumes/extra/elasticsearch/init/ >/dev/null 2>&1
chmod -R +x /opt/mistborn_volumes/extra/elasticsearch/init/
cp /opt/mistborn/scripts/services/elasticsearch/files/internal_users.yml /opt/mistborn_volumes/extra/elasticsearch/init/

ELASTICSEARCH_MISTBORN_HASHED=$(docker run --rm amazon/opendistro-for-elasticsearch:1.12.0 bash /usr/share/elasticsearch/plugins/opendistro_security/tools/hash.sh -p ${MISTBORN_DEFAULT_PASSWORD} | tr -d '\n')

sed -i "s|__MISTBORN_HASH__|${ELASTICSEARCH_MISTBORN_HASHED}|" /opt/mistborn_volumes/extra/elasticsearch/init/internal_users.yml
