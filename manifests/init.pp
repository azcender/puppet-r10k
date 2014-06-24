# Contains any technologies that must be wrapped on ALL nodes
class profile {
  # Set global file settings
  file {'/etc/puppetlabs/puppet/modules':
    mode    => 'a+5',
    recurse => 'true'
  }
}
