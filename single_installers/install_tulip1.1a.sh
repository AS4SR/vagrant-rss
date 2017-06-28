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

echo "Start of install_tulip1.1a.sh script!"
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
TULIP_FOUND=`python -c "import pkg_resources; print(pkg_resources.get_distribution('tulip').version)" | grep -m 1 -o "1.1a-dev-unknown-commit" | wc -l`
# pkg_resources should give '1.1a-dev-unknown-commit'
# grep should find a match and repeat it
# and wc -l should give 1 if tulip 1.1a was found

if [ $TULIP_FOUND -eq 1 ]
then
    echo "tulip 1.1a already installed!"
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

#
# install tulip-control v1.1a system-wide
#

# for wget and possible curl use below
$ABSOLUTE_PATH/check_pkg_status_and_install.sh wget curl

$ABSOLUTE_PATH/check_pkg_status_and_install.sh install default-jre default-jdk

#polytope 0.1.1 doesn't play nice with tulip-1.1a
#polytope 0.1.0 plays nice with tulip-1.1a
#--> see tulip-1.1a/run_tests.py (will FAIL if polytope 0.1.1 is used)
#note that tulip-1.1a seems to try and install newest version of polytope (0.1.1) from PyPi automatically (even if an older version exists, likely using pip)
#one can download and manually install polytope 0.1.0 ("sudo python setup.py install") and then run ./run_tests.py with it (without recompiling tulip-1.1a), though it does seem slower

# install polytope 0.1.0 system-wide (https://pypi.python.org/pypi/polytope/0.1.0)
# if need to force, then remove old directory first
if [ "$FORCE" == "-f" ]
then
    rm -rf .
fi
if [ "$FORCE" == "-f" ] || [ ! -f polytope-0.1.0.tar.gz ]
then
    wget https://pypi.python.org/packages/source/p/polytope/polytope-0.1.0.tar.gz#md5=1eca56d647340acab6314431c568319f
    tar xvzf polytope-0.1.0.tar.gz
fi
cd polytope-0.1.0
sudo python setup.py install

# install tulip-control v1.1a system-wide
cd ~/initdeps
# if need to force, then remove old directory first
if [ "$FORCE" == "-f" ]
then
    rm -rf tulip-control-1.1a
fi
if [ "$FORCE" == "-f" ] || [ ! -f v1.1a.tar.gz ]
then
    wget https://github.com/tulip-control/tulip-control/archive/v1.1a.tar.gz
    tar xvzf v1.1a.tar.gz
    cd tulip-control-1.1a
    sed -i.orig '290s/polytope >= 0.1.0/polytope >= 0.1.0,<0.1.1/' setup.py
    # 'polytope >= 0.1.0', --> 'polytope >= 0.1.0,<0.1.1', # inside 'install_requires'
    cd ..
fi
cd tulip-control-1.1a
sudo python setup.py install

echo "End of install_tulip1.1a.sh script!"
