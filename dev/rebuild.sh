#!/bin/bash

sudo systemctl stop Mistborn-base
sudo rm -rf /opt/mistborn_volumes/*
sudo docker container prune -f
sudo docker image prune -f
sudo docker volume prune -f
sudo eval "$(dirname "${BASH_SOURCE[0]}")/wg_clean.sh"

pushd .
cd /opt/mistborn
tar -xzvf ../mistborn_backup/mistborn_volumes_backup.tar.gz -C ../
git pull
git submodule update --init
sudo docker-compose -f base.yml build
popd

sudo systemctl start Mistborn-base
sudo journalctl -xfu Mistborn-base
