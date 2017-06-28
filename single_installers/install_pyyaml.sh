#!/bin/bash -e
# Copyright by University of Cincinnati
# All rights reserved. See LICENSE file at:
# https://github.com/AS4SR/vagrant-rss

#
# in the initialization process for vagrant, this bash script is run as user 'root' from /vagrant
#

echo "Start of install_pyyaml.sh script!"
echo "input arguments: [-f]"
echo "(note: optional input arguments in [])"
echo "-f sets FORCE=-f and will force a (re)install of all compiled-from-source components."

#
# find path of this-script-being-run
# see: http://stackoverflow.com/questions/630372/determine-the-path-of-the-executing-bash-script
#
RELATIVE_PATH="`dirname \"$0\"`"
ABSOLUTE_PATH="`( cd \"$RELATIVE_PATH\" && pwd )`"
echo "PATH of current script ($0) is: $ABSOLUTE_PATH"

#
# INPUT ARGUMENT PARSING:
#

# get -f (force) if given
if [ $# -eq 1 ] && [ "$1" == "-f" ]
then
    echo "-f (force) commandline argument given. Forcing install of all compiled-from-source components."
    FORCE=$1
else
    FORCE=
fi

#
# check for installation
#

# see ./templates_/bash-script-commands-for-checking-version-numbers-of-installed-stuff.txt for examples

# for now, default of recompilation...
LIBYAML_FOUND=0
PYYAML_FOUND=0

#
# run installation + upgrades
#

# update all packages, because "gah!" otherwise, especially for 'rosdep' stuff later
$ABSOLUTE_PATH/apt_upd_sys.sh

# start in the /root directory
cd ~
# make and move into directory for holding compilation files + downloads
mkdir -p ~/initdeps
cd ~/initdeps

# for wget and possible curl use below
$ABSOLUTE_PATH/check_pkg_status_and_install.sh wget curl

#
# install yaml in Python (PyYAML with LibYAML bindings) for yaml read-ins
#

# Instructions here: 
# * http://pyyaml.org/wiki/PyYAMLDocumentation
# * http://pyyaml.org/wiki/PyYAML
# * http://pyyaml.org/wiki/LibYAML

# you can install PyYAML-"proper" via:
# $ wget http://pyyaml.org/download/pyyaml/PyYAML-3.11.tar.gz
# $ tar xvzf PyYAML-3.11.tar.gz
# $ cd PyYAML-3.11
# $ sudo python setup.py install

# for LibYAML bindings to PyYAML, we do this instead:

# install LibYAML via:
cd ~/initdeps
# if need to force, then remove old directory first
if [ "$FORCE" == "-f" ]; then
    rm -rf "yaml-0.1.5"
    rm -rf yaml-0.1.5.tar.gz
fi
if [ ! -d "yaml-0.1.5" ]; then
    wget http://pyyaml.org/download/libyaml/yaml-0.1.5.tar.gz
    tar xvzf yaml-0.1.5.tar.gz
fi
cd "yaml-0.1.5"
if [ "$FORCE" == "-f" ] || [ $LIBYAML_FOUND -eq 0 ]; then
    ./configure
    make
    sudo make install
fi

# download PyYAML above, then install using LibYAML bindings:
cd ~/initdeps
# if need to force, then remove old directory first
if [ "$FORCE" == "-f" ]; then
    rm -rf "PyYAML-3.11"
    rm -rf PyYAML-3.11.tar.gz
fi
if [ ! -d "PyYAML-3.11" ]; then
    wget http://pyyaml.org/download/pyyaml/PyYAML-3.11.tar.gz
    tar xvzf PyYAML-3.11.tar.gz
fi
cd "PyYAML-3.11"
if [ "$FORCE" == "-f" ] || [ $PYYAML_FOUND -eq 0 ]; then
    sudo python setup.py --with-libyaml install
fi

#
# then:
#

#from yaml import load, dump
#try: # LibYAML
#    from yaml import CLoader as Loader, CDumper as Dumper
#except ImportError: # fallback on PyYAML
#    from yaml import Loader, Dumper
# ...
#data = load(stream, Loader=Loader)
# ...
#output = dump(data, Dumper=Dumper)

echo "End of install_pyyaml.sh script!"
