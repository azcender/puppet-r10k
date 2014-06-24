# Profile for the Puppet master node(s)
class profile::master {
  # Set global file settings
  file {'/etc/puppetlabs/puppet/modules':
    mode    => 'a+5',
    recurse => 'true'
  }

  file {'/etc/puppetlabs/puppet/environments':
    mode    => 'a+5',
    recurse => 'true'
  }
}
