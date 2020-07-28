#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive

sudo git -C /opt/mistborn pull
sudo git -C /opt/mistborn submodule update --init --recursive

# ensure mistborn-cli is installed
sudo pip3 install -e /opt/mistborn/modules/mistborn-cli

# handle updates to Mistborn systemd scripts
iface=$(ip -o -4 route show to default | egrep -o 'dev [^ ]*' | awk 'NR==1{print $2}')
sudo cp /opt/mistborn/scripts/services/Mistborn* /etc/systemd/system/
sudo find /etc/systemd/system/ -type f -name 'Mistborn*' | xargs sudo sed -i "s/User=root/User=mistborn/"
sudo find /etc/systemd/system/ -type f -name 'Mistborn*' | xargs sudo sed -i "s/DIFACE/$iface/"

# handle updates to traefik
sudo cp /opt/mistborn/compose/production/traefik/traefik.toml.template /opt/mistborn/compose/production/traefik/traefik.toml

sudo systemctl daemon-reload
sudo systemctl enable Mistborn-setup.service
sudo systemctl restart Mistborn-setup.service

sudo mistborn-cli pullbuild

sudo systemctl restart Mistborn-base
