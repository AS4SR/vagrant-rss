#!/bin/bash -e
# Copyright by California Institute of Technology, University of Cincinnati
# All rights reserved. See LICENSE file at:
# https://github.com/cmcghan/vagrant-rss

#
# in the initialization process for vagrant, this bash script is run as user 'root' from /vagrant
#

# there is some cleaner stuff we can do here between scripts that we are enacting now
#
# basically, if we run something as "source my_script.sh" or ". ./myscript.sh",
# then it is run at the same "level" as the calling shell (or script) and changes are
# persistent, e.g.,
# -- "source" the subscript in a top-level script for the subscript to see all the
#    environment variables in that script
# -- modify an environment variable in the subscript for the top-level script that
#    "source"d it to see the change in the top-level script
#
# if you only want to share a few env vars from the top-level down, and make
# no changes to the env vars above:
# -- "export" a environment variable in the top-level script for the subscript to see
#    only that environment variable
# -- do not "source" the subscript for changes in the subscript not to affect the
#    top-level script
# see: http://stackoverflow.com/questions/9772036/pass-all-variables-from-one-shellscript-to-another

echo "Start of install_rosstuff_setup_catkinworkspace.sh script!"
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
source $ABSOLUTE_PATH/get_rv_su_wd_f.sh "$@"
# when source'd, sets these vars at this level: ROSVERSION SCRIPTUSER WORKSPACEDIR FORCE


#
# check for installation
#

#

#
# run installation + upgrades
#

# update all packages, because "gah!" otherwise, especially for 'rosdep' stuff later
$ABSOLUTE_PATH/apt_upd_sys.sh

# for wget and possible curl use below
$ABSOLUTE_PATH/check_pkg_status_and_install.sh wget curl

# install ROS indigo OR jade OR kinetic (for "ubuntu/trusty64" box)
$ABSOLUTE_PATH/install_appropriate_ros_version.sh $ROSVERSION $SCRIPTUSER $WORSPACEDIR $FORCE

# install gazebo and gazebo-ros packages
$ABSOLUTE_PATH/install_gazebo_plus_rospkgs.sh $ROSVERSION $SCRIPTUSER $WORSPACEDIR $FORCE

# note: this will install to the home directory of user $SCRIPTUSER
# so, if this script is called as user 'vagrant'
# (e.g., "sudo -u vagrant /vagrant/single_installers/install_rosstuff_setup_catkinworkspace.sh")
# then this will install under /home/vagrant
# (technically /home/vagrant/catkin_ws and catkin_ws/src

# directory should exist, but just to make sure...
sudo -u $SCRIPTUSER mkdir -p $WORSPACEDIR/src

# remove devel and build directories if exist already (want to catkin_make from scratch)
if [ "$FORCE" == "-f" ]
then
    rm -rf $WORSPACEDIR/devel
    rm -rf $WORSPACEDIR/build
fi

# install gnome-terminal for multiscript*.py runs
$ABSOLUTE_PATH/check_pkg_status_and_install.sh gnome-terminal

# install rosbridge
$ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-rosbridge-server

# install turtlebot libraries
$ABSOLUTE_PATH/install_turtlebot_ros.sh $ROSVERSION $SCRIPTUSER $WORSPACEDIR $FORCE

# install (SD-Robot-Vision / ua_ros_p3dx) libraries for ./rss_git/contrib/p3dx_gazebo_mod
$ABSOLUTE_PATH/install_p3dx_ros.sh $ROSVERSION $SCRIPTUSER $WORSPACEDIR $FORCE

# set up catkin workspace
$ABSOLUTE_PATH/set_up_catkin_workspace.sh $ROSVERSION $SCRIPTUSER $WORSPACEDIR $FORCE

# install ROSARIA (reference: http://wiki.ros.org/ROSARIA/Tutorials/How%20to%20use%20ROSARIA )
$ABSOLUTE_PATH/install_ROSARIA.sh $ROSVERSION $SCRIPTUSER $WORSPACEDIR $FORCE

# install deps for MobileSim and MobileSim (references: http://robots.mobilerobots.com/wiki/MobileSim and http://robots.mobilerobots.com/MobileSim/download/current/README.html )
$ABSOLUTE_PATH/install_MobileSim.sh $ROSVERSION $SCRIPTUSER $WORSPACEDIR $FORCE

# install python WebSocket library (reference: https://ws4py.readthedocs.org/en/latest/sources/install/ )
$ABSOLUTE_PATH/install_ws4py.sh $ROSVERSION $SCRIPTUSER $WORSPACEDIR $FORCE

# install UWSim stuff
#$ABSOLUTE_PATH/install_uwsim_ros.sh $ROSVERSION $SCRIPTUSER $WORSPACEDIR $FORCE

# install USARSimROS + libraries
#$ABSOLUTE_PATH/install_usarsim_ros.sh $ROSVERSION $SCRIPTUSER $WORSPACEDIR $FORCE

# install CRUMBproject + libraries and dependencies
#$ABSOLUTE_PATH/install_crumb_ros.sh $ROSVERSION $SCRIPTUSER $WORSPACEDIR $FORCE

# install hector_quadrotor + libraries and dependencies
$ABSOLUTE_PATH/install_hector_quadrotor.sh $ROSVERSION $SCRIPTUSER $WORSPACEDIR $FORCE

# install SURF 2016 libraries and dependencies
#$ABSOLUTE_PATH/install_SURF2016_deps.sh $ROSVERSION $SCRIPTUSER $WORSPACEDIR $FORCE

# install WidowX stuff + libraries and dependencies
#$ABSOLUTE_PATH/install_widowx_ros.sh $ROSVERSION $SCRIPTUSER $WORSPACEDIR $FORCE

echo "End of install_rosstuff_setup_catkinworkspace.sh script!"
