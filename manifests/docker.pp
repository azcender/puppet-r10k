# Installs the Docker daemon
class profile::docker {
  # Include base class
  include ::profile

  include ::docker
  include ::haproxy

  haproxy::listen { 'puppet00':
    ipaddress => $::ipaddress,
    ports     => '8140',
  }

  # Pull images
  $images = hiera('profile::docker::images')

  create_resources('::docker::image', $images)

  $runs = hiera('profile::docker::runs')

  create_resources('::docker::run', $runs)
}
