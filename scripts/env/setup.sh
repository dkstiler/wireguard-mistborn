#!/bin/bash

VAR_FILE=/opt/mistborn/.env

source /opt/mistborn/scripts/subinstallers/platform.sh

MISTBORN_DNS_BIND_IP="0.0.0.0"
if [ "$DISTRO" == "ubuntu" ] && [ "$VERSION_ID" == "20.04" ]; then
    MISTBORN_DNS_BIND_IP="10.2.3.1"
fi

echo "MISTBORN_DNS_BIND_IP=${MISTBORN_DNS_BIND_IP}" | sudo tee ${VAR_FILE}
sudo chown mistborn:mistborn ${VAR_FILE}

GIT_BRANCH=$(git -C /opt/mistborn symbolic-ref --short HEAD || echo "master")
MISTBORN_TAG="latest"
if [ "$GIT_BRANCH" != "master" ]; then
    MISTBORN_TAG="test"
fi

echo "MISTBORN_TAG=$MISTBORN_TAG" | sudo tee -a ${VAR_FILE}
