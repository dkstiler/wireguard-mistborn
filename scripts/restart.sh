#!/bin/bash 

set -e

export DEBIAN_FRONTEND=noninteractive

sudo systemctl stop Mistborn-base
sudo systemctl restart Mistborn-setup
sudo systemctl restart Mistborn-base