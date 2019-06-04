#!/bin/bash -e
# Copyright by California Institute of Technology, University of Cincinnati
# All rights reserved. See LICENSE file at:
# https://github.com/AS4SR/vagrant-rss

#
# in the initialization process for vagrant, this bash script is run as user 'root' from /vagrant
#

echo "Start of install_appropriate_ros_version.sh script!"
#echo "input arguments: ROSVERSION [SCRIPTUSER] [WORKSPACEDIR] [-f]"
#NOTE: [WORKSPACEDIR] and [-f] are NOT used by this script!

# find path of this-script-being-run
# see: http://stackoverflow.com/questions/630372/determine-the-path-of-the-executing-bash-script
#
RELATIVE_PATH="`dirname \"$0\"`"
ABSOLUTE_PATH="`( cd \"$RELATIVE_PATH\" && pwd )`"
echo "PATH of current script ($0) is: $ABSOLUTE_PATH"

#
# parse input vars (set to appropriate vars or default vars)
#
source $ABSOLUTE_PATH/get_rv_su_wd_f.sh "$@"
# when source'd, sets these vars at this level: ROSVERSION SCRIPTUSER WORKSPACEDIR FORCE

#
# NOTE: this file does the following:
# (does NOT install ROS indigo, as ROS indigo is pre-installed on the "shadowrobot/ros-indigo-desktop-trusty64" base box)
# (if requested, installs ROS jade on "ubuntu/trusty64" (add servers to apt-get list, add key, then install))
# (if requested, installs ROS kinetic on "ubuntu/xenial64" (add servers to apt-get list, add key, then install))
#

#
# check for installation
#

ROSVERSION_INSTALLED=`dpkg -s ros-$ROSVERSION-desktop-full | grep -m 1 "Status: install ok installed" | wc -l`
# dpkg -s ros-$ROSVERSION-desktop-full should check pkg status and return a set of strings with '...Status: install ok installed...' or '...is not installed...'
# grep should find a match and repeat it (the entire line)
# and wc -l should give 1 if installed/good-status (and 0 if "is not installed" was found)
if [ $ROSVERSION_INSTALLED -eq 1 ]; then
    echo "ros-$ROSVERSION-desktop-full is already installed!"
fi

#
# run installation + upgrades
#

# update all packages, because "gah!" otherwise, especially for 'rosdep' stuff later
$ABSOLUTE_PATH/apt_upd_sys.sh

# for wget and possible curl use below
$ABSOLUTE_PATH/check_pkg_status_and_install.sh wget curl

#
# install ROS indigo OR jade OR kinetic (for "ubuntu/trusty64" box)
# --> can comment out for "shadowrobot/ros-indigo-desktop-trusty64" box (ROS indigo is pre-installed on that Vagrantbox)
#

if [ $ROSVERSION_INSTALLED -eq 0 ]; then # we need to install ROS
    sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
    sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
    sudo apt-get -y update
    
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-desktop-full # will not hurt anything if preinstalled
    # if rosdep sources file list has -not- already been initialized:
    if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then # rosdep init this
        sudo rosdep init
        su - $SCRIPTUSER -c "rosdep update;"
    fi
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh python-rosinstall
fi

echo "End of install_appropriate_ros_version.sh script!"
