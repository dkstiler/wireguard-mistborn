#!/bin/bash

mkdir -p /opt/mistborn_volumes/extra/guacamole/init/ >/dev/null 2>&1
chmod -R +x /opt/mistborn_volumes/extra/guacamole/init/
docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --postgres > /opt/mistborn_volumes/extra/guacamole/init/initdb.sql

# grab values in initdb.sql to replace
HEXSTRINGS=($(egrep -o [0-9a-fA-F]{64} /opt/mistborn_volumes/extra/guacamole/init/initdb.sql))

# reset default password in init.db
SALT=$(python3 -c "import secrets; import string; print(f''.join([secrets.choice('0123456789ABCDEF') for x in range(64)]))")
GUAC_PASSWORD_HASHED=$(echo -n "${MISTBORN_DEFAULT_PASSWORD}${SALT}" | sha256sum | awk '{print $1}' | tr a-z A-Z)

sed -i "s/${HEXSTRINGS[1]}/$SALT/" /opt/mistborn_volumes/extra/guacamole/init/initdb.sql
sed -i "s/${HEXSTRINGS[0]}/$GUAC_PASSWORD_HASHED/" /opt/mistborn_volumes/extra/guacamole/init/initdb.sql
sed -i "s/guacadmin/mistborn/g" /opt/mistborn_volumes/extra/guacamole/init/initdb.sql