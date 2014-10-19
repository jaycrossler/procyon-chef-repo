#!/usr/bin/env bash

cd /usr/src
sudo mv procyon procyon.github
sudo ln -s /vagrant/procyon-repo procyon
sudo source /vagrant/scripts/restart_web_server.sh