#!/bin/bash

set -e

SERVICE="$1"

export MISTBORN_HOME=/opt/mistborn
export SERVICE_ENV_INSTALLER="${MISTBORN_HOME}/scripts/subinstallers/extra/${SERVICE}.sh"
export SERVICE_ENV_FILE="${MISTBORN_HOME}/.envs/.production/.${SERVICE}"

# read in global variables
set -a
source ${MISTBORN_HOME}/.env
source ${MISTBORN_HOME}/.envs/.production/.django
source ${MISTBORN_HOME}/.envs/.production/.postgres
source ${MISTBORN_HOME}/.envs/.production/.pihole
set +a

if [[ -f "${SERVICE_ENV_INSTALLER}" ]]; then

    if [[ -f "${SERVICE_ENV_FILE}" ]]; then
        echo "Environment file already exists."
    else

        # create env file for service
        echo "Creating environment file"
        source $SERVICE_ENV_INSTALLER $SERVICE_ENV_FILE
        chown mistborn:mistborn $SERVICE_ENV_FILE
        chmod 600 $SERVICE_ENV_FILE

    fi

else
    echo "No subinstaller found."
fi
