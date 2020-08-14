#!/bin/bash

BIN_PATH=$(dirname "$(readlink -f "$0")")

function usage() {
    echo "Usage: npx @hmcts/probate-dev-env [options]"
    echo
    echo "Options:"
    echo "  --create - create the environment"
    echo "  --stop - stop all the docker containers"
    echo "  --destroy - remove docker containers and volumes"
    echo ""
    echo "Not specifying an option will start the development environment"
    echo
    exit 1
}

command=$1

shift
case $command in
    --create)
        $BIN_PATH/dev-setup.sh
        ;;
    --stop)
        $BIN_PATH/dev-stop.sh
        ;;
    --destroy)
        $BIN_PATH/dev-destroy.sh
        ;;
    --help)
        usage
        ;;
    *)
        $BIN_PATH/dev-start.sh
        ;;
esac
