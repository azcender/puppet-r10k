# Installs Avahi web daemon service
class profile::avahi {
  class{ '::avahi':
    firewall => 'true'
  }
}
