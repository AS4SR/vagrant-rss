#!/usr/bin/python
"""
Copyright 2019 University of Cincinnati
All rights reserved. See LICENSE file at:
https://github.com/AS4SR/vagrant-rss
Additional copyright may be held by others, as reflected in the commit history.
"""

import os
import sys

def apt_upd_sys_str(long_or_short_ver):
    if (long_or_short_ver == "long"):
        script_str = """
#
# in the initialization process for vagrant, this bash script is run as user 'root' from /vagrant
#

echo "Running apt update and upgrade!"

# make sure aptdcon exists, if not then install it to /usr/bin/aptdcon
APTDCON_INSTALLED=`whereis aptdcon | grep -m 1 "/usr/bin/aptdcon" | wc -l`
if [ $APTDCON_INSTALLED -lt 1 ]
then
    sudo apt install aptdaemon
fi

# run an 'apt update' check without sudo
# ref: https://askubuntu.com/questions/391983/software-updates-from-terminal-without-sudo
aptdcon --refresh
NUMBER_UPGRADEABLE=`apt-get -s upgrade | grep "upgraded," | cut -d' ' -f1`
if [ $NUMBER_UPGRADEABLE -gt 0 ]
then
    echo "Some packages require updating, running apt update-upgrade as sudo now..."
    sudo apt -y update
    sudo apt -y upgrade
    echo "Done with apt update-upgrade!"
fi

echo "apt update and upgrade complete!" """
    else: #if (long_or_short_ver == "short"):
        script_str = """
sudo apt -y update
sudo apt -y upgrade """
    return script_str

def check_pkg_status_and_install(long_or_short_ver,pkglist):
    if (long_or_short_ver == "long"):
        script_str = """echo "Installing packages: %r""" % pkglist
        script_str = script_str + """
# check for installation
# dpkg -s $PACKAGE_NAME should check pkg status and return a set of strings with '...Status: install ok installed...' or '...is not installed...'
# grep should find a match and repeat it (the entire line)
# and wc -l should give 1 if installed/good-status (and 0 if "is not installed" was found) """
        for i in range(len(pkglist)):
            script_str = script_str + """
PACKAGE_INSTALLED=`dpkg -s $PACKAGE_NAME | grep -m 1 "Status: install ok installed" | wc -l`
if [ $PACKAGE_INSTALLED -eq 1 ]; then
    echo "$PACKAGE_NAME is already installed!"
else # this will pass back status of the apt install if errors out (due to -e in first line)
    echo "$PACKAGE_NAME is not yet installed! Installing now!"
    sudo apt -y install $PACKAGE_NAME
    echo "$PACKAGE_NAME should now be installed!"
fi """.replace("$PACKAGE_NAME",pkglist[i])
    else: #if (long_or_short_ver == "short"):
        script_str = "sudo apt -y install"
        for i in range(len(pkglist)):
            script_str = script_str + " " + pkglist[i]
        script_str = script_str + "\n"
    return script_str

def get_os_codename(long_or_short_ver):
    script_str = ""
    if (long_or_short_ver == "long"):
        script_str = """
#
# find O/S codename (set to UCODENAME)
# see: http://www.ros.org/reps/rep-0003.html
#      http://www.unixtutorial.org/commands/lsb_release/
#      http://unix.stackexchange.com/questions/104881/remove-particular-characters-from-a-variable-using-bash
#
#UCODENAME=`lsb_release -c | sed 's/Codename:\t//g'`
# cleaner version from ROS install instructions: """
    script_str = script_str + """
UCODENAME=`lsb_release -sc`
echo "Ubuntu version is: $UCODENAME" """
    if (long_or_short_ver == "long"):
        script_str = script_str + """
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
echo "*** Will be using UCODENAME=$UCODENAME" """
    return script_str

def find_path_direct(long_or_short_ver):
    script_str = ""
    if (long_or_short_ver == "long"):
        script_str = """
# find path of this-script-being-run
# see: http://stackoverflow.com/questions/630372/determine-the-path-of-the-executing-bash-script
# """
    script_str = script_str + """
RELATIVE_PATH="`dirname \"$0\"`"
ABSOLUTE_PATH="`( cd \"$RELATIVE_PATH\" && pwd )`"
echo "PATH of current script ($0) is: $ABSOLUTE_PATH" """
    return script_str

