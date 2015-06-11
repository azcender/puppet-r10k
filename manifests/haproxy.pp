# Set up a haproxy proxy
#

class profile::haproxy(
  $ipaddress = $::ipaddress,
) {
  # Include base class
  include ::profile
  include ::haproxy

  haproxy::listen { 'docker':
    ipaddress => $ipaddress,
    ports     =>  9999,
  }
}
