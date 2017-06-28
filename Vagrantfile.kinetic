# Emacs, this is in -*- ruby -*-
# Copyright by California Institute of Technology, University of Cincinnati
# All rights reserved. See LICENSE file at:
# https://github.com/AS4SR/vagrant-rss
#
# ---- REQUIREMENTS ----
#
# The virtual machine created by this Vagrantfile requires: 2 CPUs, 4GB RAM, 40GB space
# Your computer should have: virtual 4-core CPU or higher, >6GB memory, >50GB space free
# -- Note that the VM needs 4GB RAM, not just 2GB RAM, due to the OMPL compilation erroring
#    out quite a bit otherwise during the 'make update_bindings' step (see install_ompl.sh).
#
# Install VirtualBox and Vagrant on your machine first before attempting to use this file:
# * VirtualBox: https://www.virtualbox.org/wiki/Downloads
# * Vagrant: https://www.vagrantup.com/downloads.html
#
# ---- SETUP AND USE ----
#
# The directory this file resides within is synced with
#   /vagrant
# in the VM.
#
# The intended usage is:
#   git clone -b ubuntu-16.04-xenial https://github.com/AS4SR/vagrant-rss.git
#   cd vagrant-rss
#   cp Vagrantfile.kinetic Vagrantfile
#   vagrant box add ubuntu/xenial64
#   vagrant up --provider virtualbox
#   vagrant ssh
#   cd ~/catkin_ws/src/rss_work
#
# We recommend you change your password after the first login (type 'passwd').
# For X-Window forwarding through ssh in MacOSX or Linux, use 'vagrant ssh -- -X' instead
# and uncomment the "config.ssh.forward_x11 = true" at line 87 below.
#
# When you are done, close ssh and type 'vagrant suspend' or 'vagrant halt' in the shell.
# --> Note that 'vagrant destroy' is NOT recommended, since the initial installation of
# the X-Windows GUI(+Unity) and ROS jade can take an hour, and OMPL compilation can take
# around an hour or longer to finish the provisioning process on the initial 'vagrant up'!!
#
# Note that if you are using Windows, you will need to run these commands from either
# * the shell (Start->Run->cmd)
# =OR=
# * WindowsPowerShell (recommended).
#
# Also note that, under Windows, 'vagrant ssh' will likely not work, so either
# * uncomment 'vb.gui = true' below so that VirtualBox will show the usual interface
# =OR=
# * install PuTTY+Xming for ssh access with X-Windows support (127.0.0.1, port 2222)
#   and uncomment the "config.ssh.forward_x11 = true" at line 87 below.
#
# ----REFERENCES ----
#
# This file was modified from tulip-control's Vagrantfile:
# https://github.com/tulip-control/tulip-control/blob/master/contrib/Vagrantfile
#
# Base box used:
# https://atlas.hashicorp.com/ubuntu/boxes/xenial64
#
# We also used a modified version of the 'increase swap memory' example from:
# https://jeqo.github.io/blog/devops/vagrant-quickstart/
#
# Other references:
# https://docs.vagrantup.com/v2/getting-started/boxes.html
# https://atlas.hashicorp.com/ubuntu/boxes/xenial64
# https://github.com/tulip-control/tulip-control/blob/master/contrib/nonroot-vagrant-instructions.md
# http://www.electrictoolbox.com/PuTTY-rsa-dsa-keys/
# http://unix.stackexchange.com/questions/32907/what-characters-do-i-need-to-escape-when-using-sed-in-a-sh-script
#

Vagrant.configure(2) do |config|
  #
  # general virtual machine parameters are defined here:
  #
  
  # default box:
  config.vm.box = "ubuntu/xenial64"
  # this is 1024MB memory and 16MB video RAM; 10GB drive; 2 processors; no CD/DVD drive
  # login: /home/ubuntu --> ubuntu(/)
  # You can also use the RSA private key under:
  #   .vagrant/machines/default/virtualbox/private_key
  # On Windows, load this into PuTTYGen to create a 'private_key.ppk' that PuTTY can use;
  # login via PuTTY+XMing using Connection->SSH->Auth->Private key file for authentication.

  # to allow X11 forwarding over ssh, uncomment the following line:
  #config.ssh.forward_x11 = true
  # if this is set to 'true', with 'vb.gui = false' below, then on
  # Windows you can still use PuTTY+Xming to see GUI windows pop-up
  
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--name"  , "rss_git_kinetic_development_machine"]
    vb.customize ["modifyvm", :id, "--memory", "4096"]
    vb.customize ["modifyvm", :id, "--cpus"  , 2]
    vb.customize ["modifyvm", :id, "--chipset", "ich9"]
    # Display the VirtualBox GUI when booting the machine
    vb.gui = true
  end
  #
  # The ubuntu/xenial64 box already has a disabled acct. 'ubuntu' with no default password.
  # Create password and enable sudo in GUI by typing "sudo passwd ubuntu" in the terminal
  # after having performed 'vagrant ssh' or similar using the private key.
  
  # by default, the Vagrantfile directory mounts to the shared folder /vagrant
  #config.vm.synced_folder ".", "/vagrant"

  #
  # setup commands executed at the command-line as root during first-time run are defined below:
  #
  
  # create swap file (so OMPL compilation will succeed) and install dependencies for RSE:
  config.vm.provision "shell", inline: <<-SHELL
    #!/bin/sh -e

    # 
    # create swap file (so OMPL compilation will succeed)
    #

    # size of swapfile in megabytes
    swapsize=4096
    # grep -q will kick you out immediately (quit) if a match is found
    # without -q, the -e on bash or sh would kick you out of the script
    #
    # does the swap file already exist?
    grep -q "swapfile" /etc/fstab
    # if not then create it
    if [ $? -ne 0 ]; then
      echo 'swapfile not found. Adding swapfile.'
      fallocate -l ${swapsize}M /swapfile
      chmod 600 /swapfile
      mkswap /swapfile
      swapon /swapfile
      echo '/swapfile none swap defaults 0 0' >> /etc/fstab
    else
      echo 'swapfile found. No changes made.'
    fi
    
    #
    # install Ubuntu X-Windows Desktop (for "ubuntu/xenial64" box)
    #
    sudo apt-get -y update
    sudo apt-get -y install ubuntu-desktop
    # note that this increases the disk space necessary for the vbox by several GB
    
    /vagrant/install_all_rss_deps.sh kinetic vagrant
  SHELL
end
