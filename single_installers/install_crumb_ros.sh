#!/bin/bash -e
# Copyright by University of Cincinnati
# All rights reserved. See LICENSE file at:
# https://github.com/AS4SR/vagrant-rss

#
# in the initialization process for vagrant, this bash script is run as user 'root' from /vagrant
#

echo "Start of install_crumb_ros.sh script!"
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

# need to install turtlebot libraries to make this work as well
$ABSOLUTE_PATH/install_turtlebot_ros.sh $ROSVERSION $SCRIPTUSER $WORKSPACEDIR $FORCE

# if catkin_ws workspace isn't already set up:
if [ ! -d $WORKSPACEDIR ]; then # set up the catkin workspace
    $ABSOLUTE_PATH/set_up_catkin_workspace.sh $ROSVERSION $SCRIPTUSER $WORKSPACEDIR $FORCE
fi


#
# run installation + upgrades
#

# update all packages, because "gah!" otherwise, especially for 'rosdep' stuff later
$ABSOLUTE_PATH/apt_upd_sys.sh

# install CRUMB project stuff

cd $WORKSPACEDIR/src
if [ "$FORCE" == "-f" ]; then
    rm -rf ROS
    rm -rf arbotix_ros
fi
if [ ! -d ROS ]; then
    sudo -u $SCRIPTUSER git clone https://github.com/CRUMBproject/ROS.git # main CRUMB project
fi
if [ ! -d arbotix_ros ]; then
    sudo -u $SCRIPTUSER git clone https://github.com/vanadiumlabs/arbotix_ros.git # crumb_control requires arbotix_python
fi

# roboticsgroup_gazebo_plugins requires control_toolbox
$ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-control-toolbox
# crumb_gazebo/src/led.cpp requires kobuki_msgs/Led.h
$ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-kobuki-msgs
# also need ros-$ROSVERSION-ros-control &etc. -- but should be installed by install_turtlebot_ros script now
#$ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-ros-control ros-$ROSVERSION-ros-controllers
#$ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-gazebo-ros ros-$ROSVERSION-gazebo-ros-control


if [ "$ROSVERSION" == "indigo" ]; then
    echo "No changes made in indigo before compile..."
elif [ "$ROSVERSION" == "jade" ]; then
    echo "No changes made in jade before compile..."
