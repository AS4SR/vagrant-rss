#!/bin/bash -e
# Copyright by California Institute of Technology, University of Cincinnati
# All rights reserved. See LICENSE file at:
# https://github.com/AS4SR/vagrant-rss

#
# in the initialization process for vagrant, this bash script is run as user 'root' from /vagrant
#

echo "Start of install_widowx_ros.sh script!"
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

# if ROS isn't already installed:
if [ ! -f /opt/ros/$ROSVERSION/setup.bash ]; then # install the appropriate version of ROS
    $ABSOLUTE_PATH/install_appropriate_ros_version.sh $ROSVERSION $SCRIPTUSER $WORKSPACEDIR $FORCE
fi

# need the -dev libraries of gazebo installed, and gazebo-proper, so also run:
$ABSOLUTE_PATH/install_gazebo_plus_rospkgs.sh $ROSVERSION $SCRIPTUSER $WORKSPACEDIR $FORCE

# if catkin_ws workspace isn't already set up:
if [ ! -d $WORKSPACEDIR ]; then # set up the catkin workspace
    $ABSOLUTE_PATH/set_up_catkin_workspace.sh $ROSVERSION $SCRIPTUSER $WORKSPACEDIR $FORCE
fi

#
# run installation + upgrades
#

# update all packages, because "gah!" otherwise, especially for 'rosdep' stuff later
$ABSOLUTE_PATH/apt_upd_sys.sh

# for wget and possible curl use below
$ABSOLUTE_PATH/check_pkg_status_and_install.sh wget curl





if [ "$ROSVERSION" == "indigo" ]; then
    
elif [ "$ROSVERSION" == "jade" ]; then
    
elif [ "$ROSVERSION" == "kinetic" ]; then
    
fi

#now, catkin_make this bad boy! :)
su - $SCRIPTUSER -c "source /home/$SCRIPTUSER/.bashrc; cd $WORKSPACEDIR; source /opt/ros/$ROSVERSION/setup.bash; /opt/ros/$ROSVERSION/bin/catkin_make;"



echo "End of install_widowx_ros.sh script!"
