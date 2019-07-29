#!/bin/bash -e
# Copyright by California Institute of Technology, University of Cincinnati
# All rights reserved. See LICENSE file at:
# https://github.com/AS4SR/vagrant-rss

#
# in the initialization process for vagrant, this bash script is run as user 'root' from /vagrant
#

# there is some cleaner stuff we can do here between scripts that we are enacting now
#
# basically, if we run something as "source my_script.sh" or ". ./myscript.sh",
# then it is run at the same "level" as the calling shell (or script) and changes are
# persistent, e.g.,
# -- "source" the subscript in a top-level script for the subscript to see all the
#    environment variables in that script
# -- modify an environment variable in the subscript for the top-level script that
#    "source"d it to see the change in the top-level script
#
# if you only want to share a few env vars from the top-level down, and make
# no changes to the env vars above:
# -- "export" a environment variable in the top-level script for the subscript to see
#    only that environment variable
# -- do not "source" the subscript for changes in the subscript not to affect the
#    top-level script
# see: http://stackoverflow.com/questions/9772036/pass-all-variables-from-one-shellscript-to-another

echo "Start of get_rv_su_wd_f.sh script!"
echo "(sets ROSVERSION, SCRIPTUSER, WORKSPACEDIR, FORCE environment variable for a script 'source'ing it)"
echo "(if 'source'd, this script will also return UCODENAME as an environment variable)"
echo "input arguments: ROSVERSION [SCRIPTUSER] [WORKSPACEDIR] [-f]"
echo "(note: optional input arguments in [])"
echo "(note: there is no default ROSVERSION. Acceptable inputs are: indigo jade kinetic)"
echo "(note: default [SCRIPTUSER] is \"vagrant\")"
echo "(note: SCRIPTUSER must be given as an argument for WORKSPACEDIR to be read and accepted from commandline)"
echo "(note: default [WORKSPACEDIR] is \"/home/\$SCRIPTUSER/catkin_ws\")"
echo "WORKSPACEDIR must specify the absolute path of the directory"
echo "-f sets FORCE=-f and will force a (re)install of all compiled-from-source components."

#
# find path of this-script-being-run
# see: http://stackoverflow.com/questions/630372/determine-the-path-of-the-executing-bash-script
#
#RELATIVE_PATH2="`dirname \"$0\"`"
#ABSOLUTE_PATH2="`( cd \"$RELATIVE_PATH2\" && pwd )`"
#echo "PATH of current script ($0) is: $ABSOLUTE_PATH2"

# find O/S codename (set to UCODENAME)
#source $ABSOLUTE_PATH2/get_os_codename.sh

# source'ing this script overwrites $0 -- in other words, the call of the script itself
# we can't assume that get_os_codename.sh has been run prior to this script, unfortunately
# ...so, copy the contents of get_os_codename.sh inside this script, so that this script
# doesn't depend on anything external to it!

#
# copy-paste of contents of get_os_codename.sh script
#

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
    echo "Currently, install_rosstuff_setup_catkinworkspace.sh supports Ubuntu 14.04 trusty, Ubuntu 16.04 xenial, and Ubuntu 18.04 bionic only."
    echo "Exiting."
    exit
fi
echo "*** Will be using UCODENAME=$UCODENAME"

#
# done with copy-paste of contents of get_os_codename.sh script
#

#
# INPUT ARGUMENT PARSING:
#

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
    # check against O/S argument, kinetic does not demand support for 14.04, or indigo/jade for 16.04...
    # ...or melodic for 14.04/16.04...
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
        echo "ERROR: Unknown ROS version given as commandline argument -or- ROS version does not match O/S."
        echo "Currently, install_deps.sh supports trusty with indigo and jade only, xenial with kinetic only."
        echo "Exiting."
        exit
    fi
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
                WORKSPACEDIR="/home/$SCRIPTUSER/catkin_ws"
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
if [ "$FORCE" == "-f" ]; then
    echo "Forcing install of all compiled-from-source components."
fi

echo "End of get_rv_su_wd_f.sh script!"