def get_rv_su_wd_f(long_or_short_ver): # write OK tested OK
    """ Note: this script calls get_os_codename(long_or_short_ver) inside this script! """
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

    # note: source'ing a script overwrites $0 -- in other words, the call of the script itself

    script_str = "\n" + get_os_codename(long_or_short_ver) + "\n"
    
    script_str = script_str + """
echo "Parsing commandline arguments to script..." """
    if (long_or_short_ver == "long"):
        script_str = script_str + """
echo ""
echo "input arguments: ROSVERSION [SCRIPTUSER] [WORKSPACEDIR] [-f]"
echo "defaults:        n/a         vagrant      /home/\$SCRIPTUSER/catkin_ws"
echo "ROSVERSION acceptable inputs are: indigo jade kinetic melodic"
echo "SCRIPTUSER must be given as an argument for WORKSPACEDIR to be read from commandline"
echo "WORKSPACEDIR must specify the absolute path of the directory"
echo "-f sets FORCE=-f and will force a (re)install of all compiled-from-source components." """
    script_str = script_str + """
# set defaults for input arguments
ROSVERSION=
SCRIPTUSER=vagrant
WORKSPACEDIR="/home/$SCRIPTUSER/catkin_ws"
FORCE="""
    if (long_or_short_ver == "long"):
        script_str = script_str + """
# if we get an input parameter (username) then use it, else use default 'vagrant'
# get -f (force) if given """
    script_str = script_str + """
if [ $# -lt 1 ]; then
    echo "ERROR: No ROS version given as commandline argument. Exiting."
    exit
else # at least 1 (possibly 4) argument(s) at commandline...
    # check against O/S argument, kinetic does not demand support for 14.04, or indigo/jade for 16.04, or melodic for 14.04/16.04..."""
    if (long_or_short_ver == "long"):
        script_str = script_str + """
    echo "Commandline argument 1 (for ROSVERSION) is: $1" """
    script_str = script_str + """
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
    echo "ROS version is $ROSVERSION." """
    if (long_or_short_ver == "long"):
        script_str = script_str + """
    if [ $# -lt 2 ]; then
        echo "Single username not given as commandline argument. Using default of '$SCRIPTUSER'."
    else # at least 2 (possibly more) arguments at commandline... """
    else:
        script_str = script_str + """
    if [ $# -gt 1 ]; then # at least 2 (possibly more) arguments at commandline... """
    script_str = script_str + """
        if [ "$2" == "-f" ]; then # -f is last argument at commandline...
            FORCE=$2"""
    if (long_or_short_ver == "long"):
        script_str = script_str + """
            echo "-f (force) commandline argument given."
            echo "Default user and workspace directory path will be used." """
    script_str = script_str + """
        else # SCRIPTUSER should be argument #2
            # but we need to / should check against the users that have home directories / can log in
            HOMEDIRFORUSER_FOUND=`ls -1 /home | grep -m 1 -o "$2" | wc -l` """
    if (long_or_short_ver == "long"):
        script_str = script_str + """
            # grep should find a match and repeat it
            # and wc -l should give 1 if argument #2 is a username that has a home directory associated with it """
    script_str = script_str + """
            if [ $HOMEDIRFORUSER_FOUND -eq 1 ]; then """
    if (long_or_short_ver == "long"):
        script_str = script_str + """
                echo "Username given as commandline argument." """
    script_str = script_str + """
                SCRIPTUSER=$2
                WORKSPACEDIR="/home/$SCRIPTUSER/catkin_ws"
            else # already checked for a -f, and not a user... (note: WORKSPACEDIR not allowed to be given without SCRIPTUSER argument)
                echo "Bad username given as commandline argument. Using default username."
            fi """
    if (long_or_short_ver == "long"):
        script_str = script_str + """
            if [ $# -lt 3 ]; then
                echo "Workspace not given as commandline argument. Using default of '$WORKSPACEDIR'."
            else # at least 3 (possibly more) arguments at commandline... """
    else:
        script_str = script_str + """
            if [ $# -gt 2 ]; then # at least 3 (possibly more) arguments at commandline... """
    script_str = script_str + """
                if [ "$3" == "-f" ]; then # -f is last argument at commandline...
                    FORCE=$3"""
    if (long_or_short_ver == "long"):
        script_str = script_str + """
                    echo "-f (force) commandline argument given."
                    echo "Default workspace directory path will be used." """
    script_str = script_str + """
                else # WORKSPACEDIR should be argument #3 """
    if (long_or_short_ver == "long"):
        script_str = script_str + """
                    echo "Workspace directory given as commandline argument." """
    script_str = script_str + """
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
fi """
    return script_str













