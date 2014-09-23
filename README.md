# puppet-r10k

Vagrant environment for PE3 (currently 3.3.2) w/ [r10k](http://github.com/adrienthebo/r10k) development and current best practices for building out self-contained environments (classification, code & data bindings).

Setup leverages work done in the zack/r10k Forge module. It includes an MCollective plug-in to allow r10k operations via Live
Management in the Enterprise Console.

The r10k environments are self-contained. Directories include:

  * hierdata directory
  * modules directory built out via Puppetfile
  * manifests/site.pp for node classification

Note: this self-contained environment structure is *the* Forest Service's Continuous Delivery repository.

# References & Supporting Materials

Supporting materials:

  * [Git Submodules Are Probably Not The Anwser](http://somethingsinistral.net/blog/git-submodules-are-probably-not-the-answer/)
  * [Rethinking Puppet Deployment](http://somethingsinistral.net/blog/rethinking-puppet-deployment/)
  * [Puppet Infrastructure with R10K](http://terrarum.net/administration/puppet-infrastructure-with-r10k.html)

# Requirements
  * rvm >= 1.25.31
  * VirtualBox == 4.3.16
  * Vagrant == 1.6.3
  * vagrant-oscar ( '$ vagrant plugin install oscar' )
  * vagrant-vbguest ( '$ vagrant plugin install vagrant-vbguest' )
  * librarian-puppet gem ( '$ gem install librarian-puppet' )
  * puppet gem ( '$ gem install puppet' )

# Upgrades
This environment uses vagrant oscar plugin. Whenever oscar is updated, engineers will need to wipe out old VMs and settings
before doing a 'vagrant up' with the new release:
  
    $ cd <repo>
    $ vagrant destroy -f
    $ rm -rf .vagrant
    $ (cd puppet && rm -rf modules)
    $ git pull

# Usage 
(perhaps after Upgrade directions above)

    $ cd <repo>
    $ (cd puppet && librarian-puppet install --verbose)
    $ vagrant up

# Notes
  * vagrant environment will download the required baseboxes if they've not already been installed. This can result in quite a long first run.
  * Login to console via: https://localhost:8443   w/ credentials:  admin@puppetlabs.com/puppetlabs
  * r10k builds out environments in master:/etc/puppetlabs/puppet/environments based on the branches puppet-r10k-environments repo. You can point r10k to a different repo by modifying the Hiera key in puppet/hierdata/common.yaml.

# Supplemental PE downloads
| Version | OS | Link |
| ------------- |:-------------:|:-----:|
| 3.3.2 | Ubuntu      | [Download](http://s3.amazonaws.com/pe-builds/released/3.3.2/puppet-enterprise-3.3.2-ubuntu-14.04-amd64.tar.gz) |
| 3.3.2 | RHEL/CentOS | [Download](http://s3.amazonaws.com/pe-builds/released/3.3.2/puppet-enterprise-3.3.2-el-6-x86_64.tar.gz) |
| 3.3.2 | Windows     | [Download](http://s3.amazonaws.com/pe-builds/released/3.3.2/puppet-enterprise-3.3.2.msi) |

# Installation steps

### UBUNTU - RARING/SAUCY

    $ sudo apt-get install git
    $ sudo apt-get install curl
    $ sudo apt-get install vagrant

>Check "Run command as login" checkbox in terminal profile. Exit and relaunch terminal application.


### OS X

>Install [git 1.8.5.2 for OS X](http://sourceforge.net/projects/git-osx-installer/files/git-1.8.5.2-intel-universal-snow-leopard.dmg/download) with defaults (admin required). 

>Install Xcode (and command-line tools) for your version of OS X (admin required). Run it once.
>xcode-select --install

>Install [VirtualBox 4.3.16 for OS X](http://download.virtualbox.org/virtualbox/4.3.16/VirtualBox-4.3.16-95972-OSX.dmg) with defaults (admin required).

>Install [Vagrant 1.6.3 for OS X](https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.3.dmg) with defaults (admin required).

>Install homebrew (if you don't already have ports installed)

    $ ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go/install)"

>If you're using ports:

    $ sudo port install libxml2 libxslt # (only if using ports)

>If you're using homebrew

    $ brew install libxml2 libxslt # (only if using homebrew)
    $ brew link libxml2 libxslt # (only if using homebrew)


### WINDOWS

>Install [git 1.9.4 for Windows](https://github.com/msysgit/msysgit/releases/download/Git-1.9.4-preview20140815/Git-1.9.4-preview20140815.exe) with defaults. (admin required)

>Install [ruby 2.2.0-p481 for 64-bit Windows](http://dl.bintray.com/oneclick/rubyinstaller/rubyinstaller-2.0.0-p481-x64.exe?direct) - Tcl/Tk support, add to path, associate. (admin required)

Extract Ruby DevKit [DevKit-mingw64-64-4.7.2-20130224-1432-sfx](http://cdn.rubyinstaller.org/archives/devkits/DevKit-mingw64-64-4.7.2-20130224-1432-sfx.exe) to C:\Ruby200-x64\DevKit (admin required as well as 7-Zip utility)

>Launch git bash

    $ cd /c/Ruby200-x64/devkit

    $ ruby dk.rb init

>add '- C:/Ruby200-x64' to bottom of config.yml

    $ ruby dk.rb install

    $ gem update # ('y' to update rake|rdoc|ri)

>Install [VirtualBox 4.3.16 for Windows](http://download.virtualbox.org/virtualbox/4.3.16/VirtualBox-4.3.16-95972-Win.exe) with defaults (admin required).

>Install [Vagrant 1.6.3 for Windows](https://dl.bintray.com/mitchellh/vagrant/Vagrant_1.6.3.msi) with defaults (admin required).


### COMMON - Skip rvm steps on Windows, start "continue" below

>Install RVM:

    $ \curl -L https://get.rvm.io | bash -s stable --rails --autolibs=enabled

    $ rvm get head

    $ rvm install 2.1.2

    $ rvm reload

    $ rvm --default use 2.1.2

>exit terminal, launch again, run 'which ruby' to make sure it's rvm

>POSSIBLE RED HERRING /Applications/Vagrant/embedded/bin/gem install nokogiri -- --use-system-libraries=true --with-xml2-include=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.7.sdk/usr/include/libxml2

    $ sudo port install libxml2 libxslt


Continue:

    $ vagrant plugin install oscar

    $ vagrant plugin install vagrant-vbguest

    $ gem install librarian-puppet

    $ gem install puppet

    $ cd ~/sandbox

    $ git clone git@bitbucket.org:prolixalias/puppet-r10k.git

    $ cd puppet-r10k/puppet

    $ librarian-puppet install --clean --verbose

    $ vagrant plugin update

    $ ### DEPRECATED vagrant box add vagrant-raring64 https://bitbucket.org/prolixalias/puppet/downloads/vagrant-raring64.box

    $ ### DEPRECATED vagrant box add precise64 http://puppet-vagrant-boxes.puppetlabs.com/ubuntu-server-12042-x64-vbox4210.box

    $ vagrant up  # NOTE: be sure to launch Git bash as administrator on Windows for adding vbox network interface(s) and dealing with Windows firewall


# Troubleshooting
  * vagrant-hosts sometimes fails to insert the master's hostname into the /etc/hosts files on the agent VMs. One work-around is to run:
    $ vagrant provision --provision-with hosts

  * For diagnosing vagrant issues, the following command will be utterly useful:

    $ VAGRANT_LOG=DEBUG vagrant up 2>&1 | tee /tmp/puppet-r10k-vagrant.runlog


