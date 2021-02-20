#!/bin/bash

set -e

# iptables-persistent
if [ ! "$(dpkg-query -l iptables-persistent)" ]; then
    echo "Installing iptables-persistent"
    
    # answer variables
    echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
    echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
    
    # install
    sudo -E apt-get install -y iptables-persistent ipset
else
    echo "Saving iptables rules"
    sudo bash -c "iptables-save > /etc/iptables/rules.v4"
    echo "Saving ip6tables rules"
    sudo bash -c "ip6tables-save > /etc/iptables/rules.v6"
fi

# IP forwarding
sudo sed -i 's/.*net.ipv4.ip_forward.*/net.ipv4.ip_forward=1/' /etc/sysctl.conf

# VM Overcommit Memory
sudo grep -i "vm.overcommit_memory" /etc/sysctl.conf && sudo sed -i 's/.*vm.overcommit_memory.*/vm.overcommit_memory=1/' /etc/sysctl.conf || echo "vm.overcommit_memory=1" | sudo tee -a /etc/sysctl.conf

# Force re-read of sysctl.conf
sudo sysctl -p /etc/sysctl.conf

# rsyslog to create /var/log/iptables.log
sudo cp ./scripts/conf/15-iptables.conf /etc/rsyslog.d/
sudo chown root:root /etc/rsyslog.d/15-iptables.conf
sudo systemctl restart rsyslog
