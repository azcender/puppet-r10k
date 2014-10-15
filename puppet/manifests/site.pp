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

node 'base' {
  include ntp

  @@host { $::hostname:
    ensure         => present,
    ip             => $::virtual ? {
      'virtualbox' => $::ipaddress_eth1,
      default      => $::ipaddress_eth0,
    },
    host_aliases   => $hostname,
  }

  host { 'localhost':
    ensure       => present,
    ip           => '127.0.0.1',
    host_aliases => 'localhost.localdomain',
  }

  Host <<||>>
}

node /^master*$/ inherits base {

  if $::osfamily == 'redhat' {
    class { 'firewall': ensure => stopped, }
  }

  ini_setting { 'master manifest path':
    ensure   => absent,
    path     => '/etc/puppetlabs/puppet/puppet.conf',
    section  => 'main',
    setting  => 'manifest',
  } ->

  ini_setting { 'environmentpath':
    ensure  => present,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'main',
    setting => 'environmentpath',
    value   => '$confdir/environments',
  } ->

  ini_setting { 'default_manifest':
    ensure  => present,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'main',
    setting => 'default_manifest',
    value   => '$confdir/manifests',
  } ->

  ini_setting { 'basemodulepath':
    ensure  => present,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'main',
    setting => 'basemodulepath',
    value   => '$confdir/modules:/opt/puppet/share/puppet/modules',
  } ->

  ini_setting { 'modulepath':
    ensure => absent,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'main',
    setting => 'modulepath',
  } ->

  file { '/etc/puppetlabs/puppet/prerun.sh':
    ensure  => file,
    mode    => 'ug+x,o-x',
    owner   => 'root',
    group   => 'root',
    content => '#!/bin/bash
#
# Pre-run command for r10k deployment and clean up
#
#

function prerun {
  r10k deploy environment -pv
}
function cleanup {
  chown -R pe-puppet:pe-puppet /etc/puppetlabs/puppet/environments /etc/puppetlabs/puppet/hiera
  chmod -R 750 /etc/puppetlabs/puppet/environments /etc/puppetlabs/puppet/hiera
}

trap cleanup EXIT
prerun
',
  } ->

  file { 'ruby spec directory':
    path    => '/opt/puppet/lib/ruby/gems/1.9.1/specifications',
    mode    => 'a+r',
    recurse  => true,
  } ->

  class { 'r10k':
    include_prerun_command => false,
    sources                => {
      'puppet' => {
        'remote'  => 'https://bitbucket.org/prolixalias/puppet-r10k-environments.git',
        'basedir' => "${::settings::confdir}/environments",
        'prefix'  => false,
      },

      hiera                => {
        'remote'  => 'https://bitbucket.org/prolixalias/puppet-r10k-hiera.git',
        'basedir' => "${::settings::confdir}/hiera",
        'prefix'  => true,
      }
    },
    purgedirs              => ["${::settings::confdir}/environments"],
  } ->

  class { 'r10k::prerun_command':
    command => '/etc/puppetlabs/puppet/prerun.sh',
  }

  file { '/etc/puppetlabs/puppet/hiera.yaml':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    content => '---
:backends:
  - yaml

:hierarchy:
  - "fqdn/%{::fqdn}"
  - "role/%{::role}"
  - "role/%{::role}/%{::role_group}"
  - "tier/%{::tier}"
  - common

:yaml:
  :datadir: "/etc/puppetlabs/puppet/hiera/hiera_%{::environment}"
',
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

node default inherits base {
  notify { "Node ${::hostname} received default classification on local dev. Something is WRONG!": }
  file { '/tmp/runpuppet.sh':
    ensure   => 'file',
    mode     => '0755',
    owner    => 'root',
    group    => 'root',
    content  => "#!/bin/bash\npuppet agent -t",
  } -> exec { 'at now + 1 min -f /tmp/runpuppet.sh':
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
