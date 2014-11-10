# Disables node level firewall
class profile::firewall {
  include ::profile

  class{ '::firewall':
    ensure => 'stopped'
  }
}
