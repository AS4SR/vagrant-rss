#!/bin/bash -e
# Copyright by California Institute of Technology, University of Cincinnati
# All rights reserved. See LICENSE file at:
# https://github.com/AS4SR/vagrant-rss

#
# in the initialization process for vagrant, this bash script is run as user 'root' from /vagrant
#

#
# Note: Ubuntu X-Windows Desktop and ROS indigo are pre-installed
# on the "shadowrobot/ros-indigo-desktop-trusty64" base box
#

echo "Start of install_tulip1.2.0.sh script!"
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

# check for version of tulip-control
TULIP_FOUND=`python -c "import pkg_resources; print(pkg_resources.get_distribution('tulip').version)" | grep -m 1 -o "1.2.0" | wc -l`
# pkg_resources should give '1.2.0'
# grep should find a match and repeat it
# and wc -l should give 1 if tulip 1.2.0 was found

if [ $TULIP_FOUND -eq 1 ]
then
    echo "tulip 1.2.0 already installed!"
fi

# exit script immediately if libraries are already installed
if [ "$FORCE" != "-f" ] && [ $TULIP_FOUND -eq 1 ]
then
    echo "tulip libraries already installed and up-to-date, exiting..."
    exit 0
fi

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

# install glpk and cvxopt:
#/vagrant/single_installers/install_glpk_cvxopt.sh $FORCE
$ABSOLUTE_PATH/install_glpk_cvxopt.sh $FORCE

# back to compilation/install directory (/root/initdeps)
cd ~/initdeps

# install gr1c:
#/vagrant/single_installers/install_gr1c.sh $FORCE
$ABSOLUTE_PATH/install_gr1c.sh $FORCE

# back to compilation/install directory (/root/initdeps)
cd ~/initdeps

# for wget and possible curl use below
$ABSOLUTE_PATH/check_pkg_status_and_install.sh wget curl

# install tulip-control v1.1a system-wide
$ABSOLUTE_PATH/check_pkg_status_and_install.sh default-jre default-jdk
#note that tulip-1.2.0 does not try and install newest version of polytope (0.1.1) from PyPi automatically if an older version exists
$ABSOLUTE_PATH/check_pkg_status_and_install.sh python-numpy python-scipy python-cvxopt python-networkx python-pip
#sudo pip install polytope # won't force an upgrade if not installed before # current version in repo (0.1.1) has issues with numpy >= 1.10 (because of version string parsing in quickhull.py); note that polytope won't work properly with numpy <=1.5.9 (unique1d() instead of unique())
sudo pip install --upgrade pip
sudo pip install --upgrade numpy
sudo pip install --upgrade scipy
cd ~/initdeps
if [ ! -d polytope ]
then
    git clone https://github.com/tulip-control/polytope.git
    cd polytope
    sudo pip install . # pip install polytope from local download
fi
if [ "$FORCE" == "-f" ]
then
    sudo pip install --upgrade polytope # do this to force newest version of polytope (and other deps: numpy, scipy, cvxopt, networkx) to install (polytope 0.1.1 as of 2016-04-20)
fi

cd ~/initdeps
# if need to force, then remove old directory first
if [ "$FORCE" == "-f" ]
then
    rm -rf tulip-1.2.0
fi
if [ "$FORCE" == "-f" ] || [ ! -f tulip-1.2.0.tar.gz ]
then
    wget https://pypi.python.org/packages/source/t/tulip/tulip-1.2.0.tar.gz#md5=20034ce18b665356abfa5684e496f20a
    tar xvzf tulip-1.2.0.tar.gz
fi
cd tulip-1.2.0
# optional: attempt to install jtlv:
sudo extern/get-jtlv.sh
sudo python setup.py install

echo "End of install_tulip1.2.0.sh script!"
