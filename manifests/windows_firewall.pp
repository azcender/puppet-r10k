# Disables node level firewall
class profile::firewall inherits profile {
  class{ '::windows_firewall':
    ensure => 'stopped',
  }
}
