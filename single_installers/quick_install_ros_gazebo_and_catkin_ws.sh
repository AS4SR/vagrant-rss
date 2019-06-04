#!/bin/bash -e
# Copyright by California Institute of Technology, University of Cincinnati
# All rights reserved. See LICENSE file at:
# https://github.com/AS4SR/vagrant-rss

#
# in the initialization process for vagrant, this bash script is run as user 'root' from /vagrant
#

echo "Start of quick_install_ros_gazebo_and_catkin_ws.sh script!"
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
# run installation + upgrades
#

# install ROS
$ABSOLUTE_PATH/install_appropriate_ros_version.sh $ROSVERSION $SCRIPTUSER

# install Gazebo
$ABSOLUTE_PATH/install_gazebo_plus_rospkgs.sh $ROSVERSION

# set up catkin workspace
$ABSOLUTE_PATH/set_up_catkin_workspace.sh $ROSVERSION $SCRIPTUSER $WORKSPACEDIR

echo "End of quick_install_ros_gazebo_and_catkin_ws.sh script!"
