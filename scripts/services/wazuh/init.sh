#!/bin/bash

if [[ -f "/opt/mistborn_volumes/extra/wazuh/init/internal_users.yml" ]]; then
    echo "internal_users.yml exists. Proceeding."
    exit 0
fi

mkdir -p /opt/mistborn_volumes/extra/wazuh/init/ >/dev/null 2>&1
chmod -R +x /opt/mistborn_volumes/extra/wazuh/init/
cp /opt/mistborn/scripts/services/wazuh/files/internal_users.yml /opt/mistborn_volumes/extra/wazuh/init/

WAZUH_MISTBORN_HASHED=$(docker run --rm -ti amazon/opendistro-for-elasticsearch:1.12.0 bash /usr/share/elasticsearch/plugins/opendistro_security/tools/hash.sh -p "${MISTBORN_DEFAULT_PASSWORD}")

sed -i "s/__MISTBORN_HASH__/${WAZUH_MISTBORN_HASHED}/" /opt/mistborn_volumes/extra/guacamole/init/initdb.sql