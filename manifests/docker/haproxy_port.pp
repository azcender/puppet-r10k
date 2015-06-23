#
# Helps map ports on haproxy to docker hosts
# The name of this resource is <<host port>>:<<guest port>>
define profile::docker::haproxy_port(
  $docker_ipaddress,
  $ports,
  $listening_service,
  $running = true,
) {
  # The ports array is made ip of
  # <<host ipaddress>>:<<host port>>:<<container port>>
  $ports_array = split($name, ':')

  # The host port to map to
  $port = $ports_array[0]

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
