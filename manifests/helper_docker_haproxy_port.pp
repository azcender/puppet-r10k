# Helps map ports on haproxy to docker hosts
define profile::helper_docker_haproxy_port(
  $port,
  $listening_service = 'docker',
) {

  $concat_name = "${port}-${::ipaddress}"

  @@::haproxy::balancermember { $concat_name:
    listening_service => $listening_service,
    server_names      => $::hostname,
    ipaddresses       => $::ipaddress,
    ports             => $port,
  }
}
