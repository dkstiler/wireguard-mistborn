#!/bin/bash

set -e

figlet "Mistborn: Configuring Firewall"

echo "stop iptables wrappers"
if [ "$DISTRO" == "ubuntu" ]; then
    # Disable UFW
    sudo systemctl stop ufw || true
    sudo systemctl disable ufw || true
fi

# default interface
iface=$(ip -o -4 route show to default | egrep -o 'dev [^ ]*' | awk '{print $2}')

# real public interface
riface=$(ip -o -4 route get 1.1.1.1 | egrep -o 'dev [^ ]*' | awk '{print $2}')

# resetting iptables
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -X MISTBORN_LOG_DROP 2>/dev/null || true
sudo iptables -X MISTBORN_WIREGUARD_INPUT 2>/dev/null || true
sudo iptables -X MISTBORN_WIREGUARD_FORWARD 2>/dev/null || true
sudo iptables -X MISTBORN_DOCKER_OUTPUT 2>/dev/null || true
sudo iptables -X MISTBORN_DOCKER_INPUT 2>/dev/null || true

# iptables: log and drop chain
sudo iptables -N MISTBORN_LOG_DROP
sudo iptables -A MISTBORN_LOG_DROP -m limit --limit 6/min -j LOG --log-prefix "[IPTables-Dropped]: " --log-level 4
sudo iptables -A MISTBORN_LOG_DROP -j DROP

# wireguard rules chains
sudo iptables -N MISTBORN_WIREGUARD_INPUT
sudo iptables -N MISTBORN_WIREGUARD_FORWARD
sudo iptables -N MISTBORN_WIREGUARD_OUTPUT

# iptables
echo "Setting iptables rules"
sudo iptables -P INPUT ACCEPT
sudo iptables -I INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# if installing over SSH, add SSH rule
if [ ! -z "${SSH_CLIENT}" ]; then
    SSH_SRC=$(echo $SSH_CLIENT | awk '{print $1}')
    sudo iptables -A INPUT -p tcp -s $SSH_SRC --dport 22 -j ACCEPT
fi

# docker rules
sudo iptables -N MISTBORN_DOCKER_INPUT
sudo iptables -A MISTBORN_DOCKER_INPUT -i br-+ -j ACCEPT
#sudo iptables -A MISTBORN_DOCKER_INPUT -i docker0 -j ACCEPT

# last rules
sudo iptables -A INPUT -j MISTBORN_DOCKER_INPUT
sudo iptables -A INPUT -j MISTBORN_WIREGUARD_INPUT
sudo iptables -A INPUT -j MISTBORN_LOG_DROP
sudo iptables -A FORWARD -j MISTBORN_WIREGUARD_FORWARD
sudo iptables -A OUTPUT -j MISTBORN_WIREGUARD_OUTPUT

sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT

#if [ "$iface" == "$riface" ]; then
sudo iptables -t nat -I POSTROUTING -o $iface -j MASQUERADE
#else
#    sudo iptables -t nat -I POSTROUTING -o $iface -j MASQUERADE
#    sudo iptables -t nat -I POSTROUTING -o $riface -j MASQUERADE
#fi

# resetting ip6tables rules
sudo ip6tables -F
sudo ip6tables -t nat -F
sudo ip6tables -X MISTBORN_LOG_DROP 2>/dev/null || true

# ip6tables: log and drop chain
sudo ip6tables -N MISTBORN_LOG_DROP
sudo ip6tables -A MISTBORN_LOG_DROP -m limit --limit 6/min -j LOG --log-prefix "[IPTables-Dropped]: " --log-level 4
sudo ip6tables -A MISTBORN_LOG_DROP -j DROP

# ip6tables
echo "Setting ip6tables rules"
sudo ip6tables -P INPUT ACCEPT
sudo ip6tables -I INPUT -i lo -j ACCEPT
sudo ip6tables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo ip6tables -A INPUT -j MISTBORN_LOG_DROP

sudo ip6tables -P INPUT DROP
sudo ip6tables -P FORWARD DROP
sudo ip6tables -P OUTPUT ACCEPT

# iptables-persistent
if [ ! "$(dpkg-query -l iptables-persistent)" ]; then
    echo "Installing iptables-persistent"
    
    # answer variables
    echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
    echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
    
    # install
    sudo apt-get install -y iptables-persistent ipset
else
    echo "Saving iptables rules"
    sudo bash -c "iptables-save > /etc/iptables/rules.v4"
    echo "Saving ip6tables rules"
    sudo bash -c "ip6tables-save > /etc/iptables/rules.v6"
fi

# IP forwarding
sudo sed -i 's/.*net.ipv4.ip_forward.*/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sudo sysctl -p /etc/sysctl.conf

# rsyslog to create /var/log/iptables.log
sudo cp ./scripts/conf/15-iptables.conf /etc/rsyslog.d/
sudo chown root:root /etc/rsyslog.d/15-iptables.conf
sudo systemctl restart rsyslog
