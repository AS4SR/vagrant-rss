#!/bin/bash -e
# Copyright by University of Cincinnati
# All rights reserved. See LICENSE file at:
# https://github.com/cmcghan/vagrant-rss

#
# in the initialization process for vagrant, this bash script is run as user 'root' from /vagrant
#

echo "Start of install_SOMETHING.sh script!"
#echo "input arguments: ROSVERSION [SCRIPTUSER] [WORKSPACEDIR] [-f]"

#
# find path of this-script-being-run
# see: http://stackoverflow.com/questions/630372/determine-the-path-of-the-executing-bash-script
#
RELATIVE_PATH="`dirname \"$0\"`"
ABSOLUTE_PATH="`( cd \"$RELATIVE_PATH\" && pwd )`"
echo "PATH of current script ($0) is: $ABSOLUTE_PATH"

# find O/S codename (set to UCODENAME)
#source $ABSOLUTE_PATH/get_os_codename.sh

#
# parse input vars (set to appropriate vars or default vars)
#
source $ABSOLUTE_PATH/get_rv_su_wd_f.sh "$@"
# when source'd, sets these vars at this level: ROSVERSION SCRIPTUSER WORKSPACEDIR FORCE

#
# check for installation
#

# see ./templates_/bash-script-commands-for-checking-version-numbers-of-installed-stuff.txt for examples

# exit script immediately if libraries are already installed
#if [ "$FORCE" != "-f" ] && [ $SOMETHING_FOUND -eq 1 ]
#then
#    echo "SOMETHING libraries already installed and up-to-date, exiting..."
#    exit 0
#fi

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
    #$ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-SOMETHING
elif [ "$ROSVERSION" == "jade" ]; then # jade is untested
    #$ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-SOMETHING
elif [ "$ROSVERSION" == "kinetic" ]; then
    #$ABSOLUTE_PATH/check_pkg_status_and_install.sh ros-$ROSVERSION-SOMETHING

    # kinetic from source:
    #git clone -b kinetic-devel https://github.com/SOMETHING/SOMETHING.git

fi

#now, catkin_make this bad boy! :)
#su - $SCRIPTUSER -c "source /home/$SCRIPTUSER/.bashrc; cd $WORKSPACEDIR; source /opt/ros/$ROSVERSION/setup.bash; /opt/ros/$ROSVERSION/bin/catkin_make;"

echo "End of install_SOMETHING.sh script!"
