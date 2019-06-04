#!/bin/bash -e
# Copyright by California Institute of Technology, University of Cincinnati
# All rights reserved. See LICENSE file at:
# https://github.com/AS4SR/vagrant-rss

#
# in the initialization process for vagrant, this bash script is run as user 'root' from /vagrant
#

echo "Start of set_up_catkin_workspace.sh script!"
#echo "input arguments: ROSVERSION [SCRIPTUSER] [WORKSPACEDIR] [-f]"
#NOTE: [-f] is NOT used by this script!

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
# set up catkin workspace
#

#sudo -u $SCRIPTUSER mkdir -p catkin_ws/src
sudo -u $SCRIPTUSER mkdir -p $WORKSPACEDIR/src
#su - $SCRIPTUSER -c "source /home/$SCRIPTUSER/.bashrc; cd /home/$SCRIPTUSER/catkin_ws/src; source /opt/ros/$ROSVERSION/setup.bash; /opt/ros/$ROSVERSION/bin/catkin_init_workspace; cd ..; /opt/ros/$ROSVERSION/bin/catkin_make;"
su - $SCRIPTUSER -c "source /home/$SCRIPTUSER/.bashrc; cd $WORKSPACEDIR/src; source /opt/ros/$ROSVERSION/setup.bash; /opt/ros/$ROSVERSION/bin/catkin_init_workspace; cd ..; /opt/ros/$ROSVERSION/bin/catkin_make;"
# uncomment out the two following lines if you have a single catkin workspace that you want to have automatically set up in bash:
#sudo -u $SCRIPTUSER echo "source /opt/ros/$ROSVERSION/setup.bash" >> /home/$SCRIPTUSER/.bashrc
#sudo -u $SCRIPTUSER echo "source /home/$SCRIPTUSER/catkin_ws/devel/setup.bash" >> /home/$SCRIPTUSER/.bashrc
# uncomment out the following line if you get access errors (to fix ownership rights):
#sudo chown -R $SCRIPTUSER:$SCRIPTUSER /home/$SCRIPTUSER/.bashrc

echo "End of set_up_catkin_workspace.sh script!"
