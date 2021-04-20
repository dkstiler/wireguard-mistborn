#!/bin/bash

set -e

MISTBORN_HOME="/opt/mistborn"

SERVICES="$1"
shift

IFS=','
read -ra SERVICES_ARRAY <<< "${SERVICES}"
for SERVICE in "${SERVICES_ARRAY[@]}"; do
    MISTBORN_SERVICE_FILE=${MISTBORN_HOME}/.envs/.production/.${SERVICE}
    MISTBORN_SERVICE_INIT=${MISTBORN_HOME}/scripts/services/${SERVICE}/init.sh

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

    # init script
    if [[ -f "${MISTBORN_SERVICE_INIT}" ]]; then
        echo "Running init script"
        ${MISTBORN_SERVICE_INIT}
    else
        echo "No init script. Proceeding."
    fi
done

# ensure base is up and listening
echo "Checking that Mistborn-base has finished starting up..."

while ! nc -z 10.2.3.1 5000; do
    WAIT_TIME=$((5 + $RANDOM % 15))
    echo "Waiting ${WAIT_TIME} seconds for Mistborn-base..."
    sleep ${WAIT_TIME}
done

echo "Mistborn-base is running"

exec "$@"
