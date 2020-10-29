#!/bin/bash
# @File: WatchIP.sh
# @Purpose: Detect changes to your machine's public IP and fire the callback set by /opt/IPWatcher/configure.sh
# @Author: Nick Rizzo (rizzo.n@northeastern.edu)


# check OS
[[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]] && isWindows=true || isWindows=false

# if linux, need to check if using correct permissions (need to modify stuff at /opt/...)
if [[ "${isWindows}" = false ]]; then
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root ('sudo')"
        exit
    fi
fi

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
configToolPath=${pkgDir}/configure.sh

# Create dummy file if it does not exist
if test -f ${configDataPath}; then
    # echo "${configDataPath} exists"
    : # : = pass
else
    # if file with past data doesn't exist, create it and add dummy ip data
    mkdir -p ${pkgDir}
    touch -a ${configDataPath}
    echo -e "CurrentIP=127.0.0.1\n" > ${configDataPath}
fi

# CLI Flags
print_flags () {
    echo "=========================================================================================================="
    echo "Usage: ./WatchIP.sh"
    echo "=========================================================================================================="
    echo "Main script that runs every 'x' seconds to check if your machine's public IP changed"
    echo "=========================================================================================================="
    echo "How to use:" 
    echo "  To set the callback for IP changes: ./WatchIP.sh --config --callback <command to run>"
    echo "  To stop watching, kill with ctrl+c"
    echo "  Note: You check all configuration options with ./WatchIP.sh --config --help"
    echo "  Note: If running as a service, change the interval in /etc/systemd/system/IPWatcher.service"
    echo "=========================================================================================================="
    echo "Available Flags (mutually exclusive):"
    echo "  --watch <interval(seconds)>: Will check your computer's public ip at the set interval, detect changes, and fire the callback"
    echo "  --get-ip: Get current public IP"
    echo "  --detect-ip-change: Determines if public IP has changes since last run"
    echo "  --config: Set/get callback settings"
    echo "  --help: Prints this message"
    echo "=========================================================================================================="
}


# returns current ip
function getPublicIP () {
    publicIP=$(curl --silent ifconfig.me)
    echo "${publicIP}"
}

# returns old ip
ipVname="CurrentIP="
function getOldPublicIP () {
    oldIPLine=$(grep "${ipVname}" ${configDataPath})
    oldIP=${oldIPLine/${ipVname}/}
    echo "${oldIP}"
}

# $1 = new ip
function setNewPublicIP () {
    newIP=$1
    sed -i "s/^${ipVname}.*/${ipVname}${newIP}/" ${configDataPath}
}

function detectIPChange () {
    oldIP=$(getOldPublicIP)
    currentIP=$(getPublicIP)
    if [[ "$oldIP" == "$currentIP" ]]; then
        echo "$(date): Public IP Unchanged: ${oldIP}"
    else
        setNewPublicIP "${currentIP}"
        echo "$(date): Public IP Changed: ${oldIP} --> ${currentIP}"

        # run the callback (if on)
        isCallbackOn=$(bash "${configToolPath}" --status)
        if [[ ${isCallbackOn} == true ]]; then
            callback=$("${configToolPath}" --current)
            echo "Running command: ${callback}"
            bash -c "$callback"
        fi
    fi
}

# parse command line args
# print flags if none passed
numArgs=$#
currArg=0
[[ ${numArgs} -eq 0 ]] && print_flags && exit 1
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --watch )
            # default to repeat every minute (in seconds)
            isNumRegex='^[0-9]+([.][0-9]+)?$'
            interval=60
            if [[ -z "$2" ]]; then # var exists
                echo "No watch interval set, using default"
            else
                [[ $2 =~ $isNumRegex ]] && interval=$2
            fi
            echo "Checking public IP every ${interval} seconds..."

            # use sleep in loop to be compatible with windows git bash
            while true; do
                detectIPChange
                sleep "${interval}"
            done
            exit 0
            ;;

        --get-ip )
            publicIP=$(getPublicIP)
            echo "Public IP: ${publicIP}"
            exit 0
            ;;

        --detect-ip-change )
            detectMsg=$(detectIPChange)
            echo "${detectMsg}"
            exit 0
            ;;

        --config )
            # pass all CLI args (except this one) to configure script
            startingArgIdx=$((currArg+2))
            cliArgs=("${@:${startingArgIdx}}")
            cliConfigFlag="${cliArgs[0]}"
            cliAdditionalFlags=("${cliArgs[@]:1}")
            # echo "cliArgs: ${cliArgs}"
            # echo "cliConfigFlag: ${cliConfigFlag}"

            bash "${configToolPath}" "${cliConfigFlag}" "${cliAdditionalFlags[@]}"
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
    currArg=$((currArg+1))
    shift
done