# if we're using gazebo7 (with ROS kinetic) then we will need to make some fixes!
elif [ "$ROSVERSION" == "kinetic" ]; then
    # now, fixing errors that catkin_make would otherwise give...

    # crumb_listener_gazebo, ROS/crumb/crumb_listener/CMakeFiles/crumb_listener_gazebo.dir/src/crumb_listener_gazebo.cpp.o
    # In file included from /usr/include/c++/5/mutex:35:0,
    #                 from /usr/include/gazebo-7/gazebo/transport/CallbackHelper.hh:26,
    #                 from /usr/include/gazebo-7/gazebo/transport/transport.hh:2,
    #                 from   /home/cmcghan/catkin_ws/src/ROS/crumb/crumb_listener/src/crumb_listener_gazebo.cpp:14:
    #/usr/include/c++/5/bits/c++0x_warning.h:32:2: error: #error This file requires compiler and library support for the ISO C++ 2011 standard. This support must be enabled with the -std=c++11 or -std=gnu++11 compiler options.
     #error This file requires compiler and library suppor
    # ^
    # *** this problem is an issue with gazebo not handing off flags appropriately in ROS kinetic when using create_gazebo_plugins with gazebo7,
    # so we have to "force" the issue by adding "set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} " -std=c++11")" to CMakeLists.txt
    # see: https://github.com/turtlebot/turtlebot_create_desktop/issues/18
    #      https://github.com/turtlebot/turtlebot_create_desktop/pull/19/commits/1bf481fb7beeeb63470b301a41d0f0f126dc1978
    # see also: https://github.com/bmwcarit/meta-ros/issues/333
    # *** solution:
    #ROS/crumb/crumb_listener/CMakeLists.txt
    #add at line 14 (plus extra carriage returns):
    #set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} " -std=c++11")
    cd $WORKSPACEDIR/src/ROS/crumb/crumb_listener
    sed -i.orig '14s/find_package(catkin REQUIRED COMPONENTS/set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} " -std=c++11")\n\nfind_package(catkin REQUIRED COMPONENTS/' CMakeLists.txt

    #roboticsgroup_gazebo_disable_link_plugin, ROS/roboticsgroup_gazebo_plugins/CMakeFiles/roboticsgroup_gazebo_disable_link_plugin.dir/src/disable_link_plugin.cpp.o
    #In file included from /usr/include/c++/5/random:35:0,
    #                 from /usr/include/ignition/math2/ignition/math/Rand.hh:20,
    #                 from /usr/include/ignition/math2/ignition/math.hh:18,
    #                 from /usr/include/sdformat-4.0/sdf/Param.hh:34,
    #                 from /usr/include/sdformat-4.0/sdf/Element.hh:24,
    #                 from /usr/include/sdformat-4.0/sdf/sdf.hh:5,
    #                 from /usr/include/gazebo-7/gazebo/common/Plugin.hh:42,
    #                 from /home/cmcghan/catkin_ws/src/ROS/roboticsgroup_gazebo_plugins/include/roboticsgroup_gazebo_plugins/disable_link_plugin.h:33,
    #                 from /home/cmcghan/catkin_ws/src/ROS/roboticsgroup_gazebo_plugins/src/disable_link_plugin.cpp:23:
    #/usr/include/c++/5/bits/c++0x_warning.h:32:2: error: #error This file requires compiler and library support for the ISO C++ 2011 standard. This support must be enabled with the -std=c++11 or -std=gnu++11 compiler options.
    # #error This file requires compiler and library support \
    #  ^
    # *** same type of problem as previous, fixed by same method
    # *** solution:
    #ROS/roboticsgroup_gazebo_plugins/CMakeLists.txt
    #add at line 4 (plus extra carriage returns):
    #set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} " -std=c++11")
    cd $WORKSPACEDIR/src/ROS/roboticsgroup_gazebo_plugins
    sed -i.orig '4s/# Load catkin and all dependencies required for this package/set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} " -std=c++11")\n\n# Load catkin and all dependencies required for this package/' CMakeLists.txt

    #Building CXX object ROS/crumb/crumb_listener/CMakeFiles/crumb_listener_gazebo.dir/src/crumb_listener_gazebo.cpp.o
    #/home/cmcghan/catkin_ws/src/ROS/crumb/crumb_listener/src/crumb_listener_gazebo.cpp: In function ‘int main(int, char**)’:
    #/home/cmcghan/catkin_ws/src/ROS/crumb/crumb_listener/src/crumb_listener_gazebo.cpp:66:3: error: ‘setupClient’ is not a member of ‘gazebo’
    #   gazebo::setupClient(_argc, _argv);
    #   ^
    # *** for gazebo 2.x+, started use of gazebo::setupClient(), which was used up until gazebo 6.x when it changed again
    # see: http://answers.gazebosim.org/question/8133/setupclient-is-not-a-member-of-gazebo/
    #      http://answers.gazebosim.org/question/8865/gazebo_clienthh-not-found/
    #      https://bitbucket.org/osrf/gazebo/raw/0454926303b81b1538826020d71de38e6cd06b7d/examples/stand_alone/listener/listener.cc
    #      https://bitbucket.org/osrf/gazebo/src/0454926303b81b1538826020d71de38e6cd06b7d/examples/stand_alone/listener/CMakeLists.txt?at=gazebo5&fileviewer=file-view-default
    # *** in gazebo 6 and beyond, it changed from gazebo::setupClient() in <gazebo/gazebo.hh> to gazebo::client::setup in <gazebo/gazebo_client.hh>
    # see: https://bitbucket.org/osrf/gazebo/issues/1132/simplify-the-process-of-using-gazebo-as-a
    #      http://wiki.ros.org/kinetic/Migration#Gazebo_Simulator
    # also look for "gazebo::physics::" here:
    #      https://bitbucket.org/osrf/gazebo/src/gazebo7/Migration.md?at=gazebo7&fileviewer=file-view-default#markdown-header-gazebo-6x-to-7x
    # also look for "gazebo::setupClient" here:
    #      https://bitbucket.org/osrf/gazebo/src/gazebo6/Migration.md?at=gazebo6&fileviewer=file-view-default#markdown-header-gazebo-5x-to-6x
    # *** solution:
    #ROS/crumb/crumb_listener/src/crumb_listener_gazebo.cpp
    #line 16 was:
    ##include <gazebo/gazebo.hh>
    #line 16 becomes:
    ##include <gazebo/gazebo_client.hh>
    #line 66 was:
    #  gazebo::setupClient(_argc, _argv);
    #line 66 becomes:
    #  gazebo::client::setup(_argc, _argv);
    cd $WORKSPACEDIR/src/ROS/crumb/crumb_listener/src
    sed -i.orig '16s/#include <gazebo\/gazebo.hh>/#include <gazebo\/gazebo_client.hh>/' crumb_listener_gazebo.cpp
    sed -i.orig '66s/gazebo::setupClient(_argc, _argv);/gazebo::client::setup(_argc, _argv);/' crumb_listener_gazebo.cpp

    #Building CXX object ROS/roboticsgroup_gazebo_plugins/CMakeFiles/roboticsgroup_gazebo_mimic_joint_plugin.dir/src/mimic_joint_plugin.cpp.o
    #/home/cmcghan/catkin_ws/src/ROS/roboticsgroup_gazebo_plugins/src/mimic_joint_plugin.cpp: In member function ‘virtual void gazebo::MimicJointPlugin::Load(gazebo::physics::ModelPtr, sdf::ElementPtr)’:
    #/home/cmcghan/catkin_ws/src/ROS/roboticsgroup_gazebo_plugins/src/mimic_joint_plugin.cpp:142:19: error: ‘class gazebo::physics::Joint’ has no member named ‘SetMaxForce’
    #     mimic_joint_->SetMaxForce(0,max_effort_);
    #                   ^
    #/home/cmcghan/catkin_ws/src/ROS/roboticsgroup_gazebo_plugins/src/mimic_joint_plugin.cpp: In member function ‘void gazebo::MimicJointPlugin::UpdateChild()’:
    #/home/cmcghan/catkin_ws/src/ROS/roboticsgroup_gazebo_plugins/src/mimic_joint_plugin.cpp:168:21: error: ‘class gazebo::physics::Joint’ has no member named ‘SetAngle’
    #       mimic_joint_->SetAngle(0, math::Angle(angle));
    #                     ^
    # *** gazebo 4.x+ requires use of SetParam("fmax",uint,double) instead of older SetMaxForce(uint,double) for gazebo::physics::Joint
    # gazebo 4.x+ also requires use of SetPosition(uint,double) instead of older SetAngle(uint,math::Angle) for gazebo::physics::Joint
    # see: https://github.com/ros-simulation/gazebo_ros_pkgs/issues/321
    #      https://github.com/ros-simulation/gazebo_ros_pkgs/pull/322/commits/42061adea4f55ed295256055503bff7d4293a02d
    #      https://bitbucket.org/osrf/gazebo/src/ada35b395c9dd0c6fddd96f42cafc146baf597c3/Migration.md?at=gazebo6&fileviewer=file-view-default
    #      http://answers.gazebosim.org/question/8458/setmaxforce-deprecated-in-gazebo-50/
    #      https://github.com/Dronecode/sitl_gazebo/issues/25
    #      https://github.com/PX4/sitl_gazebo/pull/14/commits/ba00aeb833f5cda02e45fafe87f621620da1936b
    # for reasoning for using a PID controller instead of changing SetPosition() directly:
    #      http://answers.gazebosim.org/question/14793/how-to-set-a-joint-position-and-and-a-joint-force-at-the-same-time-is-it-feasible-with-the-current-api/
    # *** solution:
    #ROS/roboticsgroup_gazebo_plugins/src/mimic_joint_plugin.cpp
    #line 142 was:
    #    mimic_joint_->SetMaxForce(0,max_effort_);
    #line 142 becomes:
    #    mimic_joint_->SetParam("fmax",0,max_effort_);
    #line 168 was:
    #      mimic_joint_->SetAngle(0, math::Angle(angle));
    #line 168 becomes:
    #      mimic_joint_->SetPosition(0, math::Angle(angle).Radian());
    cd $WORKSPACEDIR/src/ROS/roboticsgroup_gazebo_plugins/src
    sed -i.orig '142s/mimic_joint_->SetMaxForce(0,max_effort_);/mimic_joint_->SetParam("fmax",0,max_effort_);/' mimic_joint_plugin.cpp
    sed -i.orig '168s/mimic_joint_->SetAngle(0, math::Angle(angle));/mimic_joint_->SetPosition(0, math::Angle(angle).Radian());/' mimic_joint_plugin.cpp
fi

#now, catkin_make this bad boy! :)
su - $SCRIPTUSER -c "source /home/$SCRIPTUSER/.bashrc; cd $WORKSPACEDIR; source /opt/ros/$ROSVERSION/setup.bash; /opt/ros/$ROSVERSION/bin/catkin_make;"

echo "End of install_crumb_ros.sh script!"
