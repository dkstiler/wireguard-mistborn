#!/bin/bash

# INPUT default admin password
while [ -z "${MISTBORN_DEFAULT_PASSWORD}" ]; do
    echo
    echo "(Mistborn) The default admin password may only container alphanumeric characters and _"
    read -p "(Mistborn) Set default admin password: " -s MISTBORN_DEFAULT_PASSWORD
    echo

    if [[ ${MISTBORN_DEFAULT_PASSWORD} =~ ^[A-Za-z0-9_]+$ ]]; then
    # it matches
        echo "(Mistborn) Password is accepted"
    else
        unset MISTBORN_DEFAULT_PASSWORD
        echo "(Mistborn) Try again"
    fi

done

echo
echo "MISTBORN_DEFAULT_PASSWORD is set"
echo
