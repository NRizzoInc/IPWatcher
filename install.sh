#!/bin/bash
# Simple script to install latest release version

sudo apt install --reinstall ./releases/IPWatcher-latest.deb
sudo systemctl daemon-reload
sudo systemctl restart IPWatcher
