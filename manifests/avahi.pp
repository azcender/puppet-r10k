# Installs Avahi service
#

class profile::avahi {
  include ::profile
  include ::avahi

  # Need to disallow other services
  file_line {'disallow_other_stacks_in_avahi':
    path   => '/etc/avahi/avahi-daemon.conf',
    line   => 'disallow-other-stacks=yes',
    match  => '#?disallow-other-stacks=(yes|no)',
    before => Service['avahi-daemon'],
  }
}
