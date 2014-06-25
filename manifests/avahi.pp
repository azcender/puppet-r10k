# Installs Avahi web daemon service
class profile::avahi {
  class{ '::avahi':
    firewall => 'true'
  }

  # Need to disallow other services
  file_line {'disallow_other_stacks_in_avahi':
    path  => '/etc/avahi/avahi-daemon.conf',
    line  => 'disallow-other-stacks=yes',
    match => '#disallow-other-stacks=no',
  }
}
