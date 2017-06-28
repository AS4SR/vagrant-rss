#!/bin/bash -e
# Copyright by California Institute of Technology, University of Cincinnati
# All rights reserved. See LICENSE file at:
# https://github.com/AS4SR/vagrant-rss

echo "Start of install_ompl_noomplapp_nopythonbindings.sh script!"
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

#
# INPUT ARGUMENT PARSING:
#

# get -f (force) if given
if [ $# -eq 1 ] && [ "$1" == "-f" ]; then
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

#
# AS OF 2017-01-18 (or earlier):
#

# note that there is now an installation script provided by Kavrakilab for Ubuntu, Fedora, Linux (generic), OS X, and Windows(!!)
# it can be downloaded and permissions set to run via:
#wget http://ompl.kavrakilab.org/install-ompl-ubuntu.sh
#chmod u+x install-ompl-ubuntu.sh

# As per ( http://ompl.kavrakilab.org/installation.html ) :
# "There are three ways to run the script:
#    ./install-ompl-ubuntu.sh will install OMPL without Python bindings
#    ./install-ompl-ubuntu.sh --python will install OMPL with Python bindings
#    ./install-ompl-ubuntu.sh --app will install OMPL.app with Python bindings
# The script downloads and installs OMPL and all dependencies via apt-get & pip and from source.
# It will ask for your password to install things. The script has been tested on vanilla installs
# of Ubuntu 14.04 (Trusty), 15.10 (Wily), and 16.04 (Xenial)."

# Alternately, if the source code and/or Python bindings and/or GUI/app aren't needed...
$ABSOLUTE_PATH/check_pkg_status_and_install.sh libompl-dev ompl-demos

# Alternately-alternately, if you want the ROS MoveIt! version and have already installed a version of ROS...
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list'
wget http://packages.ros.org/ros.key -O - | sudo apt-key add -
sudo apt update
$ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-`rosversion -d`-ompl

echo "End of install_noomplapp_nopythonbindings.sh script!"
