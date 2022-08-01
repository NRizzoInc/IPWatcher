#!/bin/bash
# Simple script to install latest release version

# CLI Flags
print_flags () {
    echo "=========================================================================================================="
    echo "Usage: ./install.sh"
    echo "=========================================================================================================="
    echo "Simple script to install latest release version"
    echo "=========================================================================================================="
    echo "How to use:"
    echo "  ./install.sh <flags>"
    echo "=========================================================================================================="
    echo "Available Flags (mutually exclusive):"
    echo "  --build / --update: Installs current build rather than release"
    echo "  --help: Prints this message"
    echo "=========================================================================================================="
}

build () {
    sudo bash build-release.sh
}


# parse command line args
# print flags if none passed
numArgs=$#
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --build | --update )
            build
            ;;

        -h | --help )
            print_flags
            exit 0
            ;;
        * )
            echo "... Unrecognized config command"
            print_flags
            exit 1
            ;;
    esac
    shift
done


sudo apt install --reinstall ./releases/IPWatcher-latest.deb
sudo systemctl daemon-reload
sudo systemctl restart IPWatcher
