#!/bin/bash -e
# Copyright by University of Cincinnati
# All rights reserved. See LICENSE file at:
# https://github.com/AS4SR/vagrant-rss

#
# in the initialization process for vagrant, this bash script is run as user 'root' from /vagrant
#

echo "Start of check_pkg_status_and_install.sh script!"
echo "input arguments: PACKAGE_NAME [PACKAGE_NAME] [PACKAGE_NAME] [...]"

#
# parse input vars (set to appropriate vars or default vars)
#

# get package name if given, else toss an error and exit script
if [ $# -eq 1 ]; then
    PACKAGE_NAME=$1
    # check for installation
    PACKAGE_INSTALLED=`dpkg -s $PACKAGE_NAME | grep -m 1 "Status: install ok installed" | wc -l`
    # dpkg -s $PACKAGE_NAME should check pkg status and return a set of strings with '...Status: install ok installed...' or '...is not installed...'
    # grep should find a match and repeat it (the entire line)
    # and wc -l should give 1 if installed/good-status (and 0 if "is not installed" was found)
    if [ $PACKAGE_INSTALLED -eq 1 ]; then
        echo "$PACKAGE_NAME is already installed!"
    else # this will pass back status of the apt install if errors out (due to -e in first line)
        echo "$PACKAGE_NAME is not yet installed! Installing now!"
        sudo apt -y install $PACKAGE_NAME
        echo "$PACKAGE_NAME should now be installed!"
    fi
elif [ $# -gt 1 ]; then
    echo "Multiple packages to install..."
    #echo " $@ "
    PACKAGE_ARRAY=("$@")
    #echo "PACKAGE_ARRAY is '${PACKAGE_ARRAY[@]}'"
    # example of arrays in bash: http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_10_02.html
    for PACKAGE_NAME in ${PACKAGE_ARRAY[@]}; do
        # check for installation
        PACKAGE_INSTALLED=`dpkg -s $PACKAGE_NAME | grep -m 1 "Status: install ok installed" | wc -l`
        # dpkg -s $PACKAGE_NAME should check pkg status and return a set of strings with '...Status: install ok installed...' or '...is not installed...'
        # grep should find a match and repeat it (the entire line)
        # and wc -l should give 1 if installed/good-status (and 0 if "is not installed" was found)
        if [ $PACKAGE_INSTALLED -eq 1 ]; then
            echo "$PACKAGE_NAME is already installed!"
        else # this will pass back status of the apt install if errors out (due to -e in first line)
            echo "$PACKAGE_NAME is not yet installed! Installing now!"
            sudo apt -y install $PACKAGE_NAME
            echo "$PACKAGE_NAME should now be installed!"
        fi
    done
else
    echo "Package to check for installation not given, tossing error."
    exit 1
fi

echo "End of check_pkg_status_and_install.sh script!"
