#
define profile::docker::haproxy(
  $image,
  $docker_ipaddress,
  $listening_service = '',
  $command = undef,
  $memory_limit = '0b',
  $cpuset = [],
  $ports = [],
  $expose = [],
  $volumes = [],
  $links = [],
  $use_name = false,
  $running = true,
  $volumes_from = [],
  $net = 'bridge',
  $username = false,
  $hostname = false,
  $env = [],
  $dns = [],
  $dns_search = [],
  $lxc_conf = [],
  $restart_service = true,
  $disable_network = false,
  $privileged = false,
  $detach = undef,
  $extra_parameters = undef,
  $pull_on_start = false,
  $depends = [],
  $tty = false,
  $socket_connect = [],
  $hostentries = [],
  $restart = undef,
  $read_only = true,
) {
  # Only really worried about ports and running
  validate_array($ports)
  validate_bool($running)

  ::profile::docker::haproxy_port { $ports:
    docker_ipaddress  => $docker_ipaddress,
    listening_service => $listening_service,
    ports             => $ports,
    running           => $running,
  }
}
