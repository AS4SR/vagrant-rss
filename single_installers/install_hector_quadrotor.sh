#!/bin/bash -e
# Copyright by University of Cincinnati
# All rights reserved. See LICENSE file at:
# https://github.com/AS4SR/vagrant-rss

#
# in the initialization process for vagrant, this bash script is run as user 'root' from /vagrant
#

echo "Start of install_hector_quadrotor.sh script!"
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

# start in the /root directory
cd ~
# make and move into directory for holding compilation files + downloads
#mkdir -p ~/initdeps
#cd ~/initdeps

cd $WORKSPACEDIR/src
if [ "$ROSVERSION" == "indigo" ]; then
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-hector-quadrotor-demo
elif [ "$ROSVERSION" == "jade" ]; then # jade is untested
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-hector-quadrotor-demo
elif [ "$ROSVERSION" == "kinetic" ]; then
    #sudo apt-get -y install ros-kinetic-hector-quadrotor-demo
    #sudo apt-get -y install ros-kinetic-hector-quadrotor-description ros-kinetic-hector-quadrotor-gazebo ros-kinetic-hector-quadrotor-teleop ros-kinetic-hector-quadrotor-gazebo-plugins
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-hector-localization ros-$ROSVERSION-hector-gazebo ros-$ROSVERSION-hector-models ros-$ROSVERSION-hector-slam
    
    # keyboard control interfaces
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-kinetic-joystick-drivers ros-kinetic-teleop-twist-keyboard

    if [ "$FORCE" == "-f" ]; then
        cd $WORKSPACEDIR/src
        rm -rf hector_quadrotor
        rm -rf hector_localization
        rm -rf hector_gazebo
        rm -rf hector_models
        rm -rf hector_slam
    fi

    # rosinstall use:
    #rosinstall $WORKSPACEDIR/src /opt/ros/kinetic https://raw.githubusercontent.com/AS4SR/hector_quadrotor/kinetic-devel/tutorials.rosinstall
    su - $SCRIPTUSER -c "source /home/$SCRIPTUSER/.bashrc; rosinstall $WORKSPACEDIR/src /opt/ros/kinetic https://raw.githubusercontent.com/AS4SR/hector_quadrotor/kinetic-devel/tutorials.rosinstall;"

    # kinetic from source:
    #git clone -b kinetic-devel https://github.com/tu-darmstadt-ros-pkg/hector_quadrotor.git
    # run the hector_quadrotor.rosinstall file (see: http://wiki.ros.org/rosinstall
    #                                                http://answers.ros.org/question/9213/how-exactly-does-rosinstall-work/ )
    #$ABSOLUTE_PATH/check_pkg_status_and_install.sh python-rosinstall
    #rosinstall . hector_quadrotor.rosinstall # <-- this has issues with . as given directory... maybe supposed to be just that file run at src??

    # from the hector_quadrotor.rosinstall file:
    # (hector_quadrotor_pose_estimation requires hector_pose_estimation)
    #git clone -b catkin https://github.com/tu-darmstadt-ros-pkg/hector_localization.git
    #git clone -b kinetic-devel https://github.com/tu-darmstadt-ros-pkg/hector_gazebo.git
    #git clone -b kinetic-devel https://github.com/tu-darmstadt-ros-pkg/hector_models.git
    # additional from the tutorials.rosinstall file:
    #git clone -b catkin https://github.com/tu-darmstadt-ros-pkg/hector_slam.git

    # hector_localization/hector_pose_estimation_core requires geographic_msgs
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-geographic-msgs
    # hector_quadrotor/hector_quadrotor_interface requires hardware_interface (part of ros_control)
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-hardware-interface
    # hector_quadrotor/hector_quadrotor_interface requires controller_interface... (part of ros_control)
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-ros-control
    # hector_quadrotor/hector_quadrotor_controller_gazebo requires gazebo-ros-control
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-gazebo-ros-control

    # not sure if requires gazebo7 build from scratch...
    #$ABSOLUTE_PATH/check_pkg_status_and_install.sh mercurial meld
    #cd $WORKSPACEDIR
    #hg clone https://bitbucket.org/osrf/gazebo gazebo
    #cd gazebo
    #hg pull && hg update gazebo7_7.4.0
elif [ "$ROSVERSION" == "melodic" ]; then
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-hector-gazebo ros-$ROSVERSION-hector-models
    #$ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-hector-localization ros-$ROSVERSION-hector-slam # doesn't work in melodic
    
    # keyboard control interfaces
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-joystick-drivers ros-$ROSVERSION-teleop-twist-keyboard

    if [ "$FORCE" == "-f" ]; then
        cd $WORKSPACEDIR/src
        rm -rf hector_quadrotor
        rm -rf hector_localization
        rm -rf hector_gazebo
        rm -rf hector_models
        rm -rf hector_slam
    fi

    # rosinstall use:
    #rosinstall $WORKSPACEDIR/src /opt/ros/kinetic https://raw.githubusercontent.com/AS4SR/hector_quadrotor/kinetic-devel/tutorials.rosinstall
    su - $SCRIPTUSER -c "source /home/$SCRIPTUSER/.bashrc; rosinstall $WORKSPACEDIR/src /opt/ros/melodic https://raw.githubusercontent.com/AS4SR/hector_quadrotor/kinetic-devel/tutorials.rosinstall;"

    # kinetic from source:
    #git clone -b kinetic-devel https://github.com/tu-darmstadt-ros-pkg/hector_quadrotor.git
    # run the hector_quadrotor.rosinstall file (see: http://wiki.ros.org/rosinstall
    #                                                http://answers.ros.org/question/9213/how-exactly-does-rosinstall-work/ )
    #$ABSOLUTE_PATH/check_pkg_status_and_install.sh python-rosinstall
    #rosinstall . hector_quadrotor.rosinstall # <-- this has issues with . as given directory... maybe supposed to be just that file run at src??

    # from the hector_quadrotor.rosinstall file:
    # (hector_quadrotor_pose_estimation requires hector_pose_estimation)
    #git clone -b catkin https://github.com/tu-darmstadt-ros-pkg/hector_localization.git
    #git clone -b kinetic-devel https://github.com/tu-darmstadt-ros-pkg/hector_gazebo.git
    #git clone -b kinetic-devel https://github.com/tu-darmstadt-ros-pkg/hector_models.git
    # additional from the tutorials.rosinstall file:
    #git clone -b catkin https://github.com/tu-darmstadt-ros-pkg/hector_slam.git

    # hector_localization/hector_pose_estimation_core requires geographic_msgs
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-geographic-msgs
    # hector_quadrotor/hector_quadrotor_interface requires hardware_interface (part of ros_control)
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-hardware-interface
    # hector_quadrotor/hector_quadrotor_interface requires controller_interface... (part of ros_control)
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-ros-control
    # hector_quadrotor/hector_quadrotor_controller_gazebo requires gazebo-ros-control
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-gazebo-ros-control
    
    #    qmake: could not exec '/usr/lib/x86_64-linux-gnu/qt4/bin/qmake': No such file or directory
    #CMake Error at /usr/share/cmake-3.10/Modules/FindQt4.cmake:1320 (message):
    #  Found unsuitable Qt version "" from NOTFOUND, this code requires Qt 4.x
    #Call Stack (most recent call first):
    #  hector_slam/hector_geotiff/CMakeLists.txt:12 (find_package)
    # --> so needs qmake for catkin_make compile for Qt4 ?
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh qt4-qmake
    #CMake Error at /usr/share/cmake-3.10/Modules/FindQt4.cmake:628 (message):
    #  Could NOT find QtCore.  Check
    #  /home/cmcghan/catkin_ws/build/CMakeFiles/CMakeError.log for more details.
    #Call Stack (most recent call first):
    #  hector_slam/hector_geotiff/CMakeLists.txt:12 (find_package)
    # https://askubuntu.com/questions/766615/how-to-install-libqt4-core-and-libqt4-gui-on-ubuntu-16-04-lts
    # https://github.com/tetzank/qmenu_hud/issues/5
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh libqt4-dev
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh libqt4-designer libqt4-opengl libqt4-svg libqtgui4 libqtwebkit4 # qt5-qmake
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-libqt-core ros-$ROSVERSION-libqt-dev ros-$ROSVERSION-qt-qmake
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh libqt4-dev
    
    #CMake Error at /usr/share/cmake-3.10/Modules/FindBoost.cmake:1947 (message):
    #  Unable to find the requested Boost libraries.
    #
    #  Boost version: 1.65.1
    #
    #  Boost include path: /usr/include
    #
    #  Could not find the following Boost libraries:
    #
    #          boost_program_options
    #          boost_regex
    #          boost_iostreams
    #          boost_date_time
    #
    #  Some (but not all) of the required Boost libraries were found.  You may
    #  need to install these additional Boost libraries.  Alternatively, set
    #  BOOST_LIBRARYDIR to the directory containing Boost libraries or BOOST_ROOT
    #  to the location of Boost.
    # hector_quadrotor_controller_gazebo requires boot libraries: boost_program_options, boost_regex, boost_iostreams, boost_date_time
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh libboost-all-dev
    $ABSOLUTE_PATH/check_pkg_status_and_install.sh libboost-regex-dev libboost-iostreams-dev libboost-date-time-dev
    
    # need to add the following lines at the top of the relevant CMakeLists.txt files for melodic:
    #set(CMAKE_LIBRARY_ARCHITECTURE "x86_64-linux-gnu") # NEW
    ##set(BOOST_INCLUDEDIR /usr/include) # NEW
    #set(BOOST_LIBRARYDIR /usr/lib/x86_64-linux-gnu) # NEW
    #
    #hector_quadrotor/hector_quadrotor_controller_gazebo/CMakeLists.txt
    #hector_gazebo/hector_gazebo_thermal_camera/CMakeLists.txt
    #hector_slam/hector_mapping/CMakeLists.txt
    #hector_quadrotor/hector_quadrotor_gazebo_plugins/CMakeLists.txt
    #hector_gazebo/hector_gazebo_plugins/CMakeLists.txt
    
    cd $WORKSPACEDIR
    cd src/hector_quadrotor/hector_quadrotor_controller_gazebo
    sed -i.orig '2s/project(hector_quadrotor_controller_gazebo)/project(hector_quadrotor_controller_gazebo)\n\nset(CMAKE_LIBRARY_ARCHITECTURE "x86_64-linux-gnu") # NEW\n#set(BOOST_INCLUDEDIR \/usr\/include) # NEW\nset(BOOST_LIBRARYDIR \/usr\/lib\/x86_64-linux-gnu) # NEW/' CMakeLists.txt
    
    cd $WORKSPACEDIR
    cd src/hector_gazebo/hector_gazebo_thermal_camera
    sed -i.orig '2s/project(hector_gazebo_thermal_camera)/project(hector_quadrotor_controller_gazebo)\n\nset(CMAKE_LIBRARY_ARCHITECTURE "x86_64-linux-gnu") # NEW\n#set(BOOST_INCLUDEDIR \/usr\/include) # NEW\nset(BOOST_LIBRARYDIR \/usr\/lib\/x86_64-linux-gnu) # NEW/' CMakeLists.txt
    
    cd $WORKSPACEDIR
    cd src/hector_slam/hector_mapping
    sed -i.orig '2s/project(hector_mapping)/project(hector_quadrotor_controller_gazebo)\n\nset(CMAKE_LIBRARY_ARCHITECTURE "x86_64-linux-gnu") # NEW\n#set(BOOST_INCLUDEDIR \/usr\/include) # NEW\nset(BOOST_LIBRARYDIR \/usr\/lib\/x86_64-linux-gnu) # NEW/' CMakeLists.txt
    
    cd $WORKSPACEDIR
    cd src/hector_quadrotor/hector_quadrotor_gazebo_plugins
    sed -i.orig '2s/project(hector_quadrotor_gazebo_plugins)/project(hector_quadrotor_controller_gazebo)\n\nset(CMAKE_LIBRARY_ARCHITECTURE "x86_64-linux-gnu") # NEW\n#set(BOOST_INCLUDEDIR \/usr\/include) # NEW\nset(BOOST_LIBRARYDIR \/usr\/lib\/x86_64-linux-gnu) # NEW/' CMakeLists.txt
    
    cd $WORKSPACEDIR
    cd src/hector_gazebo/hector_gazebo_plugins
    sed -i.orig '2s/project(hector_gazebo_plugins)/project(hector_quadrotor_controller_gazebo)\n\nset(CMAKE_LIBRARY_ARCHITECTURE "x86_64-linux-gnu") # NEW\n#set(BOOST_INCLUDEDIR \/usr\/include) # NEW\nset(BOOST_LIBRARYDIR \/usr\/lib\/x86_64-linux-gnu) # NEW/' CMakeLists.txt

fi

#now, catkin_make this bad boy! :)
su - $SCRIPTUSER -c "source /home/$SCRIPTUSER/.bashrc; cd $WORKSPACEDIR; source /opt/ros/$ROSVERSION/setup.bash; /opt/ros/$ROSVERSION/bin/catkin_make;"

# note: trying to run the hector_quadrotor launch file(s) in VirtualBox VM under kinetic...
# gives the following error after not too long...
#gzserver: /build/ogre-1.9-mqY1wq/ogre-1.9-1.9.0+dfsg1/OgreMain/src/OgreRenderSystem.cpp:546: virtual void Ogre::RenderSystem::setDepthBufferFor(Ogre::RenderTarget*): Assertion `bAttached && "A new DepthBuffer for a RenderTarget was created, but after creation" "it says it's incompatible with that RT"' failed.
#Aborted (core dumped)
# *** this is apparently because we're running this in a virtual machine, and can be solved by "setting fsaa to 0"
# (see: https://bitbucket.org/osrf/gazebo/issues/1837/vmware-rendering-z-ordering-appears-random
#       https://bitbucket.org/osrf/gazebo/src/e08dcb5fe679f8d37857ba956d773fd80d3d7fb4/gazebo/rendering/Camera.cc?fileviewer=file-view-default#Camera.cc-1539 )
# but, basically, this requires upgrading gazebo -- luckily, we can get newer packages from the gazebo ppa
# ...unluckily, this doesn't seem to solve the issue under the VM

echo "End of install_hector_quadrotor.sh script!"
