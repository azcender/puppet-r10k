# Helps map ports on haproxy to docker hosts
# The name of this resource is <<host port>>:<<guest port>>
define profile::docker::haproxy_port(
  $docker_ipaddress,
  $ports,
  $listening_service = 'docker',
  $running = true,
) {
  # The ports array is made ip of
  # <<host ipaddress>>:<<host port>>:<<container port>>
  $ports_array = split($name, ':')

  # The ip docker should be listening on
  $docker_ip = $ports_array[0]

  # The host port to map to
  $port = $ports_array[1]

  $concat_name = "${port}-${::clientcert}"

  # Ensure the container is running. Else we should delete
  # the rule.
  $ensure = $running ? {
    true  => present,
    false => absent,
  }

  @@::haproxy::balancermember { $concat_name:
    ensure            => $ensure,
    listening_service => $listening_service,
    server_names      => $::hostname,
    ipaddresses       => $docker_ipaddress,
    ports             => $port,
  }
}
