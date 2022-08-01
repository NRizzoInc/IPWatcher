#/bin/bash
# Simple script to create latest package from source code

# CLI Flags
print_flags () {
    echo "=========================================================================================================="
    echo "Usage: ./build-release"
    echo "=========================================================================================================="
    echo "Helper utility to setup the bash command to run as a callback if the public IP changes"
    echo "Run watcher with './IPWatcher.sh --watch <interval>'"
    echo "Note: If your callback requires elevated privaleges, start watch as 'sudo ./IPWatcher.sh'"
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
dpkg-deb --build src/ releases/IPWatcher.deb
