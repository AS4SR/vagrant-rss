#!/bin/bash -e
# Copyright by California Institute of Technology, University of Cincinnati
# All rights reserved. See LICENSE file at:
# https://github.com/cmcghan/vagrant-rss

#
# in the initialization process for vagrant, this bash script is run as user 'root' from /vagrant
#

#
# Note: Ubuntu X-Windows Desktop and ROS indigo are pre-installed
# on the "shadowrobot/ros-indigo-desktop-trusty64" base box
#

echo "Start of install_ompl.sh script!"
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
if [ $# -eq 1 ] && [ "$1" == "-f" ]; then
    echo "-f (force) commandline argument given. Forcing install of all compiled-from-source components."
    FORCE=$1
else
    FORCE=
fi

#
# check for installation
#

# installs stuff to (among other places):
#/usr/local/lib/x86_64-linux-gnu/libompl_app*
#/usr/local/lib/python2.7/dist-packages/ompl
#/usr/local/share/ompl
#/usr/local/include/omplapp
#/usr/local/bin/ompl_app
#/usr/local/bin/ompl_benchmark_statistics.py

# other checks for things:
# gccxml --version
# python -c "import pygccxml, pyplusplus"
# Py++ installs to (this or similar): /usr/local/lib/python2.7/dist-packages/Py_-1.0.0.egg-info
GCCXML_FOUND=`gccxml --version | grep -m 1 "GCC-XML version 0.9.0" | wc -l`
if [ $GCCXML_FOUND -eq 1 ]; then
    echo "gccxml 0.9.0 already installed!"
fi

PYGCCXML_FOUND=`python -c "import pkg_resources; print(pkg_resources.get_distribution('pygccxml').version)" | grep -m 1 -o "v1.6.1" | wc -l`
# pkg_resources should give '???'
# grep should find a match and repeat it
# and wc -l should give 1 if pygccxml 1.6.1 was found

# version number not set inside python (pkg_resources won't work)
if [ ! -f /usr/local/lib/python2.7/dist-packages/Py_-1.0.0.egg-info ]; then
    PYPLUSPLUS_FOUND=0
else
    echo "pyplusplus 1.0.0 already installed!"
    PYPLUSPLUS_FOUND=1
fi
# alt. method is:
# this pipes stderr ("2>") to grep using ">()" and wc -l counts the number of lines
#PYTHON_FINDS_PYPLUSPLUS=`python -c "import pyplusplus" 2> >(grep -m 1 -o "ImportError") | wc -l`
# 0 if fine, 1 if get an ImportError
#if [ $PYTHON_FINDS_PYPLUSPLUS -eq 0 ]
#then
#    echo "pyplusplus python libraries found by python!"
#    PYPLUSPLUS_FOUND=1
#else
#    PYPLUSPLUS_FOUND=0
#fi

if [ ! -f /usr/local/lib/x86_64-linux-gnu/libompl_app.so.1.1.1 ] || [ ! -f /usr/local/lib/x86_64-linux-gnu/libompl.so.1.1.1 ]; then
    OMPLCPP_FOUND=0
else
    echo "OMPL and OMPLapp 1.1.1 cpp already installed!"
    OMPLCPP_FOUND=1
fi

# this pipes stderr ("2>") to grep using ">()" and wc -l counts the number of lines
PYTHON_FINDS_OMPL=`python -c "import ompl" 2> >(grep -m 1 -o "ImportError") | wc -l`
# 0 if fine, 1 if get an ImportError
if [ $PYTHON_FINDS_OMPL -eq 0 ]; then
    echo "OMPL python libraries found by python!"
    OMPLPY_FOUND=1
else
    OMPLPY_FOUND=0
fi

#if [ ! -f /usr/local/lib/python2.7/dist-packages/ompl/geometric/_geometric.so ] || [ ! -f /usr/local/lib/python2.7/dist-packages/ompl/app/_app.so ]
#then
#    OMPLPY_FOUND=0
#else
#    echo "OMPL geometric and OMPLapp 1.1.1 pybindings already installed!"
#    OMPLPY_FOUND=1
#fi

# exit script immediately if libraries are already installed
if [ "$FORCE" != "-f" ] && [ $OMPLCPP_FOUND -eq 1 ] && [ $OMPLPY_FOUND -eq 1 ]; then
    echo "OMPL libraries already installed and (the cpp version, at least) looks to be up-to-date, exiting..."
    exit 0
fi

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

# install glpk and cvxopt:
#/vagrant/single_installers/install_glpk_cvxopt.sh $FORCE
$ABSOLUTE_PATH/install_glpk_cvxopt.sh $FORCE

# back to compilation/install directory (/root/initdeps)
cd ~/initdeps

# for wget and possible curl use below
$ABSOLUTE_PATH/check_pkg_status_and_install.sh wget curl

# install OMPL libraries (cvxopt and glpk already installed above)
$ABSOLUTE_PATH/check_pkg_status_and_install.sh software-properties-common # for add-apt-repository
sudo add-apt-repository -y ppa:libccd-debs/ppa # libccd-dev requires ppa
sudo apt-get -y update # update to include new ppa repo list(s)
$ABSOLUTE_PATH/check_pkg_status_and_install.sh libboost-all-dev cmake libccd-dev python-dev python-qt4-dev python-qt4-gl python-opengl freeglut3-dev libassimp-dev libeigen3-dev libode-dev doxygen graphviz
#$ABSOLUTE_PATH/check_pkg_status_and_install.sh libompl-dev
$ABSOLUTE_PATH/check_pkg_status_and_install.sh texlive-fonts-recommended # required for 'make doc' not to hang
$ABSOLUTE_PATH/check_pkg_status_and_install.sh python-pip
sudo pip install PyOpenGL-accelerate
# when make update_bindings, it also looks for PY_FLASK and PY_CELERY(?), so install these, too?
sudo pip install flask
sudo pip install celery
sudo pip install Flask-Celery-Helper
# end 'pip install's
cd ~/initdeps
# if need to force, then remove old directory first
if [ "$FORCE" == "-f" ]; then
    rm -rf omplapp-1.1.1-Source
fi
if [ "$FORCE" == "-f" ] || [ ! -f omplapp-1.1.1-Source.tar.gz ]; then
    wget https://bitbucket.org/ompl/ompl/downloads/omplapp-1.1.1-Source.tar.gz
    tar xvzf omplapp-1.1.1-Source.tar.gz
fi
cd omplapp-1.1.1-Source
mkdir -p build/Release
cd build/Release
echo " "
echo "Now performing: cmake ../.."
echo " "
echo "(1) NOTE: IF A FIREFOX WINDOW POPS UP ASKING YOU TO REGISTER, YOU MUST CLOSE IT FOR THE INSTALLATION TO CONTINUE!"
echo " "
echo " "
cmake ../..
echo "Done with 'cmake ../..'."
# installpyplusplus -->/usr/local/bin/gccxml_cc1plus
# --> /usr/local/share/gccxml-0.9/*
# --> /usr/local/bin/gccxml
# --> /usr/local/lib/python2.7/dist-packages/Py_-1.0.0.egg-info
if [ "$FORCE" == "-f" ] || [ $GCCXML_FOUND -eq 0 ] || [ $PYGCCXML_FOUND -eq 0 ] || [ $PYPLUSPLUS_FOUND -eq 0 ]; then
    echo " "
    echo "Now performing: make installpyplusplus && cmake ."
    echo " "
    make installpyplusplus && cmake . # download & install Py++
    echo "Done with 'make installpyplusplus && cmake .'"
else
    echo "gccxml, pygccxml, pyplusplus already installed. Skipping 'make installpyplusplus && cmake .' step."
fi
echo " "
echo "Now performing: make update_bindings..."
echo " "
make update_bindings # can have memory issues at this step(?!) or is it the next one(?) ("internal compiler error: Killed (program cc1plus)")
echo "Done with 'make update_bindings'."
echo " "
echo "Now performing: make -j 2..."
echo " "
make -j 2 # -j 4 is for 4 parallel jobs (e.g., 4 cores)
echo "Done with 'make -j 2'."
echo " "
#echo "Now performing: make test..."
#echo " "
#make test
#echo "Done with 'make test'."
#echo " "
echo "Now performing: make doc..."
echo " "
make doc
echo "Done with 'make doc'."
echo " "
echo "Now performing: sudo make install..."
echo " "
sudo make install
echo "Done with 'sudo make install'."

echo "End of install_ompl.sh script!"
