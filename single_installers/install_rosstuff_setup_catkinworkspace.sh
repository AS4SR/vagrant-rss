#!/bin/bash -e
# Copyright by California Institute of Technology, University of Cincinnati
# All rights reserved. See LICENSE file at:
# https://github.com/cmcghan/vagrant-rss

#
# in the initialization process for vagrant, this bash script is run as user 'root' from /vagrant
#

echo "Start of install_rosstuff_setup_catkinworkspace.sh script!"
echo "input arguments: ROSVERSION [SCRIPTUSER] [WORKSPACEDIR] [-f]"
echo "(note: optional input arguments in [])"
echo "(note: there is no default ROSVERSION. Acceptable inputs are: indigo jade kinetic)"
echo "(note: default [SCRIPTUSER] is \"vagrant\")"
echo "(note: SCRIPTUSER must be given as an argument for WORKSPACEDIR to be read and accepted from commandline)"
echo "(note: default [WORKSPACEDIR] is \"/home/\$SCRIPTUSER/catkin_ws\")"
echo "WORKSPACEDIR must specify the absolute path of the directory"
echo "-f sets FORCE=-f and will force a (re)install of all compiled-from-source components."

#
# NOTE: this file does the following:
# (does NOT install ROS indigo, as ROS indigo is pre-installed on the "shadowrobot/ros-indigo-desktop-trusty64" base box)
# (if requested, installs ROS jade on "ubuntu/trusty64" (add servers to apt-get list, add key, then install))
# (if requested, installs ROS kinetic on "ubuntu/xenial64" (add servers to apt-get list, add key, then install))
# installs gnome-terminal for multiscript*.py runs
# installs rosbridge
# installs turtlebot libraries (-=currently may be limited for jade!!!=-)
# installs (SD-Robot-Vision / ua_ros_p3dx) libraries for ./rss_git/contrib/p3dx_gazebo_mod
# sets up catkin workspace
# installs ROSARIA
# installs deps for MobileSim and installs MobileSim
# installs python WebSocket library
#

#
# find O/S codename
# see: http://www.ros.org/reps/rep-0003.html
#      http://www.unixtutorial.org/commands/lsb_release/
#      http://unix.stackexchange.com/questions/104881/remove-particular-characters-from-a-variable-using-bash
#
#UCODENAME=`lsb_release -c | sed 's/Codename:\t//g'`
# cleaner version from ROS install instructions:
UCODENAME=`lsb_release -sc`
echo "Ubuntu version is: $UCODENAME"
if [ $UCODENAME == "trusty" ]; then
    ;
elif [ $UCODENAME == "xenial" ]; then
    ;
else
    echo "ERROR: Unknown Ubuntu version."
    echo "Currently, install_rosstuf_setup_catkinworkspace.sh supports Ubuntu 14.04 trusty and Ubuntu 16.04 xenial only."
    echo "Exiting."
    exit
