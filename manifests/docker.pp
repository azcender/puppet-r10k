# Installs the Docker daemon
#

class profile::docker {
  # Include base class
  include ::profile
  include ::docker

  # Docker runs in docker yaml
  $runs = hiera('profile::docker::runs')
  create_resources('::docker::run', $runs)

  $runs.each |$run| {
    $concat_name = "${name}-${::ipaddress}"

    notice($run)

    @@::haproxy::balancermember { $concat_name:
      listening_service => 'docker',
      server_names      => $::hostname,
      ipaddresses       => $::ipaddress,
      ports             => '8888',
    }
  }
}
