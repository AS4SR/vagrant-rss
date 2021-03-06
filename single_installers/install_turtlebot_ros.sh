#!/bin/bash -e
# Copyright by California Institute of Technology, University of Cincinnati
# All rights reserved. See LICENSE file at:
# https://github.com/AS4SR/vagrant-rss

#
# in the initialization process for vagrant, this bash script is run as user 'root' from /vagrant
#

echo "Start of install_turtlebot_ros.sh script!"
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

# install turtlebot libraries
$ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-joy libboost-python-dev
$ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-openni2-launch
if [ "$ROSVERSION" == "indigo" ]; then
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-turtlebot ros-$ROSVERSION-turtlebot-interactions ros-$ROSVERSION-turtlebot-apps ros-$ROSVERSION-turtlebot-simulator ros-$ROSVERSION-turtlebot-msgs  ros-$ROSVERSION-create-description ros-$ROSVERSION-kobuki-description ros-$ROSVERSION-kobuki-node ros-$ROSVERSION-rocon-app-manager ros-$ROSVERSION-kobuki-bumper2pc ros-$ROSVERSION-turtlebot-capabilities ros-$ROSVERSION-moveit-full
    # said-also-required from: http://wiki.ros.org/turtlebot/Tutorials/indigo/Debs%20Installation
    # $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-indigo-kobuki-ftdi ros-indigo-rocon-remocon # look like they may be included as auto-dependencies? need to check
    # $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-indigo-rocon-qt-library ros-indigo-ar-track-alvar-msgs # look like they may be included as auto-dependencies? need to check
elif [ "$ROSVERSION" == "jade" ]; then
    cd $WORKSPACEDIR/src
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
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-ecl-core # for kobuki_keyop, need ecl_exceptions
    if [ ! -d kobuki_msgs ]; then
        sudo -u $SCRIPTUSER git clone https://github.com/yujinrobot/kobuki_msgs.git # for kobuki_keyop, need kobuki_msgs
    fi
    if [ ! -d yujin_ocs ]; then
        sudo -u $SCRIPTUSER git clone https://github.com/yujinrobot/yujin_ocs.git # for kobuki_controller_tutorial, need yocs_controllers
    fi
    if [ ! -d yocs_msgs ]; then
        sudo -u $SCRIPTUSER git clone https://github.com/yujinrobot/yocs_msgs.git # for yocs_joyop, need yocs_msgs
    fi
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-ar-track-alvar # for yocs_ar_marker_tracking, need ar_track_alvar_msgs
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-base-local-planner # for yocs_navi_toolkit, need base_local_planner
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-move-base-msgs # for yocs_navigator, need move_base_msgs
    if [ ! -d kobuki_core ]; then
        sudo -u $SCRIPTUSER git clone https://github.com/yujinrobot/kobuki_core.git # for kobuki_auto_docking, need kobuki_dock_drive
    fi
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh libusb-dev libftdi-dev # for kobuki_ftdi, needs <usb.h> and <ftdi.h>
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-ecl-mobile-robot # for kobuki_driver, need ecl_mobile_robot
    if [ ! -d rocon_app_platform ]; then
        sudo -u $SCRIPTUSER git clone https://github.com/robotics-in-concert/rocon_app_platform.git #ros-jade-rocon-app-manager
    fi
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-moveit # should include -core, -ros, -planners
    #$ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-moveit-core ros-$ROSVERSION-moveit-ros ros-$ROSVERSION-moveit-planners-ompl #ros-jade-moveit-full
    if [ ! -d moveit_pr2 ]; then
        sudo -u $SCRIPTUSER git clone https://github.com/ros-planning/moveit_pr2.git #ros-jade-moveit-full
    fi
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-pr2-mechanism-msgs ros-$ROSVERSION-pr2-controllers-msgs # for pr2_moveit_plugins, need pr2_mechanism_msgs, pr2_controllers_msgs
elif [ "$ROSVERSION" == "kinetic" ]; then
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-turtlebot ros-$ROSVERSION-turtlebot-interactions ros-$ROSVERSION-turtlebot-apps ros-$ROSVERSION-turtlebot-simulator ros-$ROSVERSION-turtlebot-msgs  ros-$ROSVERSION-create-description ros-$ROSVERSION-kobuki-description ros-$ROSVERSION-kobuki-node ros-$ROSVERSION-rocon-app-manager ros-$ROSVERSION-kobuki-bumper2pc ros-$ROSVERSION-turtlebot-capabilities #ros-$ROSVERSION-moveit-full
    # packages that don't exist as of 2016-10-19:
    # ros-kinetic-moveit-full
    # see issues list: https://github.com/ros-planning/moveit/issues/18
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-moveit # as of 2017-05-18, this will install almost every MoveIt! package necessary
    
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-ros-control ros-$ROSVERSION-ros-controllers # as of 2018-02-22, seems to fix the controller_manager giving warnings and not starting up (test via rosservice list | grep controller_manager)
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-gazebo-ros ros-$ROSVERSION-gazebo-ros-control # still need to also include this to actually be able to correctly load controller_manager and talk to gazebo controller plugins though
    
    #
    # the following seem to be necessary for some movement of the base for CRUMB project, thus probably also the "plain vanilla" turtlebot as well
    #

    # need differential drive controllers for most mobile robot base models, see:
    # http://gazebosim.org/tutorials?tut=ros_gzplugins
    # http://wiki.ros.org/diff_drive_controller
    # this is the top-level and sub-package controller packages, already included above:
    #sudo apt install ros-kinetic-ros-controllers ros-kinetic-diff-drive-controller
    # additional packages, see:
    # -- http://wiki.ros.org/turtlebot/Tutorials/indigo/Turtlebot%20Installation
    # -- http://wiki.ros.org/turtlebot_gazebo/Tutorials/indigo/Explore%20the%20Gazebo%20world
    sudo apt install ros-kinetic-turtlebot-rviz-launchers
    sudo apt install ros-kinetic-kobuki-ftdi ros-kinetic-ar-track-alvar-msgs

    # examples of Gazebo + turtlebot bringup are given here:
    # -- http://wiki.ros.org/turtlebot_gazebo/Tutorials/indigo/Gazebo%20Bringup%20Guide
    # -- http://sauravag.com/2016/10/how-to-setup-turtlebot-simulator-in-ros-with-gazebo/
    # for teleoperating the turtlebot:
    sudo apt install ros-kinetic-turtlebot-teleop
    sudo apt install ros-kinetic-kobuki-keyop
    
