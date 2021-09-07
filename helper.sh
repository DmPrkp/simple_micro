#!/usr/bin/env bash

KEY=$1
ACTION="action_$KEY"

#####
#USER COMMANDS
#####

action_help() {
   echo "This script aggregate other command. Please use list for see list command.";
}

action_list() {
    echo "LOCAL"
    echo "================================================================"
    echo "install - install all dependencies";
    echo "run - start all local servers (back and front)";
    echo "stop - stop back server";
    echo
    echo "PRODUCTION"
    echo "================================================================"
    echo "production - all-in-one command for production";
    echo "stop_production - stop production";
    echo "pull_production - pull production";
    echo "install_production - install production";
    echo "build_production - build production";
    echo "start_production - start production";
    echo "restart_daemon - restart back server";
    echo
    echo "OTHER"
    echo "================================================================"
    echo "list - listing command";
    echo "help - for help";
    echo "alias - to make alias for this script";
    echo "composer arg1 arg2 ... argN - action for action composer";
    echo "yarn arg1 arg2 ... argN - action for action yarn";
    echo "back_console arg1 arg2 ... argN - command for execute for back";
    echo "daemon [arg1 arg2 ... argN] - run socket server daemon"
}

# LOCAL ACTIONS

action_install() {
    rm ./back/composer.lock
    cd ./back || exit
    composer install
    cd ../
    cd ./front || exit
    yarn install
    cd ../
}

action_run() {
    cd ./back || exit
    php bin/console server:stop
    rm -rf ./var/cache/dev
    php bin/console server:start 0.0.0.0:8000
    cd ../
    cd ./front || exit
    yarn run dev
    cd ../
}

action_stop() {
    cd ./back || exit
    php bin/console server:stop
    cd ../
    # shellcheck disable=SC2046
    kill -9 $(lsof -t -i:3000)
    # shellcheck disable=SC2046
    kill -9 $(lsof -t -i:8000)
}

# PRODUCTION ACTIONS

action_production() {
    action_stop_production
    sleep 1
    action_pull_production
    sleep 1
    action_install_production
    sleep 1
    action_build_production
    sleep 1
    action_start_production
}

action_stop_production() {
    cd ./front || exit
    yarn stop
    cd ../
    rm -f ./sock/pid.sock
    sleep 1
    cd ./back || exit
    php bin/console IOServer stop
    rm -rf var/cache
    cd ../
    echo "STOP SUCCESS!"
}

action_pull_production() {
    git pull
    echo "PULL SUCCESS!"
}

action_install_production() {
    cd ./back || exit
    composer install --no-dev --optimize-autoloader
    cd ../
    cd ./front || exit
    yarn install --production
    cd ../
    echo "INSTALL SUCCESS!"
}

action_build_production() {
    cd ./front || exit
    yarn build
    cd ../
    echo "BUILD SUCCESS!"
}

action_start_production() {
    cd ./front || exit
    yarn start
    cd ../
    echo "START SUCCESS!"
}

action_restart_daemon() {
    cd ./back || exit
    php bin/console IOServer start --no-debug -d
    cd ../
}

# OTHER

action_composer() {
    cd ./back || exit
    shift
    composer "$@"
    cd ../
}

action_yarn() {
    cd ./front || exit
    shift
    yarn "$@"
    cd ../
}

action_back_console() {
    cd ./back || exit
    shift
    php bin/console "$@"
    cd ../
}

action_daemon() {
    chmod +x helper.sh
    if [[ $2 ]]
    then
        shift
        php back/bin/console IOServer "$@"
    else
        rm -rf back/var/cache
        php back/bin/console IOServer start
    fi
}

action_alias() {
    chmod +x helper.sh
    if [[ $2 ]]
    then ALIAS=$2
    else ALIAS='helper'
    fi
    echo 'Please run command to make alias:'
    echo 'alias '$ALIAS"='bash $(pwd)/helper.sh'"
}

#####
#/USER COMMANDS
#####

function_exists() {
    declare -f -F "$1" > /dev/null
    return $?
}

# shellcheck disable=SC2015
function_exists "$ACTION" && "$ACTION" "$@" || action_help