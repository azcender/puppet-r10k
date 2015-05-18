# Helps map ports on haproxy to docker hosts
# The name of this resource is <<host port>>:<<guest port>>
define profile::helper_docker_haproxy_port(
  $ports,
  $listening_service = 'docker',
) {
  $ports_array = split($name, ':')

  $port = $ports_array[0]

  $concat_name = "${name}-${::ipaddress}"

  @@::haproxy::balancermember { $concat_name:
    listening_service => $listening_service,
    server_names      => $::hostname,
    ipaddresses       => $::ipaddress,
    ports             => $port,
  }
}
