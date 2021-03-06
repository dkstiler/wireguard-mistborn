#!/bin/bash

# must be run as mistborn
if [[ $(whoami) != 'mistborn' ]]; then
    echo "This must be run as mistborn"
    exit 1
fi

# input arguments
export MISTBORN_DEFAULT_PASSWORD="$1"

# set paths
export MISTBORN_HOME=/opt/mistborn
export MISTBORN_ENV_SCRIPT=${MISTBORN_HOME}/scripts/subinstallers/gen_prod_env.sh

