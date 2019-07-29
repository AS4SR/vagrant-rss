# vagrant-rss
Vagrantfile(s) for setting up a Virtual Machine (VM) for the Caltech RSE implementation and beyond (includes installation scripts)

The installation scripts under `single_installers` are set up to work under any Ubuntu bash instance, to perform installation of the libraries and programs in each script. (In other words, if you have a native Ubuntu 16.04 LTS isntallation, these scripts can be run at the command line -- the terminal window of the bash shell -- to install things system-wide; you don't need to install VirtualBox or Vagrant, or create a separate VM, or anything like that.)

Table of Contents
=================

* Non-Vagrantbox Use
  * Native Ubuntu 16.04 install:
  * Native Ubuntu 14.04 install (deprecated):
* Vagrantbox Installation Dependencies
* Requirements, Vagrantbox Installation and Use
  * For a ROS kinetic Vagrantbox:
  * For a ROS indigo Vagrantbox (deprecated):
  * For a ROS jade Vagrantbox (deprecated, largely unsupported):
  * Shutting down the Vagrant session:
  * Choice of access to VirtualBox:
  * Post-install updates to Vagrant VM:
  * If you run into issues with vagrant ssh on Windows 10...
* License
* Contact

Post-install and/or Non-Vagrantbox Use
======================================

Native Ubuntu 18.04 install:
----------------------------

The scripts that have been updated to work for melodic so far include:

install_all_rssdeps.sh
    get_rv_su_wd_f.sh
    apt_upd_sys.sh
    install_tulip1.2.0.sh # may require updating / newer tulip script
        apt_upd_sys.sh
        install_glpk_cvxopt.sh
            get_os_codename.sh
            apt_upd_sys.sh
            check_pkg_status_and_install.sh
        install_gr1c.sh
            get_os_codename.sh
            apt_upd_sys.sh
            check_pkg_status_and_install.sh            
        check_pkg_status_and_install.sh
    check_pkg_status_and_install.sh
    install_rosstuff_setup_catkinworkspace.sh
        get_rv_su_wd_f.sh
        apt_upd_sys.sh
        check_pkg_status_and_install.sh
        install_appropriate_ros_version.sh
            get_rv_su_wd_f.sh
            apt_upd_sys.sh
            check_pkg_status_and_install.sh
        install_gazebo_plus_rospkgs.sh
            get_rv_su_wd_f.sh
            apt_upd_sys.sh
            check_pkg_status_and_install.sh
        set_up_catkin_workspace.sh
            get_rv_su_wd_f.sh
        install_ROSARIA.sh
            get_os_codename.sh
            get_rv_su_wd_f.sh
            apt_upd_sys.sh
            check_pkg_status_and_install.sh
        install_MobileSim.sh # requires fixing, old website no longer online
            get_os_codename.sh
            get_rv_su_wd_f.sh
            apt_upd_sys.sh
            check_pkg_status_and_install.sh
        install_ws4py.sh
            get_rv_su_wd_f.sh
            apt_upd_sys.sh
            check_pkg_status_and_install.sh
        install_p3dx_ros.sh
            get_rv_su_wd_f.sh
            install_appropriate_ros_version.sh # more stuff under this, see above
            install_gazebo_plus_rospkgs.sh # more stuff under this, see above
            set_up_catkin_workspace.sh # more stuff under this, see above
            apt_upd_sys.sh
            check_pkg_status_and_install.sh
        install_turtlebot_ros.sh
            get_rv_su_wd_f.sh
            apt_upd_sys.sh
            check_pkg_status_and_install.sh
            install_appropriate_ros_version.sh # more stuff under this, see above
            install_gazebo_plus_rospkgs.sh # more stuff under this, see above
            set_up_catkin_workspace.sh # more stuff under this, see above
        #install_uwsim_ros.sh
            get_rv_su_wd_f.sh
            apt_upd_sys.sh
            check_pkg_status_and_install.sh
        #install_usarsim_ros.sh # not ready yet!
            get_rv_su_wd_f.sh
            apt_upd_sys.sh
            check_pkg_status_and_install.sh
        #install_crumb_ros.sh
            get_rv_su_wd_f.sh
            install_appropriate_ros_version.sh # more stuff under this, see above
            install_gazebo_plus_rospkgs.sh # more stuff under this, see above
            set_up_catkin_workspace.sh # more stuff under this, see above
            install_turtlebot_ros.sh # more stuff under this, see above
            apt_upd_sys.sh
            check_pkg_status_and_install.sh
        install_hector_quadrotor.sh
            get_rv_su_wd_f.sh
            install_appropriate_ros_version.sh # more stuff under this, see above
            install_gazebo_plus_rospkgs.sh # more stuff under this, see above
            set_up_catkin_workspace.sh # more stuff under this, see above
            apt_upd_sys.sh
            check_pkg_status_and_install.sh
        #install_SURF2016_deps.sh
            apt_upd_sys.sh
            check_pkg_status_and_install.sh
        #install_widowx_ros.sh # not ready yet!
            get_rv_su_wd_f.sh
            install_appropriate_ros_version.sh # more stuff under this, see above
            install_gazebo_plus_rospkgs.sh # more stuff under this, see above
            set_up_catkin_workspace.sh # more stuff under this, see above
            apt_upd_sys.sh
            check_pkg_status_and_install.sh
    install psulu_deps.sh
        apt_upd_sys.sh
        check_pkg_status_and_install.sh
        install_ipopt.sh
            get_os_codename.sh
            apt_upd_sys.sh
            check_pkg_status_and_install.sh
    install_MC_behavior_tree.sh
        get_os_codename.sh
        apt_upd_sys.sh
        check_pkg_status_and_install.sh
    install_rrtsharp_deps.sh
        get_os_codename.sh
        apt_upd_sys.sh
        check_pkg_status_and_install.sh
    install_pyyaml.sh
        apt_upd_sys.sh
        check_pkg_status_and_install.sh
    install_ompl.sh
        apt_upd_sys.sh
        install_glpk_cvxopt.sh # more stuff under this, see above
        check_pkg_status_and_install.sh
    #install_ompl_noomplapp_nopythonbindings.sh
        get_rv_su_wd_f.sh
        apt_upd_sys.sh
        check_pkg_status_and_install.sh
    install_tensorflow0.8.0.sh
        apt_upd_sys.sh
        check_pkg_status_and_install.sh


install_tulip1.1a.sh
    apt_upd_sys.sh
    install_glpk_cvxopt.sh
        get_os_codename.sh
        apt_upd_sys.sh
        check_pkg_status_and_install.sh
    install_gr1c.sh
        get_os_codename.sh
        apt_upd_sys.sh
        check_pkg_status_and_install.sh            
    check_pkg_status_and_install.sh

quick_install_ros_gazebo_and_catkin_ws.sh
    get_rv_su_wd_f.sh
    install_appropriate_ros_version.sh # more stuff under this, see above
    install_gazebo_plus_rospkgs.sh # more stuff under this, see above
    set_up_catkin_workspace.sh # more stuff under this, see above







Native Ubuntu 16.04 install:
----------------------------

Note that these install scripts (install_deps.sh, and the scripts in the single_installers directory) can be used separately on a native Ubuntu 14.04 install. To do so, try:

    mkdir -p ~/git_pulls && cd ~/git_pulls
    git clone https://github.com/AS4SR/vagrant-rss.git
    cd vagrant-rss
    sudo su
    ./install_all_rss_deps.sh ROSVERSION SCRIPTUSER

where **SCRIPTUSER** should be replaced with the name of your user account (e.g., **vagrant** if your username is vagrant and you want to set up the ROS catkin workspace inside your directory), and **ROSVERSION** is the ROS distro to install (**kinetic**). (An example would be: `./install_all_rss_deps.sh kinetic john_doe`.)

This will download and compile libraries under `~/initdeps` and install them system-wide, and create (and/or update) a catkin workspace located under `/home/SCRIPTUSER/catkin_ws`.

If you want to specify a nonstandard location for the catkin workspace, then try:

    ./install_all_rss_deps.sh ROSVERSION SCRIPTUSER WORKSPACEDIR

where **WORKSPACEDIR** should be replaced with the abolsute path where you want the workspace to be (e.g., `/home/vagrant/my_workspace`). Note that the default path for the workspace will be `/home/SCRIPTUSER/catkin_ws`, with an expected source directory under `/home/SCRIPTUSER/catkin_ws/src`. (An example would be: `./install_all_rss_deps.sh kinetic john_doe /home/john_doe/my_workspace`.)

If you need to force a reinstall, you can use a `-f` flag. You can do this via:  
    `./install_all_rss_deps.sh ROSVERSION SCRIPTUSER -f`  
or  
    `./install_all_rss_deps.sh ROSVERSION SCRIPTUSER WORKSPACEDIR -f`

If you want to do a local (somewhat sandboxed) install instead of a system-wide install, you can do that via **virtualenv** instead of sudo (ref: [link](http://www.pythonforbeginners.com/basics/how-to-use-python-virtualenv)):

    sudo apt install python-virtualenv
    mkdir ~/virtualenvironment
    virtualenv ~/virtualenvironment
    cd ~/virtualenvironment
    source activate # to enter the virtual environment
    mkdir -p ~/virtualenvironment/git_pulls && cd ~/virtualenvironment/git_pulls
    git clone https://github.com/AS4SR/vagrant-rss.git
    cd vagrant-rss
    ./install_all_rss_deps.sh ROSVERSION SCRIPTUSER
    # once everything you want is installed, do stuff!
    deactivate # to leave the virtual environment

Native Ubuntu 14.04 install (deprecated):
-----------------------------------------

Note that these install scripts (install_deps.sh, and the scripts in the single_installers directory) can be used separately on a native Ubuntu 14.04 install. To do so, try:

    ./install_all_rss_deps.sh ROSVERSION SCRIPTUSER

where **SCRIPTUSER** should be replaced with the name of your user account (e.g., **vagrant** if your username is vagrant and you want to set up the ROS catkin workspace inside your directory), and **ROSVERSION** is the ROS distro to install (either **indigo** or **jade**).

Alternately, you may want to use the original RSS script. If so, use `sudo git clone -b master https://github.com/AS4SR/vagrant-rss.git /vagrant` instead of the current kinetic branch.

Vagrantbox Installation Dependencies
====================================

Install VirtualBox and Vagrant on your machine first before attempting to use the Vagrantfile(s) in this repository:
* VirtualBox: https://www.virtualbox.org/wiki/Downloads
* Vagrant: https://www.vagrantup.com/downloads.html

Optional install:
* Git: https://git-scm.com/downloads
 * note that you can download and unpack the repo manually if you don't want to install git to your main O/S environment
 * https://github.com/AS4SR/vagrant-rss/archive/master.zip
 * https://github.com/AS4SR/vagrant-rss/archive/ubuntu-16.04-xenial.zip

Requirements, Vagratnbox Installation and Use
=============================================

See the individual Vagrantfile(s) for up-to-date information on requirements, setup, and use.

Note that the default vagrantfile ("Vagrantfile") is a copy of Vagrantfile.indigo

It is recommended that you create and use the ROS indigo VagrantBox virtual machine, as the turtlebot libraries are supported natively in indigo, but not jade.

For a ROS kinetic Vagrantbox:
-----------------------------

The virtual machine created by the jade Vagrantfile requires:
* 2 CPUs, 4GB RAM, 40GB space (dynamic)

So if you want to use this Vagrantfile, you will need:
* a virtual 4-core CPU or higher, >8GB RAM, >30GB of space free

Note that the default vagrantfile Vagrantfile is a copy of Vagrantfile.indigo, thus you must copy the kinetic Vagrantfile over first before the `vagrant up` command here.

The intended usage is:

    git clone https://github.com/AS4SR/vagrant-rss.git
    cd vagrant-rss
    cp Vagrantfile.kinetic Vagrantfile
    vagrant box add ubuntu/xenial64
    vagrant up --provider virtualbox
    vagrant ssh
    cd ~/catkin_ws/src/rss_work

For a ROS indigo Vagrantbox (deprecated):
-----------------------------------------

The virtual machine created by the indigo Vagrantfile requires:
* 2 CPUs, 4GB RAM, 40GB space (dynamic)

So if you want to use this Vagrantfile, you will need:
* a virtual 4-core CPU or higher, >8GB RAM, >30GB of space free

Note that the default vagrantfile Vagrantfile is a copy of Vagrantfile.kinetic, thus you must copy the jade Vagrantfile over first before the `vagrant up` command (via `cd vagrant-rss && cp Vagrantfile.indigo Vagrantfile`).

For a ROS jade Vagrantbox (deprecated, largely unsupported):
------------------------------------------------------------

The virtual machine created by the jade Vagrantfile requires:
* 4 CPUs, 4GB RAM, 40GB space (dynamic)

So if you want to use this Vagrantfile, you will need:
* a virtual 8-core CPU or higher, >8GB RAM, >30GB of space free

Note that the default vagrantfile Vagrantfile is a copy of Vagrantfile.kinetic, thus you must copy the jade Vagrantfile over first before the `vagrant up` command (via `cd vagrant-rss && cp Vagrantfile.jade Vagrantfile`).
    
Shutting down the Vagrant session:
----------------------------------

When you are done using your Vagrantbox, run  
`vagrant halt`  
to shut down the VM session.

When you wish to connect to the Vagrantbox again, try:

    vagrant up
    vagrant ssh

to start the virtual machine up again.

Choice of access to VirtualBox:
-------------------------------

Note that use of `vagrant ssh` will log you in as user "vagrant", while the VirtualBox GUI will initially log you in as user "ros".

In order to work in the VirtualBox GUI as user "vagrant", first create the Vagrantbox as per the instructions above, then run

    vagrant halt

to stop the current session.

After this:
* Open your VirtualBox application.
* Select the "rss_indigo_development_machine" or "rss_jade_development_machine" or "rss_kinetic_development_machine" in the left panel, and click on "Start".

The VM session should start, and you should be logged in automatically as user "ros".

Now, to work as user "vagrant":
* Left-click on the gear symbol in the upper-right corner, and select "Log Out..."
* Click on the right-hand icon ("Log Out").
* Wait for the user menu to come up, then select user "vagrant". Default password is the login name.

You should now be logged into the VirtualBox VM as user "vagrant".

Post-install updates to Vagrant VM:
-----------------------------------

Note that the `git clone`'d directory  
`./vagrant-rss`  
is synced with  
`/vagrant`  
in the VM.

Inside the Vagrantbox, these scripts can be rerun post-setup, after the initial `vagrant up` command, via:

    cd /vagrant
    sudo su
    ./install_all_rss_deps.sh ROSVERSION vagrant -f

where **ROSVERSION** is the ROS distro to reinstall (either **indigo** or **jade** or **kinetic**), and **-f** will force-reinstall the installed-from-source libraries.

The latter is most useful when the installation scripts in the github repository have been updated -- one can simply `git pull` an updated version of the installation scripts and then rerun them to install the new library dependencies, via:

    cd /vagrant
    sudo su
    git pull
    ./install_all_rss_deps.sh ROSVERSION vagrant -f

If you run into issues with vagrant ssh on Windows 10...
--------------------------------------------------------

If you try running `vagrant ssh` and get the following error message in your terminal:

    `ssh` executable not found in any directories in the %PATH% variable.

Then try the following at the commandline:

    set PATH=%PATH%;'C:\Program Files\Git\usr\bin'

If you want to make this change permanent, -carefully- perform the following:
* Go to Control Panel-> Security->System and left-click on the link 'Advanced System Settings' in the left toolbar.
* Go to the 'Advanced' tab, then left-click the 'Environment Variables...' button at the bottom of the tab.
* Under 'System Variables' (the lower box), left-click on 'Path' and then left-click on the 'Edit...' button.
* Be careful when you edit this! Click on the 'New' button, add an entry for `C:\Program Files\Git\usr\bin` and hit the enter key. The text should end up at the bottom of the list (which you want).
* Exit out of all dialog boxes.


License
=======

This is free software released under the terms of the BSD 3-Clause License. There is no warranty; not even for merchantability or fitness for a particular purpose. Consult LICENSE for copying conditions.

When code is modified or re-distributed, the LICENSE file should accompany the code or any subset of it, however small. As an alternative, the LICENSE text can be copied within files, if so desired.


Contact
=======

If you have any questions regarding the contents of this repository, please email Catharine McGhan at <cat.mcghan@uc.edu>.

-EOF-
