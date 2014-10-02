# Profile for the Puppet master node(s)
class profile::master {
  # Set global file settings
  file {'/etc/puppetlabs/puppet/modules':
    mode    => 'a+r',
    recurse => 'true'
  }

  file {'/etc/puppetlabs/puppet/environments':
    mode    => 'u+r',
    owner   => 'pe-puppet',
    group   => 'pe-puppet',
    recurse => 'true'
  }

  file {'/etc/puppetlabs/puppet/hiera':
    mode    => 'u+r',
    owner   => 'pe-puppet',
    group   => 'pe-puppet',
    recurse => 'true'
  }->
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
  - "role/%{::role}/%{::node_group}"
  - "tier/%{::tier}"
  - common

:yaml:
  :datadir: "/etc/puppetlabs/puppet/hiera/hiera_%{::environment}"
',
    notify => Service['pe-httpd'],
  }

  class { '::r10k': }
  ->

  ini_setting { 'modulepath':
    ensure => absent,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'main',
    setting => 'modulepath',
  }

}