# def ?(long_or_short_ver):

    # #
    # # parse input vars (set to appropriate vars or default vars)
    # #
    # source $ABSOLUTE_PATH/get_rv_su_wd_f.sh "$@"
    # # when source'd, sets these vars at this level: ROSVERSION SCRIPTUSER WORKSPACEDIR FORCE


    # if (long_or_short_ver == "long"):
        # script_str = """

        # """
    # else #if (long_or_short_ver == "short"):
        # script_str = """

        # """
    # return script_str



if __name__ == '__main__':
    """
    Call from the same directory via:
        ./create_sh_files.py
    
    This will create the 'simplified' .sh file(s) as well as the 
    combined .sh file(s) and Vagrantfile(s) for installation
    
    If you want to create a specific install set only, you can write:
        ./create_sh_files.py trusty indigo
    -or-
        ./create_sh_files.py xenial kinetic
    -or-
        ./create_sh_files.py bionic melodic
    as a few examples of the available [ubuntu - ROS ] version pairings.
    """
    
    holdargs = sys.argv
    print("holdargs = '%s'" % holdargs)

    #sys.exit(0)

    build_pairings = [['trusty','indigo'],['xenial','kinetic'],['bionic','melodic']] # valid pairings for build
        
    if len(holdargs)>2:
        if isinstance(holdargs[1],str) and isinstance(holdargs[2],str):
            holdubuntu = holdargs[1]
            holdros = holdargs[2]
            if [holdubuntu,holdros] in build_pairings: # overwrite only if
                build_pairings = [[holdubuntu,holdros]] # is valid pairing
    print("*** build_pairings = '%r' ***" % build_pairings)

    # ---- Parameters for shell script creation ----
    
    # create subdirectories for build pairings (may or may not yet exist)

    
    long_or_short_ver = "long"
    #long_or_short_ver = "short"
    
    sh_file_top = """#!/bin/bash -e
# Copyright by University of Cincinnati
# All rights reserved. See LICENSE file at:
# https://github.com/AS4SR/vagrant-rss
"""
    
    start_each_file_str = ""
    # sets RELATIVE_PATH and ABSOLUTE_PATH (has to be run inside file)
    start_each_file_str = start_each_file_str + find_path_direct(long_or_short_ver)
    # sets UCODENAME -- note that this is currently added inside get_rv_su_wd()
    #start_each_file_str = start_each_file_str + get_os_codename(long_or_short_ver)
    # when source'd, sets these vars at the calling shell script's level: ROSVERSION SCRIPTUSER WORKSPACEDIR FORCE    
    start_each_file_str = start_each_file_str + get_rv_su_wd_f(long_or_short_ver)
    
    
    #install_appropriate_ros_version.sh
    
    script_top = "/home/cmcghan/github_pulls/vagrant-rss_AS4SR/"
    outfile_location_rel_to_pyscript = "built_scripts/"
    
    print("creating directory (" + script_top + outfile_location_rel_to_pyscript + ") that it goes within...")
    # first, try and create the directory the file's gonna reside in, in case it doesn't exist already
    try:
        os.mkdir(script_top + outfile_location_rel_to_pyscript)
    except:
        pass
    print("directory created")

    outfilename = "get_rv_su_wd_f.sh"
    filecontents = sh_file_top + get_rv_su_wd_f(long_or_short_ver)

    # now, write everything to the file
    filelocation_str = script_top + outfile_location_rel_to_pyscript + outfilename
    print("writing "+ filelocation_str + "...")
    f = open(filelocation_str,'w');
    f.write(filecontents); f.close();
    print(filelocation_str + " has been written")

    
    
    sys.exit(0)
    

# --EOF--
