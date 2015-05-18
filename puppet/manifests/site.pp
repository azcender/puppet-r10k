## site.pp ##

# This file (/etc/puppetlabs/puppet/manifests/site.pp) is the main entry point
# used when an agent connects to a master and asks for an updated configuration.
#
# Global objects like filebuckets and resource defaults should go in this file,
# as should the default node definition. (The default node can be omitted
# if you use the console and don't define any other nodes in site.pp. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.)

## Active Configurations ##

# PRIMARY FILEBUCKET
# This configures puppet agent and puppet inspect to back up file contents when
# they run. The Puppet Enterprise console needs this to display file contents
# and differences.

# Define filebucket 'main':
filebucket { 'main':
  server => 'master',
  path   => false,
}

# Make filebucket 'main' the default backup location for all File resources:
File { backup => 'main' }

node /^master*$/ {
  class { '::ntp':
    servers    =>
    [ '0.us.pool.ntp.org iburst',
    '1.us.pool.ntp.org iburst',
    '2.us.pool.ntp.org iburst',
    '3.us.pool.ntp.org iburst'],
    autoupdate => true,
    restrict   => [],
  }

  $ip = $::virtual ? {
    'virtualbox' => $::ipaddress_eth1,
    default      => $::ipaddress_eth0,
  }

  @@host { $::hostname:
    ensure       => present,
    ip           => $ip,
    host_aliases => $hostname,
  }

  host { 'localhost':
    ensure       => present,
    ip           => '127.0.0.1',
    host_aliases => 'localhost.localdomain',
  }

  Host <<||>>

  if $::osfamily == 'redhat' {
    class { 'firewall': ensure => stopped, }
  }

  # Time to start using the future parser
  #ini_setting { 'parser':
  #  ensure => present,
  #  path   => '/etc/puppetlabs/puppet/puppet.conf',
  #  section => 'main',
  #  setting => 'parser',
  #  value   => 'future',
  #}

  #  ini_setting { 'environmentpath':
  #  ensure  => present,
  #  path    => '/etc/puppetlabs/puppet/puppet.conf',
  #  section => 'main',
  #  setting => 'environmentpath',
  #  value   => '$confdir/environments',
  #} ->
  #
  #ini_setting { 'default_manifest':
  #  ensure  => present,
  #  path    => '/etc/puppetlabs/puppet/puppet.conf',
  #  section => 'main',
  #  setting => 'default_manifest',
  #  value   => '$confdir/manifests',
  #} ->
  #
  #ini_setting { 'basemodulepath':
  #  ensure  => present,
  #  path    => '/etc/puppetlabs/puppet/puppet.conf',
  #  section => 'main',
  #  setting => 'basemodulepath',
  #  value   => '$confdir/modules:/opt/puppet/share/puppet/modules',
  #} ->

  file { 'ruby spec directory':
    path    => '/opt/puppet/lib/ruby/gems/1.9.1/specifications',
    mode    => 'a+r',
    recurse => true,
  }

  file { '/etc/puppetlabs/puppet/hiera.yaml':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => '/vagrant/puppet/hiera.yaml',
    notify => Service['pe-httpd'],
  }

  file { '/etc/puppetlabs/r10k/r10k.yaml':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => '/vagrant/puppet/r10k.yaml',
    notify => Service['pe-httpd'],
  }


  service { 'pe-httpd': ensure => running, }
}

# DEFAULT NODE
# Node definitions in this file are merged with node data from the console. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.

# The default node definition matches any node lacking a more specific node
# definition. If there are no other nodes in this file, classes declared here
# will be included in every node's catalog, *in addition* to any classes
# specified in the console for that node.

node default {
  class { '::ntp':
    servers    => [ '0.us.pool.ntp.org iburst','1.us.pool.ntp.org iburst',
    '2.us.pool.ntp.org iburst', '3.us.pool.ntp.org iburst'],
    autoupdate => true,
    restrict   => [],
  }

  $ip = $::virtual ? {
    'virtualbox' => $::ipaddress_eth1,
    default      => $::ipaddress_eth0,
  }


  #@@host { $::hostname:
  #  ensure       => present,
  #  ip           => $ip,
  #  host_aliases => $hostname,
  #}

  host { 'localhost':
    ensure       => present,
    ip           => '127.0.0.1',
    host_aliases => 'localhost.localdomain',
  }

  notify {
    "Node ${::hostname} received default classification on local dev.\
    Something is WRONG!":
  }

  file { '/tmp/runpuppet.sh':
    ensure  => 'file',
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    content => "#!/bin/bash\npuppet agent -t",
    } ->
    
  exec { 'at now + 1 min -f /tmp/runpuppet.sh':
    path     => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', '/opt/puppet/bin'],
  }
  case $::operatingsystem {
    windows: {
      $puppet_conf_path = 'C:/ProgramData/PuppetLabs/puppet/etc/puppet.conf'
    }
    Ubuntu, RedHat, CentOS: {
      # Set "environment"
      $puppet_conf_path = '/etc/puppetlabs/puppet/puppet.conf'
    }
    default: {
      fail("Unsupported operating system detected: ${::operatingsystem}")
    }
  }
}
