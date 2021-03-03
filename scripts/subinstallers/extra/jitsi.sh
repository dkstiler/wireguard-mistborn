#!/bin/bash

# JITSI
JITSI_PROD_FILE="$1"
cp ${MISTBORN_HOME}/scripts/conf/jitsi.env $JITSI_PROD_FILE
mkdir -p ${MISTBORN_HOME}/.envs/.production/.jitsi-cfg/{web/letsencrypt,transcripts,prosody,jicofo,jvb}
sed -i "s/JICOFO_COMPONENT_SECRET.*/JICOFO_COMPONENT_SECRET=$(python3 -c "import secrets; import string; print(f''.join([secrets.choice(string.ascii_letters+string.digits) for x in range(32)]))")/" "$JITSI_PROD_FILE"
sed -i "s/JICOFO_AUTH_PASSWORD.*/JICOFO_AUTH_PASSWORD=$(python3 -c "import secrets; import string; print(f''.join([secrets.choice(string.ascii_letters+string.digits) for x in range(32)]))")/" "$JITSI_PROD_FILE"
sed -i "s/JVB_AUTH_PASSWORD.*/JVB_AUTH_PASSWORD=$(python3 -c "import secrets; import string; print(f''.join([secrets.choice(string.ascii_letters+string.digits) for x in range(32)]))")/" "$JITSI_PROD_FILE"
sed -i "s/JIGASI_XMPP_PASSWORD.*/JIGASI_XMPP_PASSWORD=$(python3 -c "import secrets; import string; print(f''.join([secrets.choice(string.ascii_letters+string.digits) for x in range(32)]))")/" "$JITSI_PROD_FILE"
sed -i "s/JIBRI_RECORDER_PASSWORD.*/JIBRI_RECORDER_PASSWORD=$(python3 -c "import secrets; import string; print(f''.join([secrets.choice(string.ascii_letters+string.digits) for x in range(32)]))")/" "$JITSI_PROD_FILE"
sed -i "s/JIBRI_XMPP_PASSWORD.*/JIBRI_XMPP_PASSWORD=$(python3 -c "import secrets; import string; print(f''.join([secrets.choice(string.ascii_letters+string.digits) for x in range(32)]))")/" "$JITSI_PROD_FILE"