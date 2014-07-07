# Disables node level firewall
class profile::firewall inherits profile {
  class{ '::firewall':
    ensure => 'stopped'
  }
}
