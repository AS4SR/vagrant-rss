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

echo "Start of install_gr1c.sh script!"
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
source $ABSOLUTE_PATH/get_os_codename.sh

#
# INPUT ARGUMENT PARSING:
#

# get -f (force) if given
# if we get an input parameter (username) then use it, else use default 'vagrant'
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

GR1C_FOUND=`gr1c -V | grep -m 1 "gr1c 0.10.1" | wc -l`
if [ $GR1C_FOUND -eq 1 ]
then
    echo "gr1c 0.10.1 already installed!"
fi

# exit script immediately if libraries are already installed
if [ "$FORCE" != "-f" ] && [ $GR1C_FOUND -eq 1 ]
then
    echo "gr1c libraries already installed and up-to-date, exiting..."
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

# install gr1c:
$ABSOLUTE_PATH/check_pkg_status_and_install.sh curl # for curl use below
$ABSOLUTE_PATH/check_pkg_status_and_install.sh python-numpy python-pyparsing python-scipy python-cvxopt python-networkx python-numpy-doc python-matplotlib python-matplotlib-data python-matplotlib-doc python-pydot graphviz graphviz-doc python-pygraphviz python-scitools
if [ $UCODENAME == "trusty" ]; then
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh python-networkx-doc
elif [ $UCODENAME == "xenial" ]; then # not installed / name wrong on 16.04: python-networkx-doc
    :
fi
$ABSOLUTE_PATH/check_pkg_status_and_install.sh python-dev build-essential python-pip ipython ipython-notebook python-pandas python-sympy python-nose libblas-dev liblapack-dev gfortran python-glpk glpk-utils libglpk-dev libglpk36 swig libgmp3-dev
$ABSOLUTE_PATH/check_pkg_status_and_install.sh bison flex
$ABSOLUTE_PATH/check_pkg_status_and_install.sh default-jre
gpg --keyserver pgp.mit.edu --recv-keys 03B40F63
CUDDVERSION=2.5.0
GR1CVERSION=0.10.1
# if need to force, then remove old directory first
if [ "$FORCE" == "-f" ]
then
    rm -rf gr1c-$GR1CVERSION
fi
if [ "$FORCE" == "-f" ] || [ ! -f gr1c-$GR1CVERSION.tar.gz ] || [ ! -f gr1c-$GR1CVERSION.tar.gz.sig ]
then
    curl -sO http://vehicles.caltech.edu/snapshots/gr1c/gr1c-$GR1CVERSION.tar.gz
    curl -sO http://vehicles.caltech.edu/snapshots/gr1c/gr1c-$GR1CVERSION.tar.gz.sig
    gpg --verify gr1c-$GR1CVERSION.tar.gz.sig
    FILECHECKSUM=`shasum -a 256 gr1c-$GR1CVERSION.tar.gz|cut -d ' ' -f1`
    if [ $FILECHECKSUM != '73699369ee55b95aeb3742504e27676491b6d23db176e7e84c266e1a4845c6a3' ]
    then
        echo "Checksum for the gr1c tarball does not have expected value."
        rm gr1c-$GR1CVERSION.tar.gz
        false
    fi
    tar -xzf gr1c-$GR1CVERSION.tar.gz
fi
cd gr1c-$GR1CVERSION
./get-deps.sh
make cudd
make all
make check
sudo make install

echo "End of install_gr1c.sh script!"
