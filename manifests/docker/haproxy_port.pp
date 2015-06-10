# Helps map ports on haproxy to docker hosts
# The name of this resource is <<host port>>:<<guest port>>
define profile::docker::haproxy_port(
  $ports,
  $listening_service = 'docker',
  $running = true,
) {
  $ports_array = split($name, ':')

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
    ipaddresses       => $::ipaddress,
    ports             => $port,
  }
}
