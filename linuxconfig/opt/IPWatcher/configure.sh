#!/bin/bash

rootDir="$(readlink -fm $0/..)"

# check OS
[[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]] && isWindows=true || isWindows=false


# configDataPath = path to data file containing current public ip address
startDir="$(readlink -fm "$0"/..)"
pkgOptDir=/opt/IPWatcher
if [[ ${isWindows} == true ]]; then
    rootDir="$(readlink -fm "${startDir}"/../..)" #/linuxconfig/usr/bin -> linuxconfig/usr/ -> /linuxconfig
    pkgDir="${rootDir}${pkgOptDir}" # /linuxconfig/opt/IPWatcher
else
    pkgDir="${pkgOptDir}"
fi
configDataPath=${pkgDir}/data.txt

# Create dummy file if it does not exist
if test -f ${configDataPath}; then
    # echo "${configDataPath} exists"
    : # : = pass
else
    # if file with past data doesn't exist, create it and add dummy ip data
    mkdir -p ${pkgDir}
    touch -a ${configDataPath}
fi


# CLI Flags
print_flags () {
    echo "=========================================================================================================="
    echo "Usage: ./configure.sh"
    echo "=========================================================================================================="
    echo "Helper utility to setup the bash command to run as a callback if the public IP changes"
    echo "Run watcher with './WatchIP.sh --watch <interval>'"
    echo "Note: If your callback requires elevated privaleges, start watch as 'sudo ./WatchIP.sh'"
    echo "=========================================================================================================="
    echo "How to use:" 
    echo "  To set the callback for IP changes: ./configure.sh --callback <command to run>"
    echo "  To start the callback (done automatically when setting callback):  ./configure.sh --start"
    echo "  To stop callback:  ./configure.sh --stop"
    echo "  To print current callback command: ./configure.sh --current"
    echo "=========================================================================================================="
    echo "Available Flags (mutually exclusive):"
    echo "  --callback '<cmd>': Set the command to run when the public IP changes (use quotes to prevent errors)"
    echo "      Note: If using paths or '/', you will have to escape each one with a '\' (i.e.: \/path\/to\/my\/script)"
    echo "  --stop: Turn off the callback"
    echo "  --start: Turn on the callback"
    echo "  --current: Print the current callback command"
    echo "  --status: Print the on/off status of the callback (true=on, false=off)"
    echo "  --help: Prints this message"
    echo "=========================================================================================================="
}

# Functions

callbackStatusVname="isCallbackOn="
startCallback () {
    sed -in "s/${callbackStatusVname}.*/${callbackStatusVname}true/" ${configDataPath}
    echo "Configured IPWatcher to trigger the set callback"
}

stopCallback () {
    sed -in "s/${callbackStatusVname}.*/${callbackStatusVname}false/" ${configDataPath}
    echo "Configured IPWatcher to NOT trigger the set callback"
}

getCallbackStatus () {
    statusLine=$(grep "${callbackStatusVname}" ${configDataPath})
    status=${statusLine/${callbackStatusVname}/}
    echo "${status}"
}

callbackVarName="IPChangeCallback="
# $1 = the callback's command
setCallback () {
    # create backup & save new version with updated path
    cmd="$1"
    sed -in "s/${callbackVarName}.*/${callbackVarName}${cmd}/" ${configDataPath}
    echo "callback: ${cmd}"
    startCallback
}

getCurrentCallback () {
    callbackLine=$(grep "${callbackVarName}" ${configDataPath})
    callback=${callbackLine/${callbackVarName}/}
    echo "${callback}"
}

# parse command line args
# print flags if none passed
numArgs=$#
[[ ${numArgs} -eq 0 ]] && print_flags && exit 1
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --callback )
            setCallback "$2" # $2 is the command in quotes
            exit 0
            ;;

        --start )
            startCallback
            exit 0
            ;;

        --stop )
            stopCallback
            exit 0
            ;;

        --status )
            getCallbackStatus
            exit 0
            ;;

        --current )
            currCallback=$(getCurrentCallback)
            echo "${currCallback}"
            exit 0
            ;;

        -h | --help )
            print_flags
            exit 0
            ;;
        * )
            echo "... Unrecognized command"
            print_flags
            exit 1
            ;;
    esac
    shift
done
