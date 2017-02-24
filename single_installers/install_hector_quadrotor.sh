#!/bin/bash -e
# Copyright by University of Cincinnati
# All rights reserved. See LICENSE file at:
# https://github.com/cmcghan/vagrant-rss

#
# in the initialization process for vagrant, this bash script is run as user 'root' from /vagrant
#

echo "Start of install_hector_quadrotor.sh script!"
echo "input arguments: ROSVERSION [SCRIPTUSER] [WORKSPACEDIR] [-f]"
echo "(note: optional input arguments in [])"
echo "(note: there is no default ROSVERSION. Acceptable inputs are: indigo jade kinetic)"
echo "(note: default [SCRIPTUSER] is \"vagrant\")"
echo "(note: SCRIPTUSER must be given as an argument for WORKSPACEDIR to be read and accepted from commandline)"
echo "(note: default [WORKSPACEDIR] is \"/home/\$SCRIPTUSER/catkin_ws\")"
echo "WORKSPACEDIR must specify the absolute path of the directory"
echo "-f sets FORCE=-f and will force a (re)install of all compiled-from-source components."

# find O/S codename (set to UCODENAME)
source ./get_os_codename.sh

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

# set defaults for input arguments
ROSVERSION=
SCRIPTUSER=vagrant
WORKSPACEDIR="/home/$SCRIPTUSER/catkin_ws"
FORCE=






# if ROS isn't already installed:
if [ ! -f /opt/ros/$ROSVERSION/setup.bash ]; then # install the appropriate version of ROS
    ./install_appropriate_ros_version.sh $ROSVERSION $SCRIPTUSER $WORKSPACEDIR $FORCE
fi

sudo apt-get -y install libgazebo7-dev



# if catkin_ws workspace isn't already set up:
if [ ! -d $WORKSPACEDIR ]; then # set up the catkin workspace
    ./set_up_catkin_workspace.sh $ROSVERSION $SCRIPTUSER $WORKSPACEDIR $FORCE
fi


cd $WORKSPACEDIR/src

# if indigo:
sudo apt-get -y install ros-indigo-hector-quadrotor-demo
# if kinetic:
#sudo apt-get -y install ros-kinetic-hector-quadrotor-demo
#sudo apt-get -y install ros-kinetic-hector-quadrotor-description ros-kinetic-hector-quadrotor-gazebo ros-kinetic-hector-quadrotor-teleop ros-kinetic-hector-quadrotor-gazebo-plugins
sudo apt-get -y install ros-kinetic-hector-localization ros-kinetic-hector-gazebo ros-kinetic-hector-models ros-kinetic-hector-slam


# kinetic from source:
git clone -b kinetic-devel https://github.com/tu-darmstadt-ros-pkg/hector_quadrotor.git
# run the hector_quadrotor.rosinstall file (see: http://wiki.ros.org/rosinstall
#                                                http://answers.ros.org/question/9213/how-exactly-does-rosinstall-work/ )
#sudo apt-get -y install python-rosinstall
#rosinstall . hector_quadrotor.rosinstall # <-- this has issues with . as given directory... maybe supposed to be just that file run at src??

# from the hector_quadrotor.rosinstall file:
# (hector_quadrotor_pose_estimation requires hector_pose_estimation)
git clone -b catkin https://github.com/tu-darmstadt-ros-pkg/hector_localization.git
git clone -b kinetic-devel https://github.com/tu-darmstadt-ros-pkg/hector_gazebo.git
git clone -b kinetic-devel https://github.com/tu-darmstadt-ros-pkg/hector_models.git
# additional from the tutorials.rosinstall file:
git clone -b catkin https://github.com/tu-darmstadt-ros-pkg/hector_slam.git

# hector_localization/hector_pose_estimation_core requires geographic_msgs
sudo apt-get -y install ros-kinetic-geographic-msgs
# hector_quadrotor/hector_quadrotor_interface requires hardware_interface (part of ros_control)
sudo apt-get -y install ros-kinetic-hardware-interface
# hector_quadrotor/hector_quadrotor_interface requires controller_interface... (part of ros_control)
sudo apt-get -y install ros-kinetic-ros-control
# hector_quadrotor/hector_quadrotor_controller_gazebo requires gazebo-ros-control
sudo apt-get -y install ros-kinetic-gazebo-ros-control


sudo apt-get -y install mercurial meld
cd $WORKSPACEDIR
hg clone https://bitbucket.org/osrf/gazebo gazebo
cd gazebo
hg pull && hg update gazebo7_7.4.0



# now, fixing errors that catkin_make would otherwise give...

#

#now, catkin_make this bad boy! :)
su - $SCRIPTUSER -c "source /home/$SCRIPTUSER/.bashrc; cd $WORKSPACEDIR; /opt/ros/$ROSVERSION/bin/catkin_make;"




# note: trying to run

# gives the following error after not too long...
#gzserver: /build/ogre-1.9-mqY1wq/ogre-1.9-1.9.0+dfsg1/OgreMain/src/OgreRenderSystem.cpp:546: virtual void Ogre::RenderSystem::setDepthBufferFor(Ogre::RenderTarget*): Assertion `bAttached && "A new DepthBuffer for a RenderTarget was created, but after creation" "it says it's incompatible with that RT"' failed.
#Aborted (core dumped)
# *** this is apparently because we're running this in a virtual machine, and can be solved by "setting fsaa to 0"
# (see: https://bitbucket.org/osrf/gazebo/issues/1837/vmware-rendering-z-ordering-appears-random
#       https://bitbucket.org/osrf/gazebo/src/e08dcb5fe679f8d37857ba956d773fd80d3d7fb4/gazebo/rendering/Camera.cc?fileviewer=file-view-default#Camera.cc-1539 )
# but, basically, this requires upgrading gazebo -- luckily, we can get newer packages from the gazebo ppa
# ...unluckily, this doesn't seem to solve the issue under the VM



