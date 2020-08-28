#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive

sudo git -C /opt/mistborn pull
sudo git -C /opt/mistborn submodule update --init --recursive

# ensure mistborn-cli is installed
sudo pip3 install -e /opt/mistborn/modules/mistborn-cli

# handle updates to traefik
#sudo cp /opt/mistborn/compose/production/traefik/traefik.toml.template /opt/mistborn/compose/production/traefik/traefik.toml

sudo mistborn-cli pullbuild

sudo docker container prune -f
sudo docker image prune -f

sudo systemctl stop Mistborn-base
sudo systemctl restart Mistborn-setup
sudo systemctl restart Mistborn-base
