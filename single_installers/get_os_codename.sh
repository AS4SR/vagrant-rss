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

echo "Start of get_os_codename.sh script!"
echo "sets UCODENAME environment variable for a script 'source'ing it"

#
# find O/S codename (set to UCODENAME)
# see: http://www.ros.org/reps/rep-0003.html
#      http://www.unixtutorial.org/commands/lsb_release/
#      http://unix.stackexchange.com/questions/104881/remove-particular-characters-from-a-variable-using-bash
#
#UCODENAME=`lsb_release -c | sed 's/Codename:\t//g'`
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
    echo "Currently, install_rosstuff_setup_catkinworkspace.sh supports Ubuntu 14.04 trusty and Ubuntu 16.04 xenial only."
    echo "Exiting."
    exit
fi
echo "*** Will be using UCODENAME=$UCODENAME"

echo "End of get_os_codename.sh script!"