#
# *** mainly untested git pulls and compiles below!!! ***
#

    # said-also-required from: http://wiki.ros.org/turtlebot/Tutorials/indigo/Debs%20Installation
    # $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-rocon-qt-library ros-$ROSVERSION-ar-track-alvar-msgs # not included as auto-dependencies above
    # latter is handled by specific package install below
    #cd $WORKSPACEDIR/src
    #if [ "$FORCE" == "-f" ]; then
        #rm -rf moveit_pr2 # now available(?)
        #rm -rf pr2_controllers
        #rm -rf pr2_mechanism_msgs
        #rm -rf pr2_mechanism
    #fi
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-ar-track-alvar # for yocs_ar_marker_tracking, need ar_track_alvar_msgs
    # optional(?) with ros-kinetic-moveit:
    #if [ ! -d moveit_pr2 ]; then
    #    #sudo -u $SCRIPTUSER git clone https://github.com/ros-planning/moveit_pr2.git #ros-"indigo"-moveit-full (for jade)
    #    sudo -u $SCRIPTUSER git clone -b kinetic-devel https://github.com/ros-planning/moveit_pr2.git #ros-kinetic-moveit-full
    #fi
    #$ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-pr2-common # for pr2_msgs
    # for pr2_moveit_plugins, need pr2_mechanism_msgs, pr2_controllers_msgs
    #if [ ! -d pr2_controllers ]; then
    #sudo -u $SCRIPTUSER git clone https://github.com/pr2/pr2_controllers.git # for pr2_moveit_plugins, need pr2_controllers_msgs
    #fi
    #if [ ! -d pr2_mechanism_msgs ]; then
    #sudo -u $SCRIPTUSER git clone https://github.com/PR2/pr2_mechanism_msgs.git # for pr2_moveit_plugins, need pr2_mechanism_msgs
    #fi
    #if [ ! -d pr2_mechanism ]; then
    #sudo -u $SCRIPTUSER git clone https://github.com/pr2/pr2_mechanism.git # adding pr2_mechanism, just in case
    #fi
