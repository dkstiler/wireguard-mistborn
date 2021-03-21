#!/bin/bash

# daemon.json
if [ ! -f /etc/docker/daemon.json ]; then
    sudo -E cp ./scripts/conf/docker-daemon.json /etc/docker/daemon.json
    sudo -E systemctl restart docker
fi
