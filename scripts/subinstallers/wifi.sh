#!/bin/bash

# wpa_supplicant
sudo systemctl stop wpa_supplicant.service
sudo systemctl disable wpa_supplicant.service
sudo systemctl mask wpa_supplicant.service
sudo pkill wpa_supplicant

# create wificfg.json
sudo mkdir -p /opt/mistborn_volumes/extra/wifi
sudo cp /opt/mistborn/scripts/conf/wificfg.json /opt/mistborn_volumes/extra/wifi/
