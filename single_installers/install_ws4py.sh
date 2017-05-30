#!/bin/bash -e
# Copyright by California Institute of Technology, University of Cincinnati
# All rights reserved. See LICENSE file at:
# https://github.com/cmcghan/vagrant-rss

#
# in the initialization process for vagrant, this bash script is run as user 'root' from /vagrant
#

echo "Start of install_ws4py.sh script!"
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

#WS4PY_VER="0.3.5"
WS4PY_VER="0.4.3.dev0" # 2017-05-19
WS4PY_FOUND=`python -c "import pkg_resources; print(pkg_resources.get_distribution('ws4py').version)" | grep -m 1 -o "$WS4PY_VER" | wc -l`
# pkg_resources should give '$WS4PY_VER'
# grep should find a match and repeat it
# and wc -l should give 1 if ws4py of $WS4PY_VER was found
if [ $WS4PY_FOUND -eq 1 ]; then
    echo "ws4py $WS4PY_VER already installed!"
fi
# longer test from within python:
# >>> from ws4py.client.threadedclient import WebSocketClient
# >>> testclient = WebSocketClient('ws://localhost:9090/')

# exit script immediately if libraries are already installed
if [ "$FORCE" != "-f" ] && [ $WS4PY_FOUND -eq 1 ]
then
    echo "Websocket-for-Python libraries already installed and up-to-date, exiting..."
    exit 0
fi

#
# run installation + upgrades
#

# update all packages, because "gah!" otherwise, especially for 'rosdep' stuff later
$ABSOLUTE_PATH/apt_upd_sys.sh

# for wget and possible curl use below
$ABSOLUTE_PATH/check_pkg_status_and_install.sh wget curl

# install python WebSocket library (reference: https://ws4py.readthedocs.org/en/latest/sources/install/ )
mkdir -p ~/initdeps/rosbridgeclient
cd ~/initdeps/rosbridgeclient
# if need to force, then remove old directory first
if [ "$FORCE" == "-f" ]; then
    rm -rf "WebSocket-for-Python"
fi
if [ ! -d "WebSocket-for-Python" ]; then
    git clone "https://github.com/Lawouach/WebSocket-for-Python.git"
fi
cd "WebSocket-for-Python"
if [ "$FORCE" == "-f" ] || [ $WS4PY_FOUND -eq 0 ]; then
    sudo python setup.py install
fi

echo "End of install_ws4py.sh script!"