fi

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
# if we get an input parameter (username) then use it, else use default 'vagrant'
# get -f (force) if given -- NOTE: WILL -NOT- REMOVE OR FORCE-REINSTALL ROSARIA!!!
if [ $# -lt 1 ]; then
    echo "ERROR: No ROS version given as commandline argument. Exiting."
    exit
else # at least 1 (possibly 4) argument(s) at commandline...
    # check against O/S argument, kinetic does not demand support for 14.04, or indigo/jade for 16.04...
    echo "Commandline argument 1 is: $1"
    if [ $1 == "indigo" ] && [ $UCODENAME == "trusty" ]; then
        ROSVERSION="indigo"
    elif [ $1 == "jade" ] && [ $UCODENAME == "trusty" ]; then
        ROSVERSION="jade"
    elif [ $1 == "kinetic" ] && [ $UCODENAME == "xenial" ]; then
        ROSVERSION="kinetic"
    else
        echo "ERROR: Unknown ROS version given as commandline argument -or- ROS version does not match O/S."
        echo "Currently, install_deps.sh supports trusty with indigo and jade only, xenial with kinetic only."
        echo "Exiting."
        exit
    fi
    # older/original code follows, commented-out, can be removed:
    #if [ "$1" == "indigo" ]; then
    #    ROSVERSION=indigo
    #elif [ "$1" == "jade" ]; then
    #    ROSVERSION=jade
    #else
    #    echo "ERROR: Unknown ROS version given as commandline argument. Exiting."
    #    exit
    #fi
    echo "ROS version is $ROSVERSION."
    if [ $# -lt 2 ]; then
        echo "Single username not given as commandline argument. Using default of '$SCRIPTUSER'."
    else # at least 2 (possibly more) arguments at commandline...
        if [ "$2" == "-f" ]; then # -f is last argument at commandline...
            echo "-f (force) commandline argument given."
            FORCE=$2
            echo "Default user and workspace directory path will be used."
        else # SCRIPTUSER should be argument #2
            # but we need to / should check against the users that have home directories / can log in
            HOMEDIRFORUSER_FOUND=`ls -1 /home | grep -m 1 -o "$2" | wc -l`
            # grep should find a match and repeat it
            # and wc -l should give 1 if argument #2 is a username that has a home directory associated with it
            if [ $HOMEDIRFORUSER_FOUND -eq 1 ]; then
                echo "Username given as commandline argument."
                SCRIPTUSER=$2
            else # already checked for a -f, and not a user... (note: WORKSPACEDIR not allowed to be given without SCRIPTUSER argument)
                echo "Bad username given as commandline argument. Using default username."
            fi
            if [ $# -lt 3 ]; then
                echo "Workspace not given as commandline argument. Using default of '$WORKSPACEDIR'."
            else # at least 3 (possibly more) arguments at commandline...
                if [ "$3" == "-f" ]; then # -f is last argument at commandline...
                    echo "-f (force) commandline argument given."
                    FORCE=$3
                    echo "Default workspace directory path will be used."
                else # WORKSPACEDIR should be argument #3
                    echo "Workspace directory given as commandline argument."
                    WORKSPACEDIR=$3
                    if [ $# -gt 3 ] && [ "$4" == "-f" ]; then # at least 4 (possibly more) arguments at commandline...
                        echo "-f (force) commandline argument given."
                        FORCE=$4
                    fi
                fi
            fi
        fi
    fi
fi
echo "Will be using user $SCRIPTUSER and directories at and under /home/$SCRIPTUSER..."
echo "Will be setting up catkin workspace under $WORKSPACEDIR..."
if [ "$FORCE" -eq "-f" ]; then
    echo "Forcing install of all compiled-from-source components."
fi

#
# check for installation
#

MOBILESIM_FOUND=`MobileSim --help | grep -m 1 "MobileSim 0.7.3" | wc -l`
if [ $MOBILESIM_FOUND -eq 1 ]; then
    echo "MobileSim 0.7.3 already installed!"
fi
# can also find via: $ whereis MobileSim

WS4PY_FOUND=`python -c "import pkg_resources; print(pkg_resources.get_distribution('ws4py').version)" | grep -m 1 -o "0.3.5" | wc -l`
# pkg_resources should give '0.3.5'
# grep should find a match and repeat it
# and wc -l should give 1 if ws4py 0.3.5 was found
if [ $WS4PY_FOUND -eq 1 ]; then
    echo "ws4py 0.3.5 already installed!"
fi
# longer test from within python:
# >>> from ws4py.client.threadedclient import WebSocketClient
# >>> testclient = WebSocketClient('ws://localhost:9090/')

#
# run installation + upgrades
#

# update all packages, because "gah!" otherwise, especially for 'rosdep' stuff later
sudo apt-get -y update
sudo apt-get -y upgrade

sudo apt-get -y install wget curl # for wget and possible curl use below

#
# install ROS indigo OR jade OR kinetic (for "ubuntu/trusty64" box)
# --> can comment out for "shadowrobot/ros-indigo-desktop-trusty64" box (ROS indigo is pre-installed on that Vagrantbox)
#
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver hkp://pool.sks-keyservers.net:80 --recv-key 0xB01FA116
sudo apt-get -y update
sudo apt-get -y install ros-$ROSVERSION-desktop-full # will not hurt anything if preinstalled
# if rosdep sources file list has -not- already been initialized:
if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then # rosdep init this
    sudo rosdep init
    su - $SCRIPTUSER -c "rosdep update;"
fi
sudo apt-get -y install python-rosinstall

sudo sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
mkdir -p initdeps
cd ~/initdeps
wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
sudo apt-get -y update
if [ "$ROSVERSION" -eq "indigo" ]; then # install gazebo2, too
    sudo apt-get -y install gazebo2 gazebo2-dbg ros-$ROSVERSION-gazebo-ros
elif [ "$ROSVERSION" -eq "jade" ]; then # install gazebo5, too
    sudo apt-get -y install gazebo5 libgazebo5-dev
    # set up gazebo 5.1 via:
    sudo cp -r /usr/share/gazebo-5.0/media /usr/share/gazebo-5.1/
    sudo cp -r /usr/share/gazebo-5.0/worlds /usr/share/gazebo-5.1/
    # then source the gazebo directories and run gazebo...
    #cd /usr/share/gazebo-5.1 ? cd /usr/share/gazebo-5.0 ?
    #source /usr/share/gazebo-5.1/setup.sh 
    #gazebo --verbose
    # ...and then grab all the models from online that you want!
elif [ "$ROSVERSION" -eq "kinetic" ]; then # install gazebo7, too
    sudo apt-get -y install gazebo7 libgazebo7-dev
fi

#
#
# *** !!! ***
# need to install above in separate root-called script, because the rest-below basically needs non-root for install process
# ...or should(??). I -really- need to fix this file...
# *** !!! ***
#
#

# note: this will install to the home directory of user $SCRIPTUSER
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
sudo apt-get -y install ros-$ROSVERSION-rosbridge-server

# install turtlebot libraries
sudo apt-get -y install ros-$ROSVERSION-joy libboost-python-dev
sudo apt-get -y install ros-$ROSVERSION-openni2-launch
if [ "$ROSVERSION" -eq "indigo" ]; then
    sudo apt-get -y install ros-$ROSVERSION-turtlebot ros-$ROSVERSION-turtlebot-interactions ros-$ROSVERSION-turtlebot-apps ros-$ROSVERSION-turtlebot-simulator ros-$ROSVERSION-turtlebot-msgs  ros-$ROSVERSION-create-description ros-$ROSVERSION-kobuki-description ros-$ROSVERSION-kobuki-node ros-$ROSVERSION-rocon-app-manager ros-$ROSVERSION-kobuki-bumper2pc ros-$ROSVERSION-turtlebot-capabilities ros-$ROSVERSION-moveit-full
    # said-also-required from: http://wiki.ros.org/turtlebot/Tutorials/indigo/Debs%20Installation
    # sudo apt-get -y install ros-indigo-kobuki-ftdi ros-indigo-rocon-remocon # look like they may be included as auto-dependencies? need to check
    # sudo apt-get -y ros-indigo-rocon-qt-library ros-indigo-ar-track-alvar-msgs # look like they may be included as auto-dependencies? need to check
elif [ "$ROSVERSION" -eq "jade" ]; then
    cd /home/$SCRIPTUSER/catkin_ws/src
    if [ "$FORCE" == "-f" ]; then
        rm -rf turtlebot
        rm -rf turtlebot_interactions
        rm -rf turtlebot_apps
        rm -rf turtlebot_simulator
        rm -rf turtlebot_msgs
        rm -rf turtlebot_create
        rm -rf kobuki
        rm -rf kobuki_msgs
        rm -rf yujin_ocs
        rm -rf yocs_msgs
        rm -rf kobuki_core
        rm -rf rocon_app_platform
        rm -rf moveit_pr2
    fi
    if [ ! -d turtlebot ]; then
        sudo -u $SCRIPTUSER git clone https://github.com/turtlebot/turtlebot.git #ros-jade-turtlebot, ros-jade-turtlebot-capabilities
    fi
    if [ ! -d turtlebot_interactions ]; then
        sudo -u $SCRIPTUSER git clone https://github.com/turtlebot/turtlebot_interactions.git #ros-jade-turtlebot-interactions
    fi
    if [ ! -d turtlebot_apps ]; then
        sudo -u $SCRIPTUSER git clone https://github.com/turtlebot/turtlebot_apps.git #ros-jade-turtlebot-apps
    fi
    if [ ! -d turtlebot_simulator ]; then
        sudo -u $SCRIPTUSER git clone https://github.com/turtlebot/turtlebot_simulator.git #ros-jade-turtlebot-simulator
    fi
    if [ ! -d turtlebot_msgs ]; then
        sudo -u $SCRIPTUSER git clone https://github.com/turtlebot/turtlebot_msgs.git #ros-jade-turtlebot-msgs
    fi
    if [ ! -d turtlebot_create ]; then
        sudo -u $SCRIPTUSER git clone https://github.com/turtlebot/turtlebot_create.git #(includes) ros-jade-create-description
    fi
    if [ ! -d kobuki ]; then
        sudo -u $SCRIPTUSER git clone https://github.com/yujinrobot/kobuki.git #(includes) ros-jade-kobuki-description, ros-jade-kobuki-node, ros-jade-kobuki-bumper2pc
    fi
    sudo apt-get -y install ros-$ROSVERSION-ecl-core # for kobuki_keyop, need ecl_exceptions
    if [ ! -d kobuki_msgs ]; then
        sudo -u $SCRIPTUSER git clone https://github.com/yujinrobot/kobuki_msgs.git # for kobuki_keyop, need kobuki_msgs
    fi
    if [ ! -d yujin_ocs ]; then
        sudo -u $SCRIPTUSER git clone https://github.com/yujinrobot/yujin_ocs.git # for kobuki_controller_tutorial, need yocs_controllers
    fi
    if [ ! -d yocs_msgs ]; then
        sudo -u $SCRIPTUSER git clone https://github.com/yujinrobot/yocs_msgs.git # for yocs_joyop, need yocs_msgs
    fi
    sudo apt-get -y install ros-$ROSVERSION-ar-track-alvar # for yocs_ar_marker_tracking, need ar_track_alvar_msgs
    sudo apt-get -y install ros-$ROSVERSION-base-local-planner # for yocs_navi_toolkit, need base_local_planner
    sudo apt-get -y install ros-$ROSVERSION-move-base-msgs # for yocs_navigator, need move_base_msgs
    if [ ! -d kobuki_core ]; then
        sudo -u $SCRIPTUSER git clone https://github.com/yujinrobot/kobuki_core.git # for kobuki_auto_docking, need kobuki_dock_drive
    fi
    sudo apt-get -y install libusb-dev libftdi-dev # for kobuki_ftdi, needs <usb.h> and <ftdi.h>
    sudo apt-get -y install ros-$ROSVERSION-ecl-mobile-robot # for kobuki_driver, need ecl_mobile_robot
    if [ ! -d rocon_app_platform ]; then
        sudo -u $SCRIPTUSER git clone https://github.com/robotics-in-concert/rocon_app_platform.git #ros-jade-rocon-app-manager
    fi
    sudo apt-get -y install ros-$ROSVERSION-moveit # should include -core, -ros, -planners
    #sudo apt-get -y install ros-$ROSVERSION-moveit-core ros-$ROSVERSION-moveit-ros ros-$ROSVERSION-moveit-planners-ompl #ros-jade-moveit-full
    if [ ! -d moveit_pr2 ]; then
        sudo -u $SCRIPTUSER git clone https://github.com/ros-planning/moveit_pr2.git #ros-jade-moveit-full
    fi
    sudo apt-get -y install ros-$ROSVERSION-pr2-mechanism-msgs ros-$ROSVERSION-pr2-controllers-msgs # for pr2_moveit_plugins, need pr2_mechanism_msgs, pr2_controllers_msgs
elif [ "$ROSVERSION" -eq "kinetic" ]; then
    sudo apt-get -y install ros-$ROSVERSION-turtlebot ros-$ROSVERSION-turtlebot-interactions ros-$ROSVERSION-turtlebot-apps ros-$ROSVERSION-turtlebot-simulator ros-$ROSVERSION-turtlebot-msgs  ros-$ROSVERSION-create-description ros-$ROSVERSION-kobuki-description ros-$ROSVERSION-kobuki-node ros-$ROSVERSION-rocon-app-manager ros-$ROSVERSION-kobuki-bumper2pc ros-$ROSVERSION-turtlebot-capabilities ros-$ROSVERSION-moveit-full
    # packages that don't exist as of 2016-10-19:
    # ros-kinetic-moveit-full
    # see issues list: https://github.com/ros-planning/moveit/issues/18

#
# *** mainly untested git pulls and compiles below!!! ***
#

    # said-also-required from: http://wiki.ros.org/turtlebot/Tutorials/indigo/Debs%20Installation
    # sudo apt-get -y ros-$ROSVERSION-rocon-qt-library ros-$ROSVERSION-ar-track-alvar-msgs # not included as auto-dependencies above
    # latter is handled by specific package install below
    cd /home/$SCRIPTUSER/catkin_ws/src
    if [ "$FORCE" == "-f" ]; then
        #rm -rf rocon_qt_gui
        #rm -rf 0.7-indigo
        rm -rf moveit
        rm -rf moveit_pr2
        rm -rf pr2_controllers
        rm -rf pr2_mechanism_msgs
        rm -rf pr2_mechanism
    fi
    sudo apt-get -y install ros-$ROSVERSION-ar-track-alvar # for yocs_ar_marker_tracking, need ar_track_alvar_msgs
    # ros-indigo-rocon-qt-library ???? -- is part of rocon-qt-gui; either need indigo branch or goes w/renaming:
    #if [ ! -d rocon_qt_gui ]; then
    #sudo -u $SCRIPTUSER git clone https://github.com/robotics-in-concert/rocon_qt_gui.git # devel branch
    #fi
    #if [ ! -d 0.7-indigo ]; then
    #sudo -u $SCRIPTUSER git clone https://github.com/robotics-in-concert/rocon_qt_gui/tree/release/0.7-indigo.git # indigo version
    #fi
    # ros-kinetic-moveit-full:
    # ros-kinetic-moveit-core ros-kinetic-moveit-ros ros-kinetic-moveit-planners-ompl
    if [ ! -d moveit ]; then
        sudo -u $SCRIPTUSER git clone https://github.com/ros-planning/moveit.git #ros-kinetic-moveit-full
    fi
    # optional(?) with ros-kinetic-moveit-full:
    if [ ! -d moveit_pr2 ]; then
        #sudo -u $SCRIPTUSER git clone https://github.com/ros-planning/moveit_pr2.git #ros-"indigo"-moveit-full (for jade)
        sudo -u $SCRIPTUSER git clone -b kinetic-devel https://github.com/ros-planning/moveit_pr2.git #ros-kinetic-moveit-full
    fi
    # for pr2_moveit_plugins, need pr2_mechanism_msgs, pr2_controllers_msgs
    if [ ! -d pr2_controllers ]; then
    sudo -u $SCRIPTUSER git clone https://github.com/pr2/pr2_controllers.git # for pr2_moveit_plugins, need pr2_controllers_msgs
    fi
    if [ ! -d pr2_mechanism_msgs ]; then
    sudo -u $SCRIPTUSER git clone https://github.com/PR2/pr2_mechanism_msgs.git # for pr2_moveit_plugins, need pr2_mechanism_msgs
    fi
    if [ ! -d pr2_mechanism ]; then
    sudo -u $SCRIPTUSER git clone https://github.com/pr2/pr2_mechanism.git # adding pr2_mechanism, just in case
    fi
fi

# install (SD-Robot-Vision / ua_ros_p3dx) libraries for ./rss_git/contrib/p3dx_gazebo_mod
sudo apt-get -y install ros-$ROSVERSION-controller-manager-tests
sudo apt-get -y install ros-$ROSVERSION-ros-controllers
if [ "$ROSVERSION" -eq "indigo" ]; then
    sudo apt-get -y install ros-$ROSVERSION-gazebo-ros-control
elif [ "$ROSVERSION" -eq "jade" ]; then
    sudo apt-get -y install ros-$ROSVERSION-gazebo-ros-pkgs # does not include ros-jade-gazebo-ros-control yet... do we need it? if we do, then:
    echo "ROS $ROSVERSION doesn't have ros-$ROSVERSION-ros-control package in ros-$ROSVERSION-gazebo-ros-pkgs (yet). Source install via 'git clone' now:"
    cd /home/$SCRIPTUSER/catkin_ws/src    
    if [ "$FORCE" == "-f" ]; then
        rm -rf gazebo_ros_pkgs
    fi
    sudo -s $SCRIPTUSER git clone https://github.com/ros-simulation/gazebo_ros_pkgs.git # includes gazebo_ros_control...
    sudo apt-get -y install ros-jade-ros-control # for gazebo_ros_control, need transmission_interface
elif [ "$ROSVERSION" -eq "kinetic" ]; then
    sudo apt-get -y install ros-$ROSVERSION-gazebo-ros-control
fi
# then install the p3dx gazebo model from github
cd /home/$SCRIPTUSER/catkin_ws/src
# if need to force, then remove old directory first
if [ "$FORCE" == "-f" ]; then
    rm -rf PioneerModel
fi
if [ ! -d PioneerModel ]; then
    sudo -u $SCRIPTUSER git clone https://github.com/SD-Robot-Vision/PioneerModel.git
fi
# if need to force, then remove old directory first
if [ "$FORCE" == "-f" ]; then
    rm -rf p3dx_mover
fi
if [ ! -d p3dx_mover ]; then
    sudo -u $SCRIPTUSER git clone https://github.com/SD-Robot-Vision/p3dx_mover.git
fi
# PioneerModel/p3dx_control requires controller_manager to compile

# set up catkin workspace
cd /home/$SCRIPTUSER
sudo -u $SCRIPTUSER mkdir -p catkin_ws/src/rss_work
su - $SCRIPTUSER -c "source /home/$SCRIPTUSER/.bashrc; cd /home/$SCRIPTUSER/catkin_ws/src; source /opt/ros/$ROSVERSION/setup.bash; /opt/ros/$ROSVERSION/bin/catkin_init_workspace; cd ..; /opt/ros/$ROSVERSION/bin/catkin_make;"
sudo -u $SCRIPTUSER echo "source /opt/ros/$ROSVERSION/setup.bash" >> /home/$SCRIPTUSER/.bashrc
sudo -u $SCRIPTUSER echo "source /home/$SCRIPTUSER/catkin_ws/devel/setup.bash" >> /home/$SCRIPTUSER/.bashrc
#sudo chown -R $SCRIPTUSER:$SCRIPTUSER /home/$SCRIPTUSER/.bashrc

# install ROSARIA (reference: http://wiki.ros.org/ROSARIA/Tutorials/How%20to%20use%20ROSARIA )
cd /home/$SCRIPTUSER/catkin_ws/src
# do NOT attempt to force rosaria if it's been installed previously! could cause serious issues (esp. with Aria and libaria!)
# (Dependencies: genmsg -  if the make fails, Install package separately from here: https://github.com/ros/genmsg)
if [ ! -d rosaria ]
then
    sudo -u $SCRIPTUSER git clone https://github.com/amor-ros-pkg/rosaria.git
    cd rosaria
    # roll back to earlier version (/cmd_vel as pub-sub)
    sudo -u $SCRIPTUSER git checkout d58a244fc50bba568da57a828c9121c83a19284d
    # this checkout downgrades to a version of rosaria that does not
    # (a) require: chmod +x cfg/RosAria.cfg
    # (b) require: pubtopic change from /RosAria/cmd_vel to /cmd_vel
    su - $SCRIPTUSER -c "source /home/$SCRIPTUSER/.bashrc; cd /home/$SCRIPTUSER/catkin_ws; source devel/setup.bash; rosdep update; rosdep -y install rosaria; /opt/ros/$ROSVERSION/bin/catkin_make;"
    # must run "rosdep update" and "rosdep install rosaria" as $SCRIPTUSER (non-root user)
    # sudo rosdep fix-permissions # if was root, would then need to run 'rosdep update' again without sudo
fi

# install deps for MobileSim and MobileSim (references: http://robots.mobilerobots.com/wiki/MobileSim and http://robots.mobilerobots.com/MobileSim/download/current/README.html )
if [ $MOBILESIM_FOUND -eq 0 ]
then
    mkdir -p ~/initdeps
    cd ~/initdeps
    # If you are running Ubuntu 14.04 64-bit, install these packages first to resolve dependencies, just in case (these are useful for Matlab fonts and such, too)
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
fi

# install python WebSocket library (reference: https://ws4py.readthedocs.org/en/latest/sources/install/ )
mkdir -p ~/initdeps/rosbridgeclient
cd ~/initdeps/rosbridgeclient
# if need to force, then remove old directory first
if [ "$FORCE" == "-f" ]; then
    rm -rf "WebSocket-for-Python"
fi
if [ ! -d "WebSocket-for-Python" ]; then
    git clone "https://github.com/Lawouach/WebSocket-for-Python.git"
fi
cd "WebSocket-for-Python"
if [ "$FORCE" == "-f" ] || [ $WS4PY_FOUND -eq 0 ]; then
    sudo python setup.py install
fi

# install UWSim stuff
cd /home/$SCRIPTUSER/catkin_ws/src
sudo apt-get -y install python-urlgrabber ros-indigo-uwsim libdc1394-22 libdc1394-22-dev libdc1394-utils
if [ "$FORCE" == "-f" ]; then
    rm -rf freefloating_gazebo
    rm -rf freefloating_gazebo_demo
fi
if [ ! -d freefloating_gazebo ]; then
    sudo -u $SCRIPTUSER git clone https://github.com/freefloating-gazebo/freefloating_gazebo
fi
if [ ! -d freefloating_gazebo ]; then
    sudo -u $SCRIPTUSER git clone https://github.com/freefloating-gazebo/freefloating_gazebo_demo
fi
su - $SCRIPTUSER -c "source /home/$SCRIPTUSER/.bashrc; cd /home/$SCRIPTUSER/catkin_ws; source /opt/ros/$ROSVERSION/setup.bash; /opt/ros/$ROSVERSION/bin/catkin_make;"
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

# install USARSimROS + libraries
#sudo apt-get -y install ???
#cd /home/$SCRIPTUSER/initdeps/
#wget http://downloads.sourceforge.net/project/usarsim/usarsim-UDK/USARSimFull_UDKV1.2.zip
#unzip 
#cd /home/$SCRIPTUSER/catkin_ws/src
## if need to force, then remove old directory first
#if [ "$FORCE" == "-f" ]; then
#    rm -rf PioneerModel
#fi
#if [ ! -d PioneerModel ]; then
#    sudo -u $SCRIPTUSER git clone https://github.com/SD-Robot-Vision/PioneerModel.git
#fi

echo "End of install_rosstuff_setup_catkinworkspace.sh script!"
