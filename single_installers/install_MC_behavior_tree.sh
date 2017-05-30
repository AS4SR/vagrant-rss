#!/bin/bash -e
# Copyright by University of Cincinnati
# All rights reserved. See LICENSE file at:
# https://github.com/cmcghan/vagrant-rss

#
# in the initialization process for vagrant, this bash script is run as user 'root' from /vagrant
#

echo "Start of install_MC_behavior_tree.sh script!"
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

# not currently working under Ubuntu 16.04, see below
if [ $UCODENAME == "xenial" ]; then # this isn't working under Ubuntu 16.04, see above
    echo "Currently can't install Behavior-Tree properly under Ubuntu 16.04, due to compile error (/usr/bin/ld: CMakeFiles/btpp_example.dir/src/action_node.cpp.o: undefined reference to symbol 'pthread_create@@GLIBC_2.2.5'), sorry. Stopping Behavior-Tree install early."
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

# install python libraries for Michele Colledanchise's behavioral tree stuff:
$ABSOLUTE_PATH/check_pkg_status_and_install.sh libgeos-dev # Geometry Engine Open Source (GEOS) needed for shapely
sudo pip install shapely
if [ "$FORCE" == "-f" ]
then
    sudo pip install --upgrade shapely
fi

# now, Michele Colledanchise's Behavior Tree work :)
if [ "$FORCE" == "-f" ]
then
    rm -rf behavior_tree
fi
if [ ! -d behavior_tree ]; then
    git clone https://github.com/miccol/Behavior-Tree.git behavior_tree
fi
cd behavior_tree
mkdir ./build
cd build
cmake ..
make # "Note the installation generates the shared library in behavior_tree/build/lib and the sample code in behavior_tree/build/sample"
sudo make install # to install system-wide
# check installation via:
#cd ~/initdeps/behavior_tree
#cd build/sample
#./btpp_example
# or:
# /usr/local/bin/btpp_example

echo "End of install_MC_behavior_tree.sh script!"
