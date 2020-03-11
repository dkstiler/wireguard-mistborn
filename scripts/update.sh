#!/bin/bash

set -e

docker-compose -f /opt/mistborn/base.yml pull
docker-compose -f /opt/mistborn/base.yml build

systemctl restart Mistborn-base
