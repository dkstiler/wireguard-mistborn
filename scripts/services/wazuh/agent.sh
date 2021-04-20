#!/bin/bash

# detect if already installed
if [ $(dpkg -s wazuh-agent &> /dev/null) -eq 0 ]; then
    echo "Wazuh agent already installed"
    exit 0
fi

# prepare repo
echo "Adding Wazuh Repository"
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add -
echo "deb https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list

apt-get update

# wait for service to be listening
while ! nc -z 10.2.3.1 55000; do
    WAIT_TIME=10
    echo "Waiting ${WAIT_TIME} seconds for Wazuh API..."
    sleep ${WAIT_TIME}
done

# install
echo "Installing Wazuh agent"
WAZUH_MANAGER="10.2.3.1" WAZUH_AGENT_NAME="mistborn" apt-get install wazuh-agent
