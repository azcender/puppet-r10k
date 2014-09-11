###puppet-r10k

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
  * rvm == 1.25.17
  * VirtualBox == 4.3.16
  * Vagrant >= 1.6.3
  * vagrant-oscar ( '$ vagrant plugin install oscar' )
  * vagrant-vbguest ( '$ vagrant plugin install vagrant-vbguest' )
  * librarian-puppet ( '$ sudo gem install librarian-puppet' )

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

# Supplemental downloads

http://s3.amazonaws.com/pe-builds/released/3.3.2/puppet-enterprise-3.3.2-ubuntu-14.04-amd64.tar.gz

http://s3.amazonaws.com/pe-builds/released/3.3.2/puppet-enterprise-3.3.2-el-6-x86_64.tar.gz

http://s3.amazonaws.com/pe-builds/released/3.3.2/puppet-enterprise-3.3.2.msi


# Troubleshooting
  * vagrant-hosts sometimes fails to insert the master's hostname into the /etc/hosts files on the agent VMs. One work-around is to run 'vagrant provision --provision-with hosts'
  * For diagnosing vagrant issues, the following command will be utterly useful:

    $ VAGRANT_LOG=DEBUG vagrant up 2>&1 | tee /tmp/puppet-r10k-vagrant.runlog
