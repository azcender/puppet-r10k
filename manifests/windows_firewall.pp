# Disables node level firewall

include registry

class profile::windows_firewall {
  include ::profile

  class{ '::windows_firewall':
    ensure => 'stopped',
  }
}
