#!/bin/bash -e
# Copyright by California Institute of Technology, University of Cincinnati
# All rights reserved. See LICENSE file at:
# https://github.com/cmcghan/vagrant-rss

#
# in the initialization process for vagrant, this bash script is run as user 'root' from /vagrant
#

echo "Start of install_tensorflow0.8.0.sh script!"
echo "input arguments: [SCRIPTUSER] [-f]"
echo "(note: optional input arguments in [])"
echo "(note: order of [SCRIPTUSER] and -f argument can be swapped)"
echo "(note: default SCRIPTUSER is \"vagrant\")"
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

# set defaults for input arguments
SCRIPTUSER=vagrant
FORCE=
# if we get an input parameter (username) then use it, else use default 'vagrant'
# get -f (force) if given
if [ $# -lt 1 ]; then
    echo "Single username not given as commandline argument. Using default of '$SCRIPTUSER'."
    exit
else # at least 1 (possibly 2) argument(s) at commandline...
    if [ "$1" == "-f" ]; then
        echo "-f (force) commandline argument given."
        FORCE=$1
    else
        echo "Username given as commandline argument."
        SCRIPTUSER=$1
    fi
    if [ $# -gt 1 ]; then # at least 2 (possibly more) arguments at commandline...
        if [ "$2" == "-f" ]; then
            echo "-f (force) commandline argument given."
            FORCE=$2
        elif [ "$SCRIPTUSER" == "vagrant" ]; then
            echo "Username given as commandline argument."
            SCRIPTUSER=$2
        else
            echo "Username already set. Second argument ignored."
        fi
    fi
fi
echo "Will be using user $SCRIPTUSER and directories at and under /home/$SCRIPTUSER..."
if [ "$FORCE" == "-f" ]; then
    echo "Forcing install of all compiled-from-source components."
fi

#
# check for installation
#

:

#
# run installation + upgrades
#

# update all packages, because "gah!" otherwise, especially for 'rosdep' stuff later
$ABSOLUTE_PATH/apt_upd_sys.sh

# for wget and possible curl use below
$ABSOLUTE_PATH/check_pkg_status_and_install.sh wget curl

# install Google TensorFlow for Ravi Kiran's machine learning work:
# installation instructions are from:
# -- https://www.tensorflow.org/versions/r0.8/get_started/os_setup.html#download-and-setup
# -- https://www.tensorflow.org/versions/r0.8/get_started/os_setup.html#optional-install-cuda-gpus-on-linux
# dependencies are auto-installed/upgraded via setup.py: numpy >=1.8.2, six >=1.10.0, protobuf ==3.0.0b2
# for python3: wheel >=0.26
# see: https://github.com/tensorflow/tensorflow/blob/master/tensorflow/tools/pip_package/setup.py
#cd ~/initdeps
#$ABSOLUTE_PATH/check_pkg_status_and_install.sh python-pip python-dev
##sudo pip install --upgrade numpy
##sudo pip install --upgrade six
##sudo pip install --upgrade https://storage.googleapis.com/tensorflow/linux/cpu/protobuf-3.0.0b2.post2-cp27-none-linux_x86_64.whl
#sudo pip install --upgrade https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.8.0-cp27-none-linux_x86_64.whl # no-GPU install

# check library installation via:
# python -c "import tensorflow as tf;print(tf.__version__);" # should give version number of 0.8.0

# the above may not work due to the "OS owning the install" of wheel and six
# so try a VirtualEnv instead, see: https://www.tensorflow.org/versions/r0.8/get_started/os_setup.html#virtualenv-installation
# install dependencies: pip, virtualenv
$ABSOLUTE_PATH/check_pkg_status_and_install.sh python-pip python-dev python-virtualenv
# "Create a Virtualenv environment in the directory ~/tensorflow":
su - $SCRIPTUSER -c "source /home/$SCRIPTUSER/.bashrc;virtualenv --system-site-packages /home/$SCRIPTUSER/tensorflow;"
# "Activate the environment and use pip to install TensorFlow inside it":
su - $SCRIPTUSER -c "source /home/$SCRIPTUSER/.bashrc;source /home/$SCRIPTUSER/tensorflow/bin/activate;pip install --upgrade https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.8.0-cp27-none-linux_x86_64.whl;deactivate"
## "Ubuntu/Linux 64-bit, GPU enabled. Requires CUDA toolkit 7.5 and CuDNN v4."
##(tensorflow)$ pip install --upgrade https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-0.8.0-cp27-none-linux_x86_64.whl
# "and again for python3":
$ABSOLUTE_PATH/check_pkg_status_and_install.sh python3-pip
#su - $SCRIPTUSER -c "source /home/$SCRIPTUSER/.bashrc;source /home/$SCRIPTUSER/tensorflow/bin/activate;pip3 install --upgrade https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.8.0-cp34-cp34m-linux_x86_64.whl;deactivate;" # gives "PermissionError: [Errno 13] Permission denied: '/usr/lib/python3.4/site-packages'"
su - $SCRIPTUSER -c "source /home/$SCRIPTUSER/.bashrc;source /home/$SCRIPTUSER/tensorflow/bin/activate;sudo pip3 install --upgrade https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.8.0-cp34-cp34m-linux_x86_64.whl;deactivate;" # sudo??? but has issues with python3 packages (wheel, six, setuptools)
## "Ubuntu/Linux 64-bit, GPU enabled. Requires CUDA toolkit 7.5 and CuDNN v4."
#(tensorflow)$ pip3 install --upgrade https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-0.8.0-cp34-cp34m-linux_x86_64.whl

# check python library installation via:
su - $SCRIPTUSER -c "source /home/$SCRIPTUSER/.bashrc;source /home/$SCRIPTUSER/tensorflow/bin/activate;python -c \"import tensorflow as tf;print(tf.__version__)\";deactivate;" # should give version number of 0.8.0
# check python3 library installation via:
su - $SCRIPTUSER -c "source /home/$SCRIPTUSER/.bashrc;source /home/$SCRIPTUSER/tensorflow/bin/activate;python3 -c \"import tensorflow as tf;print(tf.__version__);\";deactivate;" # should give version number of 0.8.0

#With the Virtualenv environment activated, you can now test your installation.
#
# To use TensorFlow later you will have to activate the Virtualenv environment again:
#$ source ~/tensorflow/bin/activate  # If using bash.
#(tensorflow)$  # Your prompt should change.
# Run Python programs that use TensorFlow.
#...
# When you are done using TensorFlow, deactivate the environment.
#(tensorflow)$ deactivate

# optional dependency of CUDA: "NVIDIA's Cuda Toolkit (>= 7.0) and cuDNN (>= v2) need to be installed"
# for Linux x86_64 Ubuntu 14.04 ("network" deb), https://developer.nvidia.com/cuda-downloads
#cd ~/initdeps
#wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1404/x86_64/cuda-repo-ubuntu1404_7.5-18_amd64.deb # (md5sum: e810ded23efe35e3db63d2a92288f922)
#sudo dpkg -i cuda-repo-ubuntu1404_7.5-18_amd64.deb
#sudo apt-get update
#$ABSOLUTE_PATH/check_pkg_status_and_install.sh cuda
# a manual download of cuDNN will need to occur (requires registration), https://developer.nvidia.com/cudnn
#tar xvzf cudnn-6.5-linux-x64-v2.tgz
#sudo cp cudnn-6.5-linux-x64-v2/cudnn.h /usr/local/cuda/include
#sudo cp cudnn-6.5-linux-x64-v2/libcudnn* /usr/local/cuda/lib64
#sudo chmod a+r /usr/local/cuda/lib64/libcudnn*
# then download the source tree for TensorFlow and run through manual configure process
# "Ubuntu/Linux 64-bit, GPU enabled. Requires CUDA toolkit 7.5 and CuDNN v4.  For other versions, see "Install from sources" below.", https://www.tensorflow.org/versions/r0.8/get_started/os_setup.html#installation-for-linux
#$ sudo pip install --upgrade https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-0.8.0-cp27-none-linux_x86_64.whl

# install TensorFlow from source via:
#cd ~/initdeps
#git clone --recurse-submodules https://github.com/tensorflow/tensorflow -b release # for release branch
# install dependencies for bazel (OpenJDK 8), see: http://bazel.io/docs/install.html
#$ABSOLUTE_PATH/check_pkg_status_and_install.sh software-properties-common # if no "add-apt-repositories" command
#sudo add-apt-repository ppa:webupd8team/java
#sudo apt-get update
#$ABSOLUTE_PATH/check_pkg_status_and_install.sh oracle-java8-installer
# download bazel, see: https://github.com/bazelbuild/bazel/releases
##wget https://github.com/bazelbuild/bazel/releases/download/0.2.2b/bazel-0.2.2b-installer-linux-x86_64.sh
#wget https://github.com/bazelbuild/bazel/releases/download/0.2.2b/bazel_0.2.2b-linux-x86_64.deb
# install bazel
##chmod +x bazel-0.2.2b-installer-linux-x86_64.sh
##./bazel-0.2.2b-installer-linux-x86_64.sh --user
#sudo dpkg -i bazel_0.2.2b-linux-x86_64.deb
#sudo apt-get update
#$ABSOLUTE_PATH/check_pkg_status_and_install.sh bazel
## place bazel on your binary path (for system-wide use)
##sudo cp /home/$SCRIPTUSER/bin/??? /usr/local/bin/???
## alt.: add bazel to .bashrc file(?)
#sudo -u $SCRIPTUSER echo "export PATH=\"\$PATH:\$HOME/bin\"" >> /home/$SCRIPTUSER/.bashrc
# install other dependencies
#$ABSOLUTE_PATH/check_pkg_status_and_install.sh python-pip python-dev
#$ABSOLUTE_PATH/check_pkg_status_and_install.sh python-numpy swig python-dev
# source-install TensorFlow ("\n" default python path, "N\n"(no) do not attempt to build with GPU support (CUDA libraries))
#cd ~/initdeps/tensorflow
# To build without GPU support:
#./configure << printf "\nN\n"
#bazel build -c opt //tensorflow/tools/pip_package:build_pip_package
# To build with GPU support:
##./configure << printf "\ny\n???????"
##bazel build -c opt --config=cuda //tensorflow/tools/pip_package:build_pip_package
#bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg
# The name of the .whl file will depend on your platform.
#sudo pip install /tmp/tensorflow_pkg/tensorflow-0.8.0-py2-none-linux_x86_64.whl
##bazel build -c opt --config=cuda //tensorflow/cc:tutorials_example_trainer
##bazel-bin/tensorflow/cc/tutorials_example_trainer --use_gpu
# if source-install with GPU support, then add the environment variables to your ~/.bash_profile
#sudo -u $SCRIPTUSER echo "export LD_LIBRARY_PATH=\"\$LD_LIBRARY_PATH:/usr/local/cuda/lib64\"" >> /home/$SCRIPTUSER/.bash_profile
#sudo -u $SCRIPTUSER echo "export CUDA_HOME=/usr/local/cuda" >> /home/$SCRIPTUSER/.bash_profile

echo "End of install_tensorflow0.8.0.sh script!"
