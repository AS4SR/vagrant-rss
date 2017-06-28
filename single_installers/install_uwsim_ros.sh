#!/bin/bash -e
# Copyright by California Institute of Technology, University of Cincinnati
# All rights reserved. See LICENSE file at:
# https://github.com/AS4SR/vagrant-rss

#
# in the initialization process for vagrant, this bash script is run as user 'root' from /vagrant
#

echo "Start of install_uwsim_ros.sh script!"
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

# update all packages, because "gah!" otherwise, especially for 'rosdep' stuff later
$ABSOLUTE_PATH/apt_upd_sys.sh

# for wget and possible curl use below
$ABSOLUTE_PATH/check_pkg_status_and_install.sh wget curl

# install UWSim stuff -- tested in indigo only!
cd $WORKSPACEDIR/src
$ABSOLUTE_PATH/check_pkg_status_and_install.sh python-urlgrabber ros-$ROSVERSION-uwsim libdc1394-22 libdc1394-22-dev libdc1394-utils
if [ "$FORCE" == "-f" ]; then
    rm -rf freefloating_gazebo
    rm -rf freefloating_gazebo_demo
fi
if [ ! -d freefloating_gazebo ]; then
    sudo -u $SCRIPTUSER git clone https://github.com/freefloating-gazebo/freefloating_gazebo
fi
if [ ! -d freefloating_gazebo_demo ]; then
    sudo -u $SCRIPTUSER git clone https://github.com/freefloating-gazebo/freefloating_gazebo_demo
fi
#su - $SCRIPTUSER -c "source /home/$SCRIPTUSER/.bashrc; cd $WORKSPACEDIR; source /opt/ros/$ROSVERSION/setup.bash; /opt/ros/$ROSVERSION/bin/catkin_make;"
#now, catkin_make this bad boy! :)
su - $SCRIPTUSER -c "source /home/$SCRIPTUSER/.bashrc; cd $WORKSPACEDIR; source /opt/ros/$ROSVERSION/setup.bash; /opt/ros/$ROSVERSION/bin/catkin_make;"

# set up demo for the first time:
#0$ cd ~/catkin_ws && source devel/setup.bash && roscore # is this necessary?
#1$ cd ~/catkin_ws && source devel/setup.bash
#1$ rosrun uwsim uwsim # to download robots (~/.uwsim/data)
#1$ roslaunch freefloating_gazebo_demo g500arm5e.launch parse:=true # synchs simulators (creates urdf from xacro for UWSim)
# start the simulators:
#1$ cd ~/catkin_ws && source devel/setup.bash
#1$ roslaunch freefloating_gazebo_demo g500arm5e.launch
#2$ cd ~/catkin_ws && source devel/setup.bash
#2$ roslaunch freefloating_gazebo_demo g500arm5e_gazebo.launch uwsim:=true # set uwsim:=false to show window
# test the demo:
#3$ cd ~/catkin_ws && source devel/setup.bash
#3$ rosrun freefloating_gazebo_demo freefloating_gazebo_demo
# alt. is to test the demo via manual teleoperation:
#3$ cd ~/catkin_ws && source devel/setup.bash
#3$ roslaunch freefloating_gazebo_demo manual.launch




echo "End of install_uwsim_ros.sh script!"
