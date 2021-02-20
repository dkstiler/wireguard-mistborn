#!/bin/bash

set -e

figlet "Mistborn: Configuring Firewall"

source ./scripts/subinstallers/vars.sh

echo "stop iptables wrappers"
if [ "$DISTRO" == "ubuntu" ]; then
    # Disable UFW
    sudo systemctl stop ufw || true
    sudo systemctl disable ufw || true
fi

# resetting iptables
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -X MISTBORN_LOG_DROP 2>/dev/null || true
sudo iptables -X MISTBORN_INT_LOG_DROP 2>/dev/null || true
sudo iptables -X MISTBORN_WIREGUARD_INPUT 2>/dev/null || true
sudo iptables -X MISTBORN_WIREGUARD_FORWARD 2>/dev/null || true
sudo iptables -X MISTBORN_WIREGUARD_OUTPUT 2>/dev/null || true
sudo iptables -X MISTBORN_DOCKER_OUTPUT 2>/dev/null || true
sudo iptables -X MISTBORN_DOCKER_INPUT 2>/dev/null || true

# iptables: log and drop chain (external threats)
sudo iptables -N MISTBORN_LOG_DROP
sudo iptables -A MISTBORN_LOG_DROP -m limit --limit 6/min -j LOG --log-prefix "[Mistborn-IPTables-Dropped]: " --log-level 4
sudo iptables -A MISTBORN_LOG_DROP -j DROP

# iptables: log and drop chain (internal threats)
sudo iptables -N MISTBORN_INT_LOG_DROP
sudo iptables -A MISTBORN_INT_LOG_DROP -m limit --limit 6/min -j LOG --log-prefix "[Mistborn-IPTables-Internal-Dropped]: " --log-level 4
sudo iptables -A MISTBORN_INT_LOG_DROP -j DROP

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
    SSH_PRT=$(echo $SSH_CLIENT | awk '{print $3}')
    sudo iptables -A INPUT -p tcp -s $SSH_SRC --dport $SSH_PRT -j ACCEPT
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

