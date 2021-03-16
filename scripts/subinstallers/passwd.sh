#!/bin/bash

# INPUT default admin password
while [ -z "${MISTBORN_DEFAULT_PASSWORD}" ] || [ ${MISTBORN_DEFAULT_PASSWORD} =~ ^[A-Za-z0-9_]+$ ]; do
    echo
    echo "(Mistborn) The default admin password may only container alphanumeric characters and _"
    read -p "(Mistborn) Set default admin password: " -s MISTBORN_DEFAULT_PASSWORD
    echo

done

echo
echo "MISTBORN_DEFAULT_PASSWORD is set"
echo
