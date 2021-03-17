#!/bin/bash

set -e

SERVICE="$1"
shift

export MISTBORN_HOME="/opt/mistborn"
export MISTBORN_SERVICE_FILE=${MISTBORN_HOME}/.envs/.production/.${SERVICE}
export MISTBORN_SERVICE_INIT=${MISTBORN_HOME}/scripts/services/${SERVICE}/init.sh

# check and create file if needed
${MISTBORN_HOME}/scripts/env/check_env_file.sh ${SERVICE}

# read in variables
set -a
source ${MISTBORN_HOME}/.env

if [[ -f "${MISTBORN_SERVICE_FILE}" ]]; then
    echo "Loading service variables"
    source ${MISTBORN_SERVICE_FILE}
else
    echo "No service variables to load. Proceeding."
fi
set +a

# call traefik-extra
if [[ ! -z "${MISTBORN_SERVICE_NAME}" ]] && \
   [[ ! -z "${MISTBORN_SERVICE_DOMAIN}" ]] && \
   [[ ! -z "${MISTBORN_SERVICE_PORT}" ]]; then

    echo "Populating traefik routes"

    mistborn-cli traefik-extra \
        --domain-name ${MISTBORN_SERVICE_DOMAIN} \
        --service-name ${MISTBORN_SERVICE_NAME} \
        --web-port ${MISTBORN_SERVICE_PORT}
else
    echo "Not populating traefik routes"
fi

# init script
if [[ -f "${MISTBORN_SERVICE_INIT}" ]]; then
    echo "Running init script"
    ${MISTBORN_SERVICE_INIT}
else
    echo "No init script. Proceeding."
fi

exec "$@"