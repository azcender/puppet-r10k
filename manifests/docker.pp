# Installs the Docker daemon
class profile::docker {
  # Include base class
  include ::profile

  include ::docker

  # Docker runs in docker yaml
  $runs = hiera('profile::docker::runs')

  create_resources('::docker::run', $runs)

  @@::haproxy::balancermember { $::ipaddress_ens33 :
    listening_service => 'docker',
    server_names      => $::hostname,
    ipaddresses       => $::ipaddress_ens33,
    ports             => '8888',
  }
}
