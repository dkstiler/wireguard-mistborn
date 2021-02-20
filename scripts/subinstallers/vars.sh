#!/bin/bash

# default interface
iface=$(ip -o -4 route show to default | egrep -o 'dev [^ ]*' | awk 'NR==1{print $2}')

# real public interface
riface=$(ip -o -4 route get 1.1.1.1 | egrep -o 'dev [^ ]*' | awk 'NR==1{print $2}')
