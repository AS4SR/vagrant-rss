#!/bin/bash -e
# Copyright by California Institute of Technology, University of Cincinnati
# All rights reserved. See LICENSE file at:
# https://github.com/AS4SR/vagrant-rss

#
# in the initialization process for vagrant, this bash script is run as user 'root' from /vagrant
#

echo "Start of install_MobileSim.sh script!"
#echo "input arguments: ROSVERSION [SCRIPTUSER] [WORKSPACEDIR] [-f]"

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
# parse input vars (set to appropriate vars or default vars)
#
source $ABSOLUTE_PATH/get_rv_su_wd_f.sh "$@"
# when source'd, sets these vars at this level: ROSVERSION SCRIPTUSER WORKSPACEDIR FORCE


#
# check for installation
#

MOBILESIM_FOUND=`MobileSim --help | grep -m 1 "MobileSim 0.7.3" | wc -l`
#MOBILESIM_FOUND=`MobileSim --help | grep -m 1 "MobileSim 0.9.8" | wc -l`
if [ $MOBILESIM_FOUND -eq 1 ]; then
    echo "MobileSim 0.7.3 already installed!"
#    echo "MobileSim 0.9.8 already installed!"
fi
# can also find via: $ whereis MobileSim

#
# run installation + upgrades
#

# update all packages, because "gah!" otherwise, especially for 'rosdep' stuff later
$ABSOLUTE_PATH/apt_upd_sys.sh

# for wget and possible curl use below
$ABSOLUTE_PATH/check_pkg_status_and_install.sh wget curl

# install deps for MobileSim and MobileSim (references: https://github.com/srmq/MobileSim and http://robots.mobilerobots.com/wiki/MobileSim and http://robots.mobilerobots.com/MobileSim/download/current/README.html )
# Wayback Machine archived:
# https://web.archive.org/web/20181006012429/http://robots.mobilerobots.com/wiki/MobileSim
# https://web.archive.org/web/20181012011016/http://robots.mobilerobots.com/MobileSim/download/current/README.html
# -and-
# https://web.archive.org/web/20151007151559/http://robots.mobilerobots.com/wiki/MobileSim
# https://web.archive.org/web/20150921153951/http://robots.mobilerobots.com/MobileSim/download/current/README.html
# 0.9.8 source code available via:
# https://github.com/srmq/MobileSim
# 0.7.3 source code available via:
# https://web.archive.org/web/20140819235544/http://robots.mobilerobots.com/MobileSim/download/current/MobileSim-0.7.3+x86_64+gcc4.6.tgz
# https://web.archive.org/web/20140819235521/http://robots.mobilerobots.com/MobileSim/download/current/MobileSim-0.7.3+gcc4.6.tgz

if [ $MOBILESIM_FOUND -eq 0 ]
then
    mkdir -p ~/initdeps
    cd ~/initdeps
    
    # If you are running Ubuntu 14.04 64-bit, install these packages first to resolve dependencies, just in case (these are useful for Matlab fonts and such, too)
    if [ $UCODENAME == "trusty" ]; then
        $ABSOLUTE_PATH/check_pkg_status_and_install.sh lib32z1 lib32ncurses5 lib32bz2-1.0 xfonts-100dpi
    elif [ $UCODENAME == "xenial" ] || [ $UCODENAME == "bionic" ] ; then
        # requires GTK 2.6+ and libstdc++ 2.2 for libc6 ??
        # ia32-libs is replaced by the first two
        $ABSOLUTE_PATH/check_pkg_status_and_install.sh lib32z1 lib32ncurses5 lib32stdc++6 xfonts-100dpi
        sudo dpkg --add-architecture i386
        sudo apt -y update
        #sudo apt -y install libbz2-1.0:i386
        $ABSOLUTE_PATH/check_pkg_status_and_install.sh libbz2-1.0:i386
    fi
    
    #$ABSOLUTE_PATH/check_pkg_status_and_install.sh wget
    ARCH_NUM=`uname -m` # gives x86_64 vs. i386
    if [ $ARCH_NUM == "x86_64" ]; then
        ARCH_NUM="amd64"
    fi
    if [ "$FORCE" == "-f" ] || [ ! -f mobilesim_0.7.3+ubuntu12+gcc4.6_$ARCH_NUM.deb ]; then
        #wget http://robots.mobilerobots.com/MobileSim/download/archives/mobilesim_0.7.3+ubuntu12+gcc4.6_$ARCH_NUM.deb
        
        if [ $ARCH_NUM == "x86_64" ];
        then
            wget https://web.archive.org/web/20140819235405/http://robots.mobilerobots.com/MobileSim/download/current/mobilesim_0.7.3+ubuntu12+gcc4.6_amd64.deb
        else
            wget https://web.archive.org/web/20140819235255/http://robots.mobilerobots.com/MobileSim/download/current/mobilesim_0.7.3+ubuntu12+gcc4.6_i386.deb
        fi
    fi
    if [ "$FORCE" == "-f" ] || [ $MOBILESIM_FOUND -eq 0 ]; then
        sudo dpkg -i mobilesim_0.7.3+ubuntu12+gcc4.6_$ARCH_NUM.deb
    fi
    
    #if [ "$FORCE" == "-f" ] || [ ! -f mobilesim_0.9.8+ubuntu16_$ARCH_NUM.deb ]; then
    #    if [ "$ARCH_NUM" == "x86_64" ]; then
    #        wget https://web.archive.org/web/20181108102718/http://robots.mobilerobots.com/MobileSim/download/current/mobilesim_0.9.8+ubuntu16_amd64.deb
    #    else
    #        wget https://web.archive.org/web/20181110115927/http://robots.mobilerobots.com/MobileSim/download/current/mobilesim_0.9.8+ubuntu16_i386.deb
    #    fi
    #fi
    #if [ "$FORCE" == "-f" ] || [ $MOBILESIM_FOUND -eq 0 ]; then
    #    sudo dpkg -i mobilesim_0.9.8+ubuntu16_$ARCH_NUM.deb
    #fi
fi

# test a single robot via:
#MobileSim -m /usr/local/MobileSim/columbia.map -r p3dx
# test multiple robots via:
#MobileSim -m /usr/local/MobileSim/columbia.map -r p3dx:robot1 -r p3dx:robot2 -r amigo:robot3

echo "End of install_MobileSim.sh script!"