elif [ "$ROSVERSION" == "melodic" ]; then # turtlebot 2 has not been ported, but turtlebot 3 exists/has-been

    #
    # Turtlebot 2
    #


    # all are missing!
    # ros-$ROSVERSION-turtlebot ros-$ROSVERSION-turtlebot-interactions ros-$ROSVERSION-turtlebot-apps ros-$ROSVERSION-turtlebot-simulator ros-$ROSVERSION-turtlebot-msgs  ros-$ROSVERSION-create-description ros-$ROSVERSION-kobuki-description ros-$ROSVERSION-kobuki-node ros-$ROSVERSION-rocon-app-manager ros-$ROSVERSION-kobuki-bumper2pc ros-$ROSVERSION-turtlebot-capabilities

    #
    # the following seem to be necessary for some movement of the base for CRUMB project, thus probably also the "plain vanilla" turtlebot as well
    #

    # need differential drive controllers for most mobile robot base models, see:
    # http://gazebosim.org/tutorials?tut=ros_gzplugins
    # http://wiki.ros.org/diff_drive_controller
    # this is the top-level and sub-package controller packages, already included above:
    #sudo apt install ros-kinetic-ros-controllers ros-kinetic-diff-drive-controller
    # additional packages, see:
    # -- http://wiki.ros.org/turtlebot/Tutorials/indigo/Turtlebot%20Installation
    # -- http://wiki.ros.org/turtlebot_gazebo/Tutorials/indigo/Explore%20the%20Gazebo%20world
    #sudo apt install ros-kinetic-turtlebot-rviz-launchers
    #sudo apt install ros-kinetic-kobuki-ftdi ros-kinetic-ar-track-alvar-msgs

    # examples of Gazebo + turtlebot bringup are given here:
    # -- http://wiki.ros.org/turtlebot_gazebo/Tutorials/indigo/Gazebo%20Bringup%20Guide
    # -- http://sauravag.com/2016/10/how-to-setup-turtlebot-simulator-in-ros-with-gazebo/
    # for teleoperating the turtlebot:
    #sudo apt install ros-kinetic-turtlebot-teleop
    #sudo apt install ros-kinetic-kobuki-keyop


    # *** WORK IN PROGRESS BELOW! ***

    cd $WORKSPACEDIR/src
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
        sudo -u $SCRIPTUSER git clone https://github.com/turtlebot/turtlebot.git #ros-melodic-turtlebot, ros-melodic-turtlebot-capabilities
    fi
    if [ ! -d turtlebot_interactions ]; then
        sudo -u $SCRIPTUSER git clone https://github.com/turtlebot/turtlebot_interactions.git #ros-melodic-turtlebot-interactions
    fi
    if [ ! -d turtlebot_apps ]; then
        sudo -u $SCRIPTUSER git clone https://github.com/turtlebot/turtlebot_apps.git #ros-melodic-turtlebot-apps
    fi
    if [ ! -d turtlebot_simulator ]; then
        sudo -u $SCRIPTUSER git clone https://github.com/turtlebot/turtlebot_simulator.git #ros-melodic-turtlebot-simulator
    fi
    if [ ! -d turtlebot_msgs ]; then
        sudo -u $SCRIPTUSER git clone https://github.com/turtlebot/turtlebot_msgs.git #ros-melodic-turtlebot-msgs
    fi
    if [ ! -d turtlebot_create ]; then
        sudo -u $SCRIPTUSER git clone https://github.com/turtlebot/turtlebot_create.git #(includes) ros-melodic-create-description
    fi
    if [ ! -d kobuki ]; then
        sudo -u $SCRIPTUSER git clone https://github.com/yujinrobot/kobuki.git #(includes) ros-melodic-kobuki-description, ros-melodic-kobuki-node, ros-melodic-kobuki-bumper2pc
    fi
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-ecl-core # for kobuki_keyop, need ecl_exceptions
    #if [ ! -d kobuki_msgs ]; then
    #    sudo -u $SCRIPTUSER git clone https://github.com/yujinrobot/kobuki_msgs.git # for kobuki_keyop, need kobuki_msgs
    #fi
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-kobuki-msgs
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-kobuki-driver # for kobuki_node, need kobuki_driver
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-yujin-ocs # for kobuki_controller_tutorial, need yocs_controllers
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-yocs-msgs # for yocs_joyop, need yocs_msgs
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-ar-track-alvar # for yocs_ar_marker_tracking, need ar_track_alvar_msgs
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-base-local-planner # for yocs_navi_toolkit, need base_local_planner
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-move-base-msgs # for yocs_navigator, need move_base_msgs
    #if [ ! -d kobuki_core ]; then
    #    sudo -u $SCRIPTUSER git clone https://github.com/yujinrobot/kobuki_core.git # for kobuki_auto_docking, need kobuki_dock_drive
    #fi # *** THIS SEEMS TO HAVE ISSUES BECAUSE IS PLAIN CMAKE, WANTS catkin_make_isolated BECAUSE OF THIS ***
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-kobuki-dock-drive # for kobuki_auto_docking, need kobuki_dock_drive
    
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh libusb-dev libftdi-dev # for kobuki_ftdi, needs <usb.h> and <ftdi.h>
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-ecl-mobile-robot # for kobuki_driver, need ecl_mobile_robot
    if [ ! -d rocon_app_platform ]; then
        sudo -u $SCRIPTUSER git clone https://github.com/robotics-in-concert/rocon_app_platform.git #ros-jade-rocon-app-manager
    fi
    
    
    
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-moveit # should include -core, -ros, -planners
    #$ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-moveit-core ros-$ROSVERSION-moveit-ros ros-$ROSVERSION-moveit-planners-ompl #ros-jade-moveit-full
    #if [ ! -d moveit_pr2 ]; then
    #    sudo -u $SCRIPTUSER git clone https://github.com/ros-planning/moveit_pr2.git #ros-kinetic-moveit-full
    #fi
    #$ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-pr2-mechanism-msgs ros-$ROSVERSION-pr2-controllers-msgs # for pr2_moveit_plugins, need pr2_mechanism_msgs, pr2_controllers_msgs

    # *** WORK IN PROGRESS ABOVE! ***
    # seems to be okay now, though :)




    #
    # Turtlebot 3
    #

    # install necessary packages, see:
    # http://emanual.robotis.com/docs/en/platform/turtlebot3/pc_setup/#install-dependent-ros-packages
    # http://wiki.ros.org/Robots/TurtleBot

    #sudo apt-get install ros-kinetic-joy ros-kinetic-teleop-twist-joy ros-kinetic-teleop-twist-keyboard ros-kinetic-laser-proc ros-kinetic-rgbd-launch ros-kinetic-depthimage-to-laserscan ros-kinetic-rosserial-arduino ros-kinetic-rosserial-python ros-kinetic-rosserial-server ros-kinetic-rosserial-client ros-kinetic-rosserial-msgs ros-kinetic-amcl ros-kinetic-map-server ros-kinetic-move-base ros-kinetic-urdf ros-kinetic-xacro ros-kinetic-compressed-image-transport ros-kinetic-rqt-image-view ros-kinetic-gmapping ros-kinetic-navigation ros-kinetic-interactive-markers

    sudo apt install ros-$ROSVERSION-turtlebot3 ros-$ROSVERSION-turtlebot3-msgs ros-$ROSVERSION-turtlebot3-simulations ros-$ROSVERSION-turtlebot3-applications ros-$ROSVERSION-turtlebot3-autorace ros-$ROSVERSION-turtlebot3-description ros-$ROSVERSION-turtlebot3-gazebo ros-$ROSVERSION-hls-lfcd-lds-driver ros-$ROSVERSION-open-manipulator ros-$ROSVERSION-dynamixel-sdk 
    
    #sudo apt install ros-melodic-turtlebot3-deliver
    #sudo apt install ros-$ROSVERSION-opencr



    #
    # additional packages for Turtlebot 2 & etc.
    #
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-moveit
    
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-ros-control ros-$ROSVERSION-ros-controllers # as of 2018-02-22, seems to fix the controller_manager giving warnings and not starting up (test via rosservice list | grep controller_manager)
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-gazebo-ros ros-$ROSVERSION-gazebo-ros-control # still need to also include this to actually be able to correctly load controller_manager and talk to gazebo controller plugins though

fi

#now, catkin_make this bad boy! :)
su - $SCRIPTUSER -c "source /home/$SCRIPTUSER/.bashrc; cd $WORKSPACEDIR; source /opt/ros/$ROSVERSION/setup.bash; /opt/ros/$ROSVERSION/bin/catkin_make;"



echo "End of install_turtlebot_ros.sh script!"
