# Installs the Docker daemon
class profile::docker {
  # Include base class
  include ::profile

  include ::docker
  include ::haproxy

  ::haproxy::listen { 'puppet00':
    #ipaddres => $::ipaddress,
    mode      => 'http',
    ipaddress => '*',
    ports     => '8140',
  }

  #  ::haproxy::balancermember { '70b223b40eab':
  #  listening_service => 'puppet00',
  #  server_names      => '70b223b40eab',
  #  ipaddresses       => '172.17.0.2',
  #  ports             => '8080',
  #}

  $balancermember_defaults = {
    listening_service => 'puppet00',
    require           => Class['::docker'],
  }

  # Create balance members if containers exist
  if is_hash($::candy) {
    create_resources('::haproxy::balancermember', $::candy,
    $balancermember_defaults)
  }

  # Pull images
  #  $images_defaults = {
  #  before => Class['::haproxy::balancermember'],
  #}

  ::Docker::Image <<||>> -> ::Haproxy::Balancermember <<||>>
  ::Docker::Run <<||>> -> ::Haproxy::Balancermember <<||>>

  $images = hiera('profile::docker::images')

  create_resources('::docker::image', $images)

  #  $runs_defaults = {
  #  before => Class['::haproxy::balancermember'],
  #}

  $runs = hiera('profile::docker::runs')

  create_resources('::docker::run', $runs)
}
