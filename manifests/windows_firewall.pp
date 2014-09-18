# Disables node level firewall

include registry

class profile::firewall inherits profile {
  class{ '::windows_firewall':
    ensure => 'stopped',
  }
}
