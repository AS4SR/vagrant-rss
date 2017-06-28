#!/bin/bash -e
# Copyright by University of Cincinnati
# All rights reserved. See LICENSE file at:
# https://github.com/AS4SR/vagrant-rss

#
# in the initialization process for vagrant, this bash script is run as user 'root' from /vagrant
#

echo "Start of install_rrtsharp_deps.sh script!"
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

# see ./templates_/bash-script-commands-for-checking-version-numbers-of-installed-stuff.txt for examples

#ARMA_VER="6.600.5" # tar.gz
ARMA_VER="7.900.1" # 2017-05-19

# for now, default of recompilation...
ARMADILLO_FOUND=0
YAMLCPP_FOUND=0

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

# install eclipse for development environment for Oktay's RRT# (RRT-sharp) planner
$ABSOLUTE_PATH/check_pkg_status_and_install.sh eclipse-platform

# install dependencies for Ravi's ROS-native wrapper for the RRT# code (service call)
$ABSOLUTE_PATH/check_pkg_status_and_install.sh gcc g++ patch wget

# C++ Armadillo library: http://arma.sourceforge.net/download.html
if [ $UCODENAME == "trusty" ]; then
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh cmake libopenblas-dev liblapack-dev libatlas-dev libarpack2-dev libsuperlu3-dev # libsuperlu-dev # libarpack-dev
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh libarmadillo-dev # installs 4.200.0, not 6.600.5 latest
elif [ $UCODENAME == "xenial" ]; then
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh cmake libopenblas-dev liblapack-dev libatlas-dev libarpack2-dev libsuperlu-dev # libarpack-dev
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh libarmadillo-dev # installs 4.200.0 on 14.04 trusty, not $ARMA_VER latest
fi

cd ~/initdeps
# if need to force, then remove old directory first
if [ "$FORCE" == "-f" ]; then
    rm -rf "armadillo-$ARMA_VER"
    #rm -rf armadillo-$ARMA_VER.tar.gz
    rm -rf armadillo-$ARMA_VER.tar.xz
fi
if [ ! -d "armadillo-$ARMA_VER" ]; then
    #wget http://sourceforge.net/projects/arma/files/armadillo-$ARMA_VER.tar.gz
    wget http://sourceforge.net/projects/arma/files/armadillo-$ARMA_VER.tar.xz
    #tar xvzf armadillo-$ARMA_VER.tar.gz
    tar xvf armadillo-$ARMA_VER.tar.xz
fi
cd "armadillo-$ARMA_VER"
if [ "$FORCE" == "-f" ] || [ $ARMADILLO_FOUND -eq 0 ]; then
    cmake .
    make
    sudo make install
fi

# YAML-CPP: https://github.com/jbeder/yaml-cpp/releases/tag/release-0.5.3
# This is the patched release. Latest git pull has an issue ( https://github.com/jbeder/yaml-cpp/commit/34bd1a7083e5875e6a4b2d4f61c0b356cc5d53fc )
cd ~/initdeps
# if need to force, then remove old directory first
if [ "$FORCE" == "-f" ]; then
    rm -rf "yaml-cpp-release-0.5.3"
fi
if [ ! -d "yaml-cpp-release-0.5.3" ]; then
    wget https://github.com/jbeder/yaml-cpp/archive/release-0.5.3.tar.gz
    tar xvzf release-0.5.3.tar.gz
fi
cd "yaml-cpp-release-0.5.3"
if [ "$FORCE" == "-f" ] || [ $YAMLCPP_FOUND -eq 0 ]; then
    mkdir build
    cd build
    cmake .. -DBUILD_SHARED_LIBS=ON
    make clean all
    make
    sudo make install
fi

# then take rrtsharp.tar.gz, place in ~/catkin_ws/src, and catkin_make inside ~/catkin_ws
#pull_from_wherever
#cd /home/$SCRIPTUSER/
#sudo -u vagrant tar xvzf rrtsharp.tar.gz # extracts to directory /home/$SCRIPTUSER/catkin_ws/src/rrt
#cd ..
#su - $SCRIPTUSER -c "source /home/$SCRIPTUSER/.bashrc; cd $WORKSPACEDIR; source /opt/ros/$ROSVERSION/setup.bash; source devel/setup.bash; /opt/ros/$ROSVERSION/bin/catkin_make;"

# check that functions like "driver" are available as dynamically-linked functions in the library with static names
#python
#import ctypes
#ctypes.CDLL
##<class 'ctypes.CDLL'>
#ctypes.CDLL("librrt.so")
##<CDLL 'librrt.so', handle 2257580 at 7f5b71fde110>
#ctypes.CDLL("librrt.so").driver
##<_FuncPtr object at 0x7f5b71f7a460>
#exit()

echo "End of install_rrtsharp_deps.sh script!"
