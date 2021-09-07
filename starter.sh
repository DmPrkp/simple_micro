#!/usr/bin/env bash

KEY=$1
ACTION="action_$KEY"

# LOCAL ACTIONS

action_micro() {
    echo "start event-bus"
    cd ./event-bus || exit
    npm run start || exit
    cd ../
    sleep 1

    echo "start query"
    cd ./query || exit
    npm run start || exit
    cd ../
    sleep 1

    echo "start posts"
    cd ./posts || exit
    npm run start || exit
    cd ../
    sleep 1

    echo "start comments"
    cd ./comments || exit
    npm run start || exit
    cd ../
    sleep 1

    echo "start client"
    cd ./client || exit
    npm run start || exit
}

function_exists() {
    declare -f -F "$1" > /dev/null
    return $?
}

# shellcheck disable=SC2015
function_exists "$ACTION" && "$ACTION" "$@" || action_help