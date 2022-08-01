#/bin/bash
# Simple script to create latest package from source code

dpkg-deb --build src/ releases/IPWatcher.deb
