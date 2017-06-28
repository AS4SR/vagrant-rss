#!/bin/bash -e
# Copyright by University of Cincinnati
# All rights reserved. See LICENSE file at:
# https://github.com/AS4SR/vagrant-rss

#
# in the initialization process for vagrant, this bash script is run as user 'root' from /vagrant
#

echo "Start of install_SOMETHING2.sh script!"
echo "input arguments: [-f]"
echo "(note: optional input arguments in [])"
echo "-f sets FORCE=-f and will force a (re)install of all compiled-from-source components."

#
# find path of this-script-being-run
# see: http://stackoverflow.com/questions/630372/determine-the-path-of-the-executing-bash-script
#
RELATIVE_PATH="`dirname \"$0\"`"
ABSOLUTE_PATH="`( cd \"$RELATIVE_PATH\" && pwd )`"
echo "PATH of current script ($0) is: $ABSOLUTE_PATH"

# find O/S codename (set to UCODENAME)
#source $ABSOLUTE_PATH/get_os_codename.sh

#
# INPUT ARGUMENT PARSING:
#

# get -f (force) if given
if [ $# -eq 1 ] && [ "$1" == "-f" ]
then
    echo "-f (force) commandline argument given. Forcing install of all compiled-from-source components."
    FORCE=$1
else
    FORCE=
fi

#
# check for installation
#

# see ./templates_/bash-script-commands-for-checking-version-numbers-of-installed-stuff.txt for examples

# exit script immediately if libraries are already installed
#if [ "$FORCE" != "-f" ] && [ $SOMETHING_FOUND -eq 1 ]
#then
#    echo "SOMETHING libraries already installed and up-to-date, exiting..."
#    exit 0
#fi

#
# run installation + upgrades
#

# update all packages, because "gah!" otherwise, especially for 'rosdep' stuff later
$ABSOLUTE_PATH/apt_upd_sys.sh

# start in the /root directory
cd ~
# make and move into directory for holding compilation files + downloads
mkdir -p ~/initdeps
cd ~/initdeps

# for wget and possible curl use below
$ABSOLUTE_PATH/check_pkg_status_and_install.sh wget curl

# install SOMETHING python library from git:
#mkdir -p ~/initdeps/SOMETHING
#cd ~/initdeps/SOMETHING
# if need to force, then remove old directory first
#if [ "$FORCE" == "-f" ]; then
#    rm -rf "SOMETHING"
#fi
#if [ ! -d "SOMETHING" ]; then
#    git clone "SOMETHING"
#fi
#cd "SOMETHING"
#if [ "$FORCE" == "-f" ] || [ $SOMETHING_FOUND -eq 0 ]; then
#    sudo python setup.py install
#fi

# install SOMETHING library from pip:
#if [ ! -d SOMETHING ]
#then
#    git clone SOMETHING
#    cd SOMETHING
#    sudo pip install . # pip install SOMETHING from local download
#fi
#if [ "$FORCE" == "-f" ]
#then
#    sudo pip install --upgrade SOMETHING # do this to force newest version of SOMETHING
#fi

echo "End of install_SOMETHING2.sh script!"
