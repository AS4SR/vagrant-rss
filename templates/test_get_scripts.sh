#!/bin/bash -e
# Copyright by California Institute of Technology, University of Cincinnati
# All rights reserved. See LICENSE file at:
# https://github.com/AS4SR/vagrant-rss

echo "Start of test_get_scripts.sh script!"
echo "sets UCODENAME environment variable for a script 'source'ing it"
echo "(sets ROSVERSION, SCRIPTUSER, WORKSPACEDIR, FORCE environment variable for a script 'source'ing it)"

#
# find path of this-script-being-run
# see: http://stackoverflow.com/questions/630372/determine-the-path-of-the-executing-bash-script
#
RELATIVE_PATH="`dirname \"$0\"`"
ABSOLUTE_PATH="`( cd \"$RELATIVE_PATH\" && pwd )`"
echo "PATH of current script ($0) is: $ABSOLUTE_PATH"

#
# simple runs, show nothing changes on non-source runs...
#

echo " "
echo "Non-source'd runs:"
echo " "

$ABSOLUTE_PATH/get_os_codename.sh
#./get_os_codename.sh
echo " "
echo "Back in test_get_scripts.sh script..."
echo "UCODENAME is $UCODENAME"
echo " "

$ABSOLUTE_PATH/get_rv_su_wd_f.sh kinetic vagrant /home/vagrant/catkin_ws -f
#./get_rv_su_wd_f.sh kinetic vagrant /home/vagrant/catkin_ws -f
echo " "
echo "Back in test_get_scripts.sh script..."
echo "ROSVERSION is $ROSVERSION"
echo "SCRIPTUSER is $SCRIPTUSER"
echo "WORKSPACEDIR is $WORKSPACEDIR"
echo "FORCE is $FORCE"
echo " "

#
# source'd runs, show env vars are changed/now-exist in top script...
#

echo " "
echo "Source'd runs:"
echo " "

# find O/S codename (set to UCODENAME)
source $ABSOLUTE_PATH/get_os_codename.sh
#source ./get_os_codename.sh

echo " "
echo "Back in test_get_scripts.sh script..."
echo "UCODENAME is $UCODENAME"
echo " "

#
# parse input vars (set to appropriate vars or default vars)
#
source $ABSOLUTE_PATH/get_rv_su_wd_f.sh kinetic vagrant /home/vagrant/catkin_ws -f
#source ./get_rv_su_wd_f.sh kinetic vagrant /home/vagrant/catkin_ws -f
# when source'd, sets these vars at this level: ROSVERSION SCRIPTUSER WORKSPACEDIR FORCE

echo " "
echo "Back in test_get_scripts.sh script..."
echo "ROSVERSION is $ROSVERSION"
echo "SCRIPTUSER is $SCRIPTUSER"
echo "WORKSPACEDIR is $WORKSPACEDIR"
echo "FORCE is $FORCE"
echo " "

echo "End of test_get_scripts.sh script!"
