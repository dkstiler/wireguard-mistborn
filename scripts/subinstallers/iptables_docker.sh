#!/bin/bash

set -e

source ./scripts/subinstallers/vars.sh

# start from scratch
sudo iptables -X MISTBORN-DOCKER-USER 2>/dev/null || true

sudo iptables -N DOCKER-USER || true
sudo iptables -N MISTBORN-DOCKER-USER || true

# default Mistborn Docker User chain
sudo iptables -A MISTBORN-DOCKER-USER -i $iface -s 10.0.0.0/8 -j RETURN
sudo iptables -A MISTBORN-DOCKER-USER -i $iface -s 172.16.0.0/12 -j RETURN
sudo iptables -A MISTBORN-DOCKER-USER -i $iface -s 192.168.0.0/16 -j RETURN
sudo iptables -A MISTBORN-DOCKER-USER -i $iface -j MISTBORN_INT_LOG_DROP

# add chain to DOCKER-USER
sudo iptables -I DOCKER-USER -j MISTBORN-DOCKER-USER