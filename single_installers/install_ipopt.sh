#!/bin/bash -e
# Copyright by California Institute of Technology, University of Cincinnati
# All rights reserved. See LICENSE file at:
# https://github.com/cmcghan/vagrant-rss

#
# in the initialization process for vagrant, this bash script is run as user 'root' from /vagrant
#

#
# Note: Ubuntu X-Windows Desktop and ROS indigo are pre-installed
# on the "shadowrobot/ros-indigo-desktop-trusty64" base box
#

echo "Start of install_ipopt.sh script!"
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

IPOPT_FOUND=`ipopt -v | grep -m 1 "Ipopt 3.12.0" | wc -l`
if [ $IPOPT_FOUND -eq 1 ]
then
    echo "Ipopt 3.12.0 already installed!"
fi

# exit script immediately if libraries are already installed
if [ "$FORCE" != "-f" ] && [ $IPOPT_FOUND -eq 1 ]
then
    echo "Ipopt libraries already installed and up-to-date, exiting..."
    exit 0
fi

# not currently working under Ubuntu 16.04, see below
if [ $UCODENAME == "xenial" ]; then # this isn't working under Ubuntu 16.04, see above
    echo "Currently can't install Ipopt properly under Ubuntu 16.04, due to missing library (libipoptamplinterface.so.1), sorry. Stopping Ipopt install early."
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

# install python libraries for deliberative/psulu_picard (doxygen installed above)
$ABSOLUTE_PATH/check_pkg_status_and_install.sh gcc g++ gfortran subversion patch wget
$ABSOLUTE_PATH/check_pkg_status_and_install.sh doxygen
# you also need to get the 3.11.4 version for Ubuntu 14.04 from the repo, otherwise you will get:
# "ipopt: error while loading shared libraries: libipoptamplinterface.so.1: cannot open shared object file: No such file or directory"
# when you try to run "ipopt -v" to check the version (missing libraries, and yes this is weird...)
# (and yes, even installing the Ubuntu repo version afterwards solves the error message issue, so weird...)
$ABSOLUTE_PATH/check_pkg_status_and_install.sh coinor-libipopt-dev

# the above installs version 3.11.9-2.1 of coinor-libipopt-dev under Ubuntu 16.04 and gives the library error again when checking to see if it loads successfully (it doesn't)

if [ $UCODENAME == "trusty" ]; then
    # if need to force, then remove old directory first
    if [ "$FORCE" == "-f" ]
    then
        rm -rf Ipopt-3.12.0
    fi
    if [ "$FORCE" == "-f" ] || [ ! -f Ipopt-3.12.0.tgz ]
    then
        wget http://www.coin-or.org/download/source/Ipopt/Ipopt-3.12.0.tgz
        tar xvzf Ipopt-3.12.0.tgz
    fi
    cd Ipopt-3.12.0
    cd ThirdParty/Blas && ./get.Blas
    cd ../Lapack && ./get.Lapack
    cd ../ASL && ./get.ASL
    cd ../Mumps && ./get.Mumps
    cd ../Metis && ./get.Metis
    cd ../..
    mkdir -p build && cd build
    ../configure --prefix=/usr/local
    cd ../Ipopt/src/Common
    sed -i.orig '179s/__GNUC_PATCHLEVEL__ == 3/__GNUC_PATCHLEVEL__ >= 2/' IpUtils.cpp
    sed -i.orig '200s/__GNUC_PATCHLEVEL__ == 3/__GNUC_PATCHLEVEL__ >= 2/' IpUtils.cpp
    cd ../../../build
    make && make test && make doxydoc
    sudo make install
elif [ $UCODENAME == "xenial" ]; then # this isn't working under Ubuntu 16.04, see above
    # if need to force, then remove old directory first
    if [ "$FORCE" == "-f" ]
    then
        rm -rf CoinIpopt
    fi
    if [ "$FORCE" == "-f" ] || [ ! -f Ipopt-3.12.0.tgz ]
    then # https://www.coin-or.org/Ipopt/documentation/node12.html#SECTION00042300000000000000
        wget http://www.coin-or.org/download/source/Ipopt/Ipopt-3.12.7.tgz
        tar xvzf Ipopt-3.12.7.tgz
        mv Ipopt-3.12.7 CoinIpopt
    fi
    cd CoinIpopt
    cd ThirdParty/Blas && ./get.Blas
    cd ../Lapack && ./get.Lapack
    cd ../ASL && ./get.ASL
    cd ../Mumps && ./get.Mumps
    cd ../Metis && ./get.Metis
    cd ../..
    mkdir -p build && cd build
    ../configure --prefix=/usr/local
    #cd ../Ipopt/src/Common
    #sed -i.orig '179s/__GNUC_PATCHLEVEL__ == 3/__GNUC_PATCHLEVEL__ >= 2/' IpUtils.cpp
    #sed -i.orig '200s/__GNUC_PATCHLEVEL__ == 3/__GNUC_PATCHLEVEL__ >= 2/' IpUtils.cpp
    #cd ../../../build
    make && make test && make doxydoc
    sudo make install
fi

echo "End of install_ipopt.sh script!"
