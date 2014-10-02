# Disables node level firewall

include registry

class profile::windows_firewall inherits profile {
  class{ '::windows_firewall':
    ensure => 'stopped',
  }
}
