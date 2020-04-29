#!/bin/bash

pushd .
cd /etc/wireguard

for filename in ./*.conf; do
    
    iface="$(basename $filename | cut -d'.' -f1)" 
    
    if sudo wg show $iface 1>/dev/null 2>&1 ; then
        # interface exists
        if sudo wg show $iface | grep -qF 'latest handshake' ; then
            echo 'connected'
        else
            echo 'never connected'
            echo "stoppping, disabling, and removing  $iface"
            sudo systemctl stop wg-quick@$iface && sudo systemctl disable wg-quick@$iface && rm ./$filename
        fi
    fi

done


popd
