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

echo "Start of install_glpk_cvxopt.sh script!"
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

if [ ! -f /usr/lib/x86_64-linux-gnu/libglpk.so.36.0.1 ]
then
    GLPK_FOUND=0
else
    echo "libglpk.so.36.0.1 already installed!"
    GLPK_FOUND=1
fi

#if [ ! -f /usr/local/lib/python2.7/dist-packages/cvxopt-1.1.8.egg-info/PKG-INFO ]
if [ ! -f /usr/local/lib/python2.7/dist-packages/cvxopt-1.1.7.egg-info/PKG-INFO ]
then
    CVXOPT_FOUND=0
else
    echo "cvxopt 1.1.7 already installed!"
    #echo "cvxopt 1.1.8 already installed!"
    CVXOPT_FOUND=1
fi
# alt. from cvxopt.org/install/ : "To test that the installation was successful, go to the examples directory and try one of the examples, for example,"
#cd examples/doc/chap8
#python lp.py

# exit script immediately if both libraries are already installed
if [ "$FORCE" != "-f" ] && [ $GLPK_FOUND -eq 1 ] && [ $CVXOPT_FOUND -eq 1 ]
then
    echo "both glpk and cvxopt libraries already installed and up-to-date, exiting..."
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
$ABSOLUTE_PATH/check_pkg_status_and_install.sh curl # for curl use below
$ABSOLUTE_PATH/check_pkg_status_and_install.sh python-numpy python-pyparsing python-scipy python-cvxopt python-networkx python-numpy-doc python-matplotlib python-matplotlib-data python-matplotlib-doc python-pydot graphviz graphviz-doc python-pygraphviz python-scitools

if [ $UCODENAME == "trusty" ]; then
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh python-networkx-doc
elif [ $UCODENAME == "xenial" ]; then # not installed / name wrong on 16.04: python-networkx-doc
    :
fi
$ABSOLUTE_PATH/check_pkg_status_and_install.sh python-dev build-essential python-pip ipython ipython-notebook python-pandas python-sympy python-nose libblas-dev liblapack-dev gfortran python-glpk glpk-utils libglpk-dev libglpk36 swig libgmp3-dev
$ABSOLUTE_PATH/check_pkg_status_and_install.sh python-ply
#$ABSOLUTE_PATH/check_pkg_status_and_install.sh python-pip python-nose
#$ABSOLUTE_PATH/check_pkg_status_and_install.sh python-numpy python-networkx python-scipy python-ply python-matplotlib
#$ABSOLUTE_PATH/check_pkg_status_and_install.sh python-pydot
if [ "$FORCE" == "-f" ] || [ $GLPK_FOUND -eq 0 ]
then
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh libglpk-dev
fi
$ABSOLUTE_PATH/check_pkg_status_and_install.sh bison flex
$ABSOLUTE_PATH/check_pkg_status_and_install.sh default-jre
if [ "$FORCE" == "-f" ] || [ $CVXOPT_FOUND -eq 0 ]
then
    # if need to force, then remove old directory first
    if [ "$FORCE" == "-f" ]
    then
        rm -rf cvxopt-1.1.7
        #rm -rf cvxopt-1.1.8
    fi
    #if [ "$FORCE" == "-f" ] || [ ! -f cvxopt-1.1.8.tar.gz ]
    if [ "$FORCE" == "-f" ] || [ ! -f cvxopt-1.1.7.tar.gz ]
    then
        curl -sL https://github.com/cvxopt/cvxopt/archive/1.1.7.tar.gz -o cvxopt-1.1.7.tar.gz
        #curl -sL https://github.com/cvxopt/cvxopt/archive/1.1.8.tar.gz -o cvxopt-1.1.8.tar.gz
        FILECHECKSUM=`shasum -a 256 cvxopt-1.1.7.tar.gz|cut -d ' ' -f1`
        #FILECHECKSUM=`shasum -a 256 cvxopt-1.1.8.tar.gz|cut -d ' ' -f1`
        #if [ $FILECHECKSUM != 'c96f8d01ae31a5bdec36a65b0587f50cfbf8139335adb70442350a8042da2025' ]
        if [ $FILECHECKSUM != '11624199ba0064e4c384c9fe7ced6d425596fe1f1bbfafd6baaa18f0fe63fd9b' ]
        then
            echo "Checksum for the cvxopt tarball does not have expected value."
            rm cvxopt-1.1.7.tar.gz
            false
        fi
        tar -xzf cvxopt-1.1.7.tar.gz
        #tar -xzf cvxopt-1.1.8.tar.gz
    fi
    cd cvxopt-1.1.7
    #cd cvxopt-1.1.8
    sed -i.orig '41s/BUILD_GLPK = 0/BUILD_GLPK = 1/' setup.py
    #sed -i.orig '40s/BUILD_GLPK = 0/BUILD_GLPK = 1/' setup.py # 1.1.8
    # GLPK_LIB_DIR = '/usr/lib' --> GLPK_LIB_DIR = '/usr/lib/x86_64-linux-gnu'
    # breaking out and single quote: do a ' to escape, then \' for the character, then ' to start again
    # https://muffinresearch.co.uk/bash-single-quotes-inside-of-single-quoted-strings/
    sed -i.orig '44s/GLPK_LIB_DIR = '\''\/usr\/lib'\''/GLPK_LIB_DIR = '\''\/usr\/lib\/x86_64-linux-gnu'\''/' setup.py
    # sed -i.orig '44s/lib/lib\/x86_64-linux-gnu/' setup.py
    #sed -i.orig '43s/GLPK_LIB_DIR = '\''\/usr\/lib'\''/GLPK_LIB_DIR = '\''\/usr\/lib\/x86_64-linux-gnu'\''/' setup.py # 1.1.8
    python setup.py build
    #sudo pip install . # doesn't include the made-up .egg higher up the python path, which means python only sees the OS-installed cvxopt 1.1.4
    sudo python setup.py install # so do this instead -- it includes the .egg in the python path near the top
fi

echo "End of install_glpk_cvxopt.sh script!"
