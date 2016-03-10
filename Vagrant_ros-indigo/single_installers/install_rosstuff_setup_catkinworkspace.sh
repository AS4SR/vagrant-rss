#!/bin/bash -e

#
# in the initialization process for vagrant, this bash script is run as user 'root' from /vagrant
#

echo "Start of install_rosstuff_setup_catkinworkspace.sh script!"

#
# NOTE: this file does the following:
# (ROS indigo is pre-installed on the "shadowrobot/ros-indigo-desktop-trusty64" base box)
# install gnome-terminal for multiscript*.py runs
# install rosbridge
# install turtlebot libraries
# install (SD-Robot-Vision / ua_ros_p3dx) libraries for ./rss_git/contrib/p3dx_gazebo_mod
# set up catkin workspace
# install ROSARIA
# install deps for MobileSim and MobileSim
# install python WebSocket library
#

#
# get user directory
#

# if we get an input parameter (username) then use it, else use default 'vagrant'
if [ $# -lt 1 ]
then
    echo "Single username not given as commandline argument. Using default."
    SCRIPTUSER="vagrant"
else
    echo "Username given as commandline argument."
    SCRIPTUSER=$1
fi
echo "Will be using user $SCRIPTUSER and directories at and under /home/$SCRIPTUSER..."

#
# get -f (force) if given -- NOTE: WILL -NOT- REMOVE OR FORCE-REINSTALL ROSARIA!!!
#

# if we get an input parameter (username) then use it, else use default 'vagrant'
if [ $# -eq 2 ] && [ "$2" == "-f" ]
then
    echo "-f (force) commandline argument given. Forcing install of all compiled-from-source components."
    FORCE=$2
else
    FORCE=
fi

#
# check for installation
#

MOBILESIM_FOUND=`MobileSim --help | grep -m 1 "MobileSim 0.7.3" | wc -l`
if [ $MOBILESIM_FOUND -eq 1 ]
then
    echo "MobileSim 0.7.3 already installed!"
fi

WS4PY_FOUND=`python -c "import pkg_resources; print(pkg_resources.get_distribution('ws4py').version)" | grep -m 1 -o "0.3.5" | wc -l`
# pkg_resources should give '0.3.5'
# grep should find a match and repeat it
# and wc -l should give 1 if ws4py 0.3.5 was found

if [ $WS4PY_FOUND -eq 1 ]
then
    echo "ws4py 0.3.5 already installed!"
fi

#
# run installation + upgrades
#

# update all packages, because "gah!" otherwise, especially for 'rosdep' stuff later
sudo apt-get -y update
sudo apt-get -y upgrade

# note: this will install to the home directory of whichever user is calling the script
# so, if this script is called as user 'vagrant'
# (e.g., "sudo -u vagrant /vagrant/single_installers/install_rosstuff_setup_catkinworkspace.sh")
# then this will install under /home/vagrant
# (technically /home/vagrant/catkin_ws and catkin_ws/src

# directory should exist, but just to make sure...
sudo -u $SCRIPTUSER mkdir -p /home/$SCRIPTUSER/catkin_ws/src

# remove devel and build directories if exist already (want to catkin_make from scratch)
if [ "$FORCE" == "-f" ]
then
    rm -rf /home/$SCRIPTUSER/catkin_ws/devel
    rm -rf /home/$SCRIPTUSER/catkin_ws/build
fi

# install gnome-terminal for multiscript*.py runs
sudo apt-get -y install gnome-terminal

# install rosbridge
sudo apt-get -y install ros-indigo-rosbridge-server

# install turtlebot libraries
sudo apt-get -y install ros-indigo-turtlebot ros-indigo-turtlebot-interactions ros-indigo-turtlebot-apps ros-indigo-turtlebot-simulator ros-indigo-turtlebot-msgs ros-indigo-joy ros-indigo-create-description ros-indigo-kobuki-description ros-indigo-kobuki-node ros-indigo-rocon-app-manager ros-indigo-kobuki-bumper2pc ros-indigo-turtlebot-capabilities ros-indigo-openni2-launch libboost-python-dev ros-indigo-moveit-full

# install (SD-Robot-Vision / ua_ros_p3dx) libraries for ./rss_git/contrib/p3dx_gazebo_mod
sudo apt-get -y install ros-indigo-controller-manager-tests
sudo apt-get -y install ros-indigo-gazebo-ros-control ros-indigo-ros-controllers
# then install the p3dx gazebo model from github
cd /home/$SCRIPTUSER/catkin_ws/src
# if need to force, then remove old directory first
if [ "$FORCE" == "-f" ]
then
    rm -rf PioneerModel
fi
if [ ! -d PioneerModel ]
then
    sudo -u $SCRIPTUSER git clone https://github.com/SD-Robot-Vision/PioneerModel.git
fi
# if need to force, then remove old directory first
if [ "$FORCE" == "-f" ]
then
    rm -rf p3dx_mover
fi
if [ ! -d p3dx_mover ]
then
    sudo -u $SCRIPTUSER git clone https://github.com/SD-Robot-Vision/p3dx_mover.git
fi
# PioneerModel/p3dx_control requires controller_manager to compile

# set up catkin workspace
cd /home/$SCRIPTUSER
sudo -u $SCRIPTUSER mkdir -p catkin_ws/src/rss_work
su - $SCRIPTUSER -c "source /home/$SCRIPTUSER/.bashrc; cd /home/$SCRIPTUSER/catkin_ws/src; source /opt/ros/indigo/setup.bash; /opt/ros/indigo/bin/catkin_init_workspace; cd ..; /opt/ros/indigo/bin/catkin_make;"
sudo -u $SCRIPTUSER echo "source /opt/ros/indigo/setup.bash" >> /home/$SCRIPTUSER/.bashrc
sudo -u $SCRIPTUSER echo "source /home/$SCRIPTUSER/catkin_ws/devel/setup.bash" >> /home/$SCRIPTUSER/.bashrc
#sudo chown -R $SCRIPTUSER:$SCRIPTUSER /home/$SCRIPTUSER/.bashrc

# install ROSARIA
cd /home/$SCRIPTUSER/catkin_ws/src
# do NOT attempt to force rosaria if it's been installed previously! could cause serious issues (esp. with Aria and libaria!)
if [ ! -d rosaria ]
then
    sudo -u $SCRIPTUSER git clone https://github.com/amor-ros-pkg/rosaria.git
    cd rosaria
    # roll back to earlier version (/cmd_vel as pub-sub)
    sudo -u $SCRIPTUSER git checkout d58a244fc50bba568da57a828c9121c83a19284d
    su - $SCRIPTUSER -c "source /home/$SCRIPTUSER/.bashrc; cd /home/$SCRIPTUSER/catkin_ws; source devel/setup.bash; rosdep update; rosdep -y install rosaria; /opt/ros/indigo/bin/catkin_make;"
    # must run "rosdep update" and "rosdep install rosaria" as $SCRIPTUSER (non-root user)
    # sudo rosdep fix-permissions # if was root, would then need to run 'rosdep update' again without sudo
fi

# install deps for MobileSim and MobileSim
mkdir -p ~/initdeps
cd ~/initdeps
sudo apt-get -y install lib32z1 lib32ncurses5 lib32bz2-1.0 xfonts-100dpi
sudo apt-get -y install wget
if [ "$FORCE" == "-f" ] || [ ! -f mobilesim_0.7.3+ubuntu12+gcc4.6_amd64.deb ]
then
    wget http://robots.mobilerobots.com/MobileSim/download/current/mobilesim_0.7.3+ubuntu12+gcc4.6_amd64.deb
fi
if [ "$FORCE" == "-f" ] || [ $MOBILESIM_FOUND -eq 0 ]
then
    sudo dpkg -i mobilesim_0.7.3+ubuntu12+gcc4.6_amd64.deb
fi

# install python WebSocket library
mkdir -p ~/initdeps/rosbridgeclient
cd ~/initdeps/rosbridgeclient
# if need to force, then remove old directory first
if [ "$FORCE" == "-f" ]
then
    rm -rf WebSocket-for-Python
fi
if [ ! -d WebSocket-for-Python ]
then
    git clone https://github.com/Lawouach/WebSocket-for-Python.git
fi
cd WebSocket-for-Python
if [ "$FORCE" == "-f" ] || [ $WS4PY_FOUND -eq 0 ]
then
    sudo python setup.py install
fi

echo "End of install_rosstuff_setup_catkinworkspace.sh script!"
