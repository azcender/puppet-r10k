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
  }

  class { '::r10k': }
}
