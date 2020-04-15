#!/bin/bash

set -e

sudo docker-compose -f /opt/mistborn/base.yml pull
sudo docker-compose -f /opt/mistborn/base.yml build

sudo systemctl restart Mistborn-base
