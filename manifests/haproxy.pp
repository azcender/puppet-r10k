# Set up a haproxy proxy
#

class profile::haproxy(
  $ipaddress = $::ipaddress,
  $listeners = {},
) {
  include ::profile
  include ::haproxy

  # Set the default ipaddress to the one passed in
  $default_listener_params = {
    ipaddress => $ipaddress,
  }

  create_resources(::haproxy::listen, $listeners, $default_listener_params)
}
