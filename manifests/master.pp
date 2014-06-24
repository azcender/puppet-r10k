# Profile for the Puppet master node(s)
class master {
  # Set global file settings
  file {'/etc/puppetlabs/puppet/modules':
    mode    => 'a+5',
    recurse => 'true'
  }
}
