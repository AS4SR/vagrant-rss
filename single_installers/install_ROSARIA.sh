#!/bin/bash -e
# Copyright by California Institute of Technology, University of Cincinnati
# All rights reserved. See LICENSE file at:
# https://github.com/cmcghan/vagrant-rss

#
# in the initialization process for vagrant, this bash script is run as user 'root' from /vagrant
#

echo "Start of install_ROSARIA.sh script!"
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
# (old note, no longer valid -- NOTE: "-f" WILL -NOT- REMOVE OR FORCE-REINSTALL ROSARIA!!!)

#
# check for installation
#

# Aria is installed to /usr/local/Aria ; libAria.so is installed to /usr/local/Aria/libAria.so
# $ dpkg -s libaria
#dpkg-query: package 'libaria' is not installed and no information is available
#Use dpkg --info (= dpkg-deb --info) to examine archive files,
#and dpkg --contents (= dpkg-deb --contents) to list their contents.
# $ dpkg -s libaria
#Package: libaria
#Status: install ok installed
#Priority: optional
#Section: contrib/MobileRobots
#Installed-Size: 67783
#Maintainer: Reed Hedges <reed@mobilerobots.com>
#Architecture: amd64
#Source: aria
#Version: 2.9.1+ubuntu16
#Replaces: aria, libaria-seekur
#Provides: libarnetworking
#Suggests: mobilesim, mobileeyes, mapper3
#Conffiles:
# /etc/Aria 814a935e7f663b25ead1ec9c1bf179e2
#Description: programming interface and applications toolkit for MobileRobots/ActivMedia robots
# ARIA is an object oriented toolkit for controlling MobileRobots/ActivMedia
# mobile robots and their accessories, and for creating robot control
# applications. It also provides many cross-platform and high-level tools for
# multimedia, networking, and other useful tasks. This package contains
# libraries, example programs, API reference documentation, and full source code.

if [ ! -f /usr/local/Aria/libAria.so ]
then
    ARIA_FOUND=0
else
    echo "libAria.so already installed!"
    ARIA_FOUND=1
fi

#
# run installation + upgrades
#

# update all packages, because "gah!" otherwise, especially for 'rosdep' stuff later
$ABSOLUTE_PATH/apt_upd_sys.sh

# for wget and possible curl use below
$ABSOLUTE_PATH/check_pkg_status_and_install.sh wget curl

# install libAria (performing this step this way allows us to skip the problematic rosdep step that would require uninstallation of libAria via apt-get prior to the rosdep command)
# start in the root directory (if "sudo su" then is "/root")
cd ~
# make and move into directory for holding compilation files + downloads
mkdir -p ~/initdeps
cd ~/initdeps
# references:
# http://wiki.ros.org/ROSARIA/Tutorials/How%20to%20use%20ROSARIA
# http://robots.mobilerobots.com/wiki/Aria

if [ "$FORCE" == "-f" ] && [ $ARIA_FOUND -eq 1 ] # if forcing stuff, uninstall libAria before reinstalling
then
    # note: as of 2017-05-19, it looks like Aria has a much cleaner uninstall process
    sudo apt-get remove libaria
fi
if [ "$FORCE" == "-f" ] || [ $ARIA_FOUND -eq 0 ]
then
    ARCH_NUM=`uname -m`
    if [ $UCODENAME == "trusty" ]; then # Ubuntu 14.04 LTS
        if [ "$ARCH_NUM" == "x86_64" ]; then # 64-bit arch
            wget http://robots.mobilerobots.com/ARIA/download/current/libaria_2.9.1+ubuntu12_amd64.deb
            sudo dpkg -i libaria_2.9.1+ubuntu12_amd64.deb
        elif [ "$ARCH_NUM" == "i386" ]; then # 32-bit arch
            wget http://robots.mobilerobots.com/ARIA/download/current/libaria_2.9.1+ubuntu12_i386.deb
            sudo dpkg -i libaria_2.9.1+ubuntu12_i386.deb
        else
            echo "Unknown ARCH_NUM='$ARCH_NUM'"
            exit 1
        fi
    elif [ $UCODENAME == "xenial" ]; then # Ubuntu 16.04 LTS
        if [ "$ARCH_NUM" == "x86_64" ]; then # 64-bit arch
            wget http://robots.mobilerobots.com/ARIA/download/current/libaria_2.9.1+ubuntu16_amd64.deb
            sudo dpkg -i libaria_2.9.1+ubuntu16_amd64.deb
        elif [" $ARCH_NUM" == "i386" ]; then # 32-bit arch
            wget http://robots.mobilerobots.com/ARIA/download/current/libaria_2.9.1+ubuntu16_i386.deb
            sudo dpkg -i libaria_2.9.1+ubuntu16_i386.deb
        else
            echo "Unknown ARCH_NUM='$ARCH_NUM'"
            exit 1
        fi
    fi
fi

# install ROSARIA (reference: http://wiki.ros.org/ROSARIA/Tutorials/How%20to%20use%20ROSARIA )
cd $WORKSPACEDIR/src
# do NOT attempt to force rosaria if it's been installed previously! could cause serious issues (esp. with Aria and libaria!)
# (Dependencies: genmsg -  if the make fails, Install package separately from here: https://github.com/ros/genmsg)
if [ "$FORCE" == "-f" ]; then # remove rosaria git repo and clean up catkin_make (need to remove build devel or do 'catkin_make --force_cmake' to fix this if previously ran w/o libAria.so installed)
    rm -rf rosaria
    rm -rf $WORKSPACEDIR/build
    rm -rf $WORKSPACEDIR/devel
fi
if [ "$FORCE" == "-f" ] || [ ! -d rosaria ]
then
    sudo -u $SCRIPTUSER git clone https://github.com/amor-ros-pkg/rosaria.git
    cd rosaria
    # roll back to earlier version (/cmd_vel as pub-sub)
    sudo -u $SCRIPTUSER git checkout d58a244fc50bba568da57a828c9121c83a19284d
    # this checkout downgrades to a version of rosaria that does not
    # (a) require: chmod +x cfg/RosAria.cfg
    # (b) require: pubtopic change from /RosAria/cmd_vel to /cmd_vel
    #su - $SCRIPTUSER -c "source /home/$SCRIPTUSER/.bashrc; cd $WORKSPACEDIR; source /opt/ros/$ROSVERSION/setup.bash; source devel/setup.bash; rosdep update; rosdep -y install rosaria; /opt/ros/$ROSVERSION/bin/catkin_make;"
    # must run "rosdep update" and "rosdep install rosaria" as $SCRIPTUSER (non-root user)
    # sudo rosdep fix-permissions # if was root, would then need to run 'rosdep update' again without sudo
    su - $SCRIPTUSER -c "source /home/$SCRIPTUSER/.bashrc; cd $WORKSPACEDIR; source /opt/ros/$ROSVERSION/setup.bash; source devel/setup.bash; /opt/ros/$ROSVERSION/bin/catkin_make;"
fi

echo "End of install_ROSARIA.sh script!"
