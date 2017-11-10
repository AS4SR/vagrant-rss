#!/bin/bash -e
# Copyright by University of Cincinnati
# All rights reserved. See LICENSE file at:
# https://github.com/AS4SR/vagrant-rss

#
# in the initialization process for vagrant, this bash script is run as user 'root' from /vagrant
#

echo "Start of apt_upd_sys.sh script!"

# make sure aptdcon exists, if not then install it to /usr/bin/aptdcon
APTDCON_INSTALLED=`whereis aptdcon | grep -m 1 "/usr/bin/aptdcon" | wc -l`
if [ $APTDCON_INSTALLED -lt 1 ]
then
    sudo apt install aptdaemon
fi

# run an 'apt update' check without sudo
# ref: https://askubuntu.com/questions/391983/software-updates-from-terminal-without-sudo
aptdcon --refresh
NUMBER_UPGRADEABLE=`apt-get -s upgrade | grep "upgraded," | cut -d' ' -f1`
if [ $NUMBER_UPGRADEABLE -gt 0 ]
then
    echo "Some packages require updating, running apt update-upgrade as sudo now..."
    sudo apt -y update
    sudo apt -y upgrade
    echo "Done with apt update-upgrade!"
fi

echo "End of apt_upd_sys.sh script!"
