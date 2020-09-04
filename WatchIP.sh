#!/bin/bash
# @File: WatchIP.sh
# @Purpose: Detect changes to your machine's public IP and fire the callback set by ./configure
# @Author: Nick Rizzo (rizzo.n@northeastern.edu)


# check OS
[[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]] && isWindows=true || isWindows=false

genericInfoPath=/opt/WatchIP/data.txt
[[ "${isWindows}" == true ]] && currInfoPath="./${genericInfoPath}" || currInfoPath=${genericInfoPath}

# CLI Flags
print_flags () {
    echo "=========================================================================================================="
    echo "Usage: ./WatchIP.sh"
    echo "=========================================================================================================="
    echo "Main script that runs every 'x' seconds to check if your machine's public IP changed"
    echo "=========================================================================================================="
    echo "How to use:" 
    echo "  To set the callback for IP changes: ./configure --callback <command to run>"
    echo "  To stop watching, kill with ctrl+c"
    echo "  Note: You can turn the callback off/on too with ./configure --stop/start"
    echo "=========================================================================================================="
    echo "Available Flags (mutually exclusive):"
    echo "  --get-ip: Get current public IP"
    echo "  --detect-ip-change: Determines if public IP has changes since last run"
    echo "  --help: Prints this message"
    echo "=========================================================================================================="
}


# returns current ip
function getPublicIP () {
    publicIP=$(curl --silent ifconfig.me)
    echo "${publicIP}"
}

# returns old ip
function getOldPublicIP () {
    oldIP=$(sed 's/^CurrentIP=//' ${currInfoPath})
    echo "${oldIP}"
}

# $1 = new ip
function setNewPublicIP () {
    newIP=$1
    sed -i "s/^CurrentIP=.*/CurrentIP=${newIP}/" ${currInfoPath}
}

function detectIPChange () {
    oldIP=$(getOldPublicIP)
    currentIP=$(getPublicIP)
    if [[ "$oldIP" == "$currentIP" ]]; then
    # TODO: add time this ran
        echo "Public IP Unchanged: ${oldIP}"
    else
        setNewPublicIP "${currentIP}"
        echo "Public IP Changed: ${oldIP} --> ${currentIP}"
        # TODO: Run callback
    fi
}

# parse command line args
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --watch )
            interval=60 # repeat every minute (in seconds)
            echo "Checking public IP every ${interval} seconds..."
            watch -n ${interval} -x bash -c detectIPChange
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
