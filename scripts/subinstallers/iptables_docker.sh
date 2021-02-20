#!/bin/bash

set -e

source ./scripts/subinstallers/vars.sh

sudo iptables -N DOCKER-USER || true
sudo iptables -I DOCKER-USER -i $iface -j MISTBORN_INT_LOG_DROP
