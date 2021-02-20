#!/bin/bash

set -e

# resetting ip6tables rules
sudo ip6tables -F
sudo ip6tables -t nat -F
sudo ip6tables -X MISTBORN_LOG_DROP 2>/dev/null || true
sudo ip6tables -X MISTBORN_INT_LOG_DROP 2>/dev/null || true

# ip6tables: log and drop chain (external threats)
sudo ip6tables -N MISTBORN_LOG_DROP
sudo ip6tables -A MISTBORN_LOG_DROP -m limit --limit 6/min -j LOG --log-prefix "[Mistborn-IPTables-Dropped]: " --log-level 4
sudo ip6tables -A MISTBORN_LOG_DROP -j DROP

# ip6tables: log and drop chain (internal threats)
sudo ip6tables -N MISTBORN_INT_LOG_DROP
sudo ip6tables -A MISTBORN_INT_LOG_DROP -m limit --limit 6/min -j LOG --log-prefix "[Mistborn-IPTables-Internal-Dropped]: " --log-level 4
sudo ip6tables -A MISTBORN_INT_LOG_DROP -j DROP

# ip6tables
echo "Setting ip6tables rules"
sudo ip6tables -P INPUT ACCEPT
sudo ip6tables -I INPUT -i lo -j ACCEPT
sudo ip6tables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo ip6tables -A INPUT -j MISTBORN_LOG_DROP

sudo ip6tables -P INPUT DROP
sudo ip6tables -P FORWARD DROP
sudo ip6tables -P OUTPUT ACCEPT

