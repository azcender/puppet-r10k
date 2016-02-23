# -*- mode: ruby -*-
# vi: set ft=ruby :
domain = 'localdomain'

nodes = [
  { :hostname => 'master',  :box => 'puppetlabs/centos-7.2-64-nocm', :ram => '4096', :cpus => '2', :ip => '192.168.0.105' },
  { :hostname => 'consul0',  :box => 'puppetlabs/centos-7.2-64-nocm', :ram => '256', :cpus => '1' },
  { :hostname => 'consul1',  :box => 'puppetlabs/centos-7.2-64-nocm', :ram => '256', :cpus => '1'  },
  { :hostname => 'docker0',  :box => 'puppetlabs/centos-7.2-64-nocm', :ram => '2048', :cpus => '2'  },
  { :hostname => 'docker1',  :box => 'puppetlabs/centos-7.2-64-nocm', :ram => '2048', :cpus => '2'  },
  { :hostname => 'nginx0', :box => 'puppetlabs/centos-7.2-64-nocm', :ram => '256', :cpus => '1'  },
  { :hostname => 'nginx1', :box => 'puppetlabs/centos-7.2-64-nocm', :ram => '256', :cpus => '1'  },
  { :hostname => 'forms0', :box => 'puppetlabs/centos-7.2-64-nocm', :ram => '2048', :cpus => '2'  },
]

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  #config.vm.box = "base"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"
  config.vm.synced_folder ".", "/vagrant"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  nodes.each do |node|
    config.vm.define node[:hostname] do |nodeconfig|
      nodeconfig.vm.box = node[:box] ? node[:box] : 'precise32'
      nodeconfig.vm.hostname = node[:hostname] + '.' + domain
      #nodeconfig.vm.network :private_network, ip: node[:ip]

      if node[:ip] 
        nodeconfig.vm.network :private_network, ip: node[:ip]
      end

      cpus = node[:cpus] ? node[:cpus] : 1;
      memory = node[:ram] ? node[:ram] : 256;

      nodeconfig.vm.provider :vmware_fusion do |v|
	v.gui = false
        v.vmx["memsize"] = memory.to_s
        v.vmx["numvcpus"] = cpus.to_s
      end
    end
  end

 
  config.vm.provision :hosts do |provisioner|
    # Add a single hostname
    #provisioner.add_host '192.168.0.105', ['master']
  end


  config.vm.provision  "shell" do |s|
    s.inline = "sudo yum -y update"
  end
  
  config.vm.provision  "shell" do |s|
    s.inline = "curl -k https://master:8140/packages/current/install.bash | sudo bash"
  end
  
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   sudo apt-get update
  #   sudo apt-get install -y apache2
  # SHELL
end
