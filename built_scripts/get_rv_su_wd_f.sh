#!/bin/bash -e
# Copyright by University of Cincinnati
# All rights reserved. See LICENSE file at:
# https://github.com/AS4SR/vagrant-rss


#
# find O/S codename (set to UCODENAME)
# see: http://www.ros.org/reps/rep-0003.html
#      http://www.unixtutorial.org/commands/lsb_release/
#      http://unix.stackexchange.com/questions/104881/remove-particular-characters-from-a-variable-using-bash
#
#UCODENAME=`lsb_release -c | sed 's/Codename:	//g'`
# cleaner version from ROS install instructions: 
UCODENAME=`lsb_release -sc`
echo "Ubuntu version is: $UCODENAME" 
if [ $UCODENAME == "trusty" ]; then # do-nothing
    : # null command
elif [ $UCODENAME == "xenial" ]; then # do-nothing
    : # null command
elif [ $UCODENAME == "bionic" ]; then # do-nothing
    : # null command
else
    echo "ERROR: Unknown Ubuntu version."
    echo "Currently, these install scripts only support Ubuntu 14.04 trusty, Ubuntu 16.04 xenial, and Ubuntu 18.04 bionic."
    echo "Exiting."
    exit
fi
echo "*** Will be using UCODENAME=$UCODENAME" 

echo "Parsing commandline arguments to script..." 
echo ""
echo "input arguments: ROSVERSION [SCRIPTUSER] [WORKSPACEDIR] [-f]"
echo "defaults:        n/a         vagrant      /home/\$SCRIPTUSER/catkin_ws"
echo "ROSVERSION acceptable inputs are: indigo jade kinetic melodic"
echo "SCRIPTUSER must be given as an argument for WORKSPACEDIR to be read from commandline"
echo "WORKSPACEDIR must specify the absolute path of the directory"
echo "-f sets FORCE=-f and will force a (re)install of all compiled-from-source components." 
# set defaults for input arguments
ROSVERSION=
SCRIPTUSER=vagrant
WORKSPACEDIR="/home/$SCRIPTUSER/catkin_ws"
FORCE=
# if we get an input parameter (username) then use it, else use default 'vagrant'
# get -f (force) if given 
if [ $# -lt 1 ]; then
    echo "ERROR: No ROS version given as commandline argument. Exiting."
    exit
else # at least 1 (possibly 4) argument(s) at commandline...
    # check against O/S argument, kinetic does not demand support for 14.04, or indigo/jade for 16.04, or melodic for 14.04/16.04...
    echo "Commandline argument 1 (for ROSVERSION) is: $1" 
    if [ $1 == "indigo" ] && [ $UCODENAME == "trusty" ]; then
        ROSVERSION="indigo"
    elif [ $1 == "jade" ] && [ $UCODENAME == "trusty" ]; then
        ROSVERSION="jade"
    elif [ $1 == "kinetic" ] && [ $UCODENAME == "xenial" ]; then
        ROSVERSION="kinetic"
    elif [ $1 == "melodic" ] && [ $UCODENAME == "bionic" ]; then
        ROSVERSION="melodic"
    else
        echo "ERROR: Unknown ROS version ($1) given as commandline argument -or- ROS version does not match O/S."
        echo "Currently, install_deps.sh supports indigo and jade on trusty only, kinetic on xenial only, and melodic on bionic only."
        echo "Exiting."
        exit
    fi
    echo "ROS version is $ROSVERSION." 
    if [ $# -lt 2 ]; then
        echo "Single username not given as commandline argument. Using default of '$SCRIPTUSER'."
    else # at least 2 (possibly more) arguments at commandline... 
        if [ "$2" == "-f" ]; then # -f is last argument at commandline...
            FORCE=$2
            echo "-f (force) commandline argument given."
            echo "Default user and workspace directory path will be used." 
        else # SCRIPTUSER should be argument #2
            # but we need to / should check against the users that have home directories / can log in
            HOMEDIRFORUSER_FOUND=`ls -1 /home | grep -m 1 -o "$2" | wc -l` 
            # grep should find a match and repeat it
            # and wc -l should give 1 if argument #2 is a username that has a home directory associated with it 
            if [ $HOMEDIRFORUSER_FOUND -eq 1 ]; then 
                echo "Username given as commandline argument." 
                SCRIPTUSER=$2
                WORKSPACEDIR="/home/$SCRIPTUSER/catkin_ws"
            else # already checked for a -f, and not a user... (note: WORKSPACEDIR not allowed to be given without SCRIPTUSER argument)
                echo "Bad username given as commandline argument. Using default username."
            fi 
            if [ $# -lt 3 ]; then
                echo "Workspace not given as commandline argument. Using default of '$WORKSPACEDIR'."
            else # at least 3 (possibly more) arguments at commandline... 
                if [ "$3" == "-f" ]; then # -f is last argument at commandline...
                    FORCE=$3
                    echo "-f (force) commandline argument given."
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
if [ "$FORCE" == "-f" ]; then
    echo "Forcing install of all compiled-from-source components."
fi 