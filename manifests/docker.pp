# Installs the Docker daemon
#

class profile::docker {
  # Include base class
  include ::profile
  include ::docker

  # Docker runs in docker yaml
  $runs = hiera('profile::docker::runs')
  create_resources('::docker::run', $runs)

  $concat_name = "${name}-${::ipaddress_ens33}"

  @@::haproxy::balancermember { $concat_name:
    listening_service => $concat_name,
    server_names      => $::hostname,
    ipaddresses       => $::ipaddress_ens33,
    ports             => '8888',
  }
}
