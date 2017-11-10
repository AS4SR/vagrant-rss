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
# but -not- on either of the "ubuntu/trusty64" or "ubuntu/xenial64" base boxes
#

echo "Start of install_all_rss_deps.sh script!"
#echo "input arguments: ROSVERSION [SCRIPTUSER] [WORKSPACEDIR] [-f]"

#
# find path of this-script-being-run
# see: http://stackoverflow.com/questions/630372/determine-the-path-of-the-executing-bash-script
#
RELATIVE_PATH="`dirname \"$0\"`"
ABSOLUTE_PATH="`( cd \"$RELATIVE_PATH\" && pwd )`"
echo "PATH of current script ($0) is: $ABSOLUTE_PATH"

#
# parse input vars (set to appropriate vars or default vars)
#
source $ABSOLUTE_PATH/single_installers/get_rv_su_wd_f.sh "$@"
# when source'd, sets these vars at this level: ROSVERSION SCRIPTUSER WORKSPACEDIR FORCE

#
# run installation + upgrades
#

# update all packages, because "gah!" otherwise, especially for 'rosdep' stuff later
$ABSOLUTE_PATH/single_installers/apt_upd_sys.sh

# start in the root directory (if "sudo su" then is "/root")
cd ~
# make and move into directory for holding compilation files + downloads
mkdir -p ~/initdeps
cd ~/initdeps

# install tulip-control v1.1a system-wide
#$ABSOLUTE_PATH/vagrant/single_installers/install_tulip1.1a.sh $FORCE
# install tulip-control v1.2.0 system-wide
$ABSOLUTE_PATH/single_installers/install_tulip1.2.0.sh $FORCE

# install recommended software for python development (python-pip already installed above)
$ABSOLUTE_PATH/single_installers/check_pkg_status_and_install.sh spyder geany python-dev build-essential dos2unix

# install polytope library -- should be installed via tulip-control installer
#:

cd ~/initdeps

# directory should exist, but just to make sure...
sudo -u $SCRIPTUSER mkdir -p $WORKSPACEDIR/src

# just in case, fix ownership of /home/$SCRIPTUSER/catkin_ws/src
sudo chown -R $SCRIPTUSER:$SCRIPTUSER $WORKSPACEDIR

# install gnome-terminal for multiscript*.py runs
# install rosbridge
# install turtlebot libraries
# install (SD-Robot-Vision / ua_ros_p3dx) libraries for ./rss_git/contrib/p3dx_gazebo_mod
# set up catkin workspace
# install ROSARIA
# install deps for MobileSim and MobileSim
# install python WebSocket library
$ABSOLUTE_PATH/single_installers/install_rosstuff_setup_catkinworkspace.sh $ROSVERSION $SCRIPTUSER $WORKSPACEDIR $FORCE

# OMPL install moved to bottom of file due to possible installation issues under some circumstances

# install psulu dependencies  # this isn't working under Ubuntu 16.04 currently
$ABSOLUTE_PATH/single_installers/install_psulu_deps.sh $FORCE

# install Michele Colledanchise's Behavior Tree work :) # this isn't working under Ubuntu 16.04 currently
$ABSOLUTE_PATH/single_installers/install_MC_behavior_tree.sh $FORCE

# install RRT# (RRT-sharp) planner dependencies
$ABSOLUTE_PATH/single_installers/install_rrtsharp_deps.sh $FORCE

# install yaml in Python (PyYAML with LibYAML bindings) for yaml read-ins
$ABSOLUTE_PATH/single_installers/install_pyyaml.sh $FORCE

# install OMPL libraries (cvxopt and glpk already installed above)
$ABSOLUTE_PATH/single_installers/install_ompl.sh $FORCE # install_ompl.sh untested under Ubuntu 16.04

# install OMPL system libraries from Debian packages -- no python bindings!
#$ABSOLUTE_PATH/single_installers/install_ompl_noomplapp_nopythonbindings.sh $ROSVERSION $SCRIPTUSER $WORKSPACEDIR $FORCE

# install Google TensorFlow for Ravi Kiran's machine learning work:
$ABSOLUTE_PATH/single_installers/install_tensorflow0.8.0.sh $SCRIPTUSER $FORCE
# note that this installs TensowFlow to a VirtualEnv session for the given $SCRIPTUSER
# also note that the python3 install may not work / may error out...

echo "End of install_all_rss_deps.sh script!"
