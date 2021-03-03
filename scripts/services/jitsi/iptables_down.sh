#!/bin/bash

iptables -w -D DOCKER-USER -i $DIFACE -p udp --dport $JVB_PORT -j MISTBORN_LOG_DROP
iptables -w -D DOCKER-USER -i $DIFACE -p tcp --dport $JVB_TCP_PORT -j MISTBORN_LOG_DROP