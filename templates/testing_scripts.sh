#!/bin/bash -e
# Copyright by University of Cincinnati
# All rights reserved. See LICENSE file at:
# https://github.com/AS4SR/vagrant-rss

# Need to test in order:

#ROSVERSION=indigo
#ROSVERSION=jade
#ROSVERSION=kinetic
#SCRIPTUSER=
#WORKSPACEDIR=/home/$SCRIPTUSER/catkin_ws
#FORCE=
#FORCE=-f

# ./install_all_rss_deps.sh ROSVERSION SCRIPTUSER WORKSPACEDIR FORCE

# try:
# ./install_all_rss_deps.sh kinetic testuser /home/testuser/catkin_ws
# ./install_all_rss_deps.sh kinetic testuser
# ./install_all_rss_deps.sh kinetic testuser /home/testuser/catkin_ws -f
# ./install_all_rss_deps.sh kinetic testuser -f

#
# find path of this-script-being-run
# see: http://stackoverflow.com/questions/630372/determine-the-path-of-the-executing-bash-script
#
RELATIVE_PATH="`dirname \"$0\"`"
ABSOLUTE_PATH="`( cd \"$RELATIVE_PATH\" && pwd )`"
echo "PATH of current script ($0) is: $ABSOLUTE_PATH"

ABSOLUTE_PATH=$ABSOLUTE_PATH/..
echo "modded-for-this-script's-use ABSOLUTE_PATH is: $ABSOLUTE_PATH"

# from inside install_all_rss_deps.sh

echo "trying get_os_codename.sh..."
source $ABSOLUTE_PATH/single_installers/get_os_codename.sh
echo "done trying get_os_codename.sh..."
read -rs -p "Press any key to continue..." -n 1 # reference: https://ss64.com/bash/read.html
echo " "
echo " "

echo "testing_scripts.sh args are: $@"

echo "trying get_rv_su_wd_f.sh..."
source $ABSOLUTE_PATH/single_installers/get_rv_su_wd_f.sh "$@" # pass $1 $2 $3 etc. to #script (not $0) ...but source'ing the script means that it takes the $0 from the calling script... (erg..)
#source $ABSOLUTE_PATH/single_installers/get_rv_su_wd_f.sh "${@:1}" # . runs script under current shell # ${@:2} passes $2 $3 etc. to script (not $1 $2 $3 etc.)
echo "done trying get_rv_su_wd_f.sh..."
echo "ROSVERSION is $ROSVERSION"
echo "SCRIPTUSER is $SCRIPTUSER"
echo "WORKSPACEDIR is $WORKSPACEDIR"
echo "FORCE is $FORCE"
read -rs -p "Press any key to continue..." -n 1 # reference: https://ss64.com/bash/read.html
echo " "
echo " "

# example of arrays in bash: http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_10_02.html
# install_glpk_cvxopt.sh and install_gr1c.sh from inside install_tulip-1.2.0.sh
scriptsarray0=(install_glpk_cvxopt.sh install_gr1c.sh install_tulip1.2.0.sh)
for i in ${scriptsarray0[@]}; do
    echo "trying $i..."
    $ABSOLUTE_PATH/single_installers/$i $FORCE
    echo "done trying $i..."
    read -rs -p "Press any key to continue..." -n 1 # reference: https://ss64.com/bash/read.html
    echo " "
    echo " "
done

# example of arrays in bash: http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_10_02.html
# following from inside install_rosstuff_setup_catkinworkspace.sh
scriptsarray1=(install_appropriate_ros_version.sh install_gazebo_plus_rospkgs.sh install_turtlebot_ros.sh trying install_p3dx_ros.sh set_up_catkin_workspace.sh trying install_MobileSim.sh install_ws4py.sh)
for i in ${scriptsarray1[@]}; do
    echo "trying $i..."
    $ABSOLUTE_PATH/single_installers/$i $ROSVERSION $SCRIPTUSER $WORKSPACEDIR $FORCE
    echo "done trying $i..."
    read -rs -p "Press any key to continue..." -n 1 # reference: https://ss64.com/bash/read.html
    echo " "
    echo " "
done

# scripts that are not ready yet:
#scriptsarray1b=(install_uwsim_ros.sh install_usarsim_ros.sh install_crumb_ros.sh install_hector_quadrotor.sh trying install_SURF2016_deps.sh trying install_widowx_ros.sh)

echo "trying install_rosstuff_setup_catkinworkspace.sh..."
$ABSOLUTE_PATH/single_installers/install_rosstuff_setup_catkinworkspace.sh $ROSVERSION $SCRIPTUSER $WORKSPACEDIR $FORCE
echo "done trying install_rosstuff_setup_catkinworkspace.sh..."
read -rs -p "Press any key to continue..." -n 1 # reference: https://ss64.com/bash/read.html
echo " "
echo " "

# example of arrays in bash: http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_10_02.html
# install_ipopt.sh from inside install_psulu_deps.sh # ipopt isn't installing correctly under 16.04 currently
# MC_behavior_tree isn't installing correctly under 16.04 currently
# install_glpk_cvxopt.sh from inside install_ompl.sh # install_ompl.sh untested under Ubuntu 16.04
scriptsarray2=(install_ipopt.sh install_psulu_deps.sh install_MC_behavior_tree.sh install_rrtsharp_deps.sh install_pyyaml.sh install_ompl.sh install_ompl_noomplapp_nopythonbindings.sh)
for i in ${scriptsarray2[@]}; do
    echo "trying $i..."
    $ABSOLUTE_PATH/single_installers/$i $FORCE
    echo "done trying $i..."
    read -rs -p "Press any key to continue..." -n 1 # reference: https://ss64.com/bash/read.html
    echo " "
    echo " "
done

# example of arrays in bash: http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_10_02.html
scriptsarray3=(install_tensorflow0.8.0.sh)
for i in ${scriptsarray3[@]}; do
    echo "trying $i..."
    $ABSOLUTE_PATH/single_installers/$i $SCRIPTUSER $FORCE
    echo "done trying $i..."
    read -rs -p "Press any key to continue..." -n 1 # reference: https://ss64.com/bash/read.html
    echo " "
    echo " "
done

echo "trying install_all_rss_deps.sh..."
$ABSOLUTE_PATH/install_all_rss_deps.sh $ROSVERSION $SCRIPTUSER $WORKSPACEDIR $FORCE
echo "done trying install_all_rss_deps.sh..."
read -rs -p "Press any key to continue..." -n 1 # reference: https://ss64.com/bash/read.html
echo " "
echo " "

# --eof--
