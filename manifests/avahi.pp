# Installs Avahi web daemon service
class profile::avahi inherits profile {
  class{ '::avahi': }

  # Need to disallow other services
  file_line {'disallow_other_stacks_in_avahi':
    path    => '/etc/avahi/avahi-daemon.conf',
    line    => 'disallow-other-stacks=yes',
    match   => '#?disallow-other-stacks=(yes|no)',
    require => Package['avahi'],
    before  => Service['avahi-daemon'],
  } ~>
  Service['avahi-daemon']
}
