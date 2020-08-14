#!/bin/bash

BIN_PATH=$(dirname "$0")

command=$1

shift
case $command in
    --create)
        $BIN_PATH/dev-setup.sh
        ;;
    --stop)
        $BIN_PATH/dev-stop.sh
        ;;
    --usage)
        usage
        ;;
    *)
        $BIN_PATH/dev-start.sh
        ;;
esac

function usage() {
    echo "Usage: npx @hmcts/probate-dev-env [options]"
    echo
    echo "Options:"
    echo "  --create - create the environment"
    echo "  --stop - "
    echo ""
    echo "Not specifying an option will start the development environment"
    echo
    exit 1
}