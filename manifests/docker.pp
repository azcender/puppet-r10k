# Installs the Docker daemon
class profile::docker {
  # Include base class
  include ::profile

  include ::docker
  include ::haproxy

  ::haproxy::listen { 'puppet00':
    #ipaddress => $::ipaddress,
    ipaddress => '*',
    ports     => '8140',
  }

  ::haproxy::balancermember { '70b223b40eab':
    listening_service => 'puppet00',
    server_names      => '70b223b40eab',
    ipaddresses       => '172.17.0.2',
    ports             => '8080',
  }

  notice($::candy)

  create_resources('::haproxy::balancermember', $::candy)

  file { '/usr/lib/ruby/candy.rb':
    source => 'puppet:///modules/profile/candy.rb',
  }

  # Pull images
  $images = hiera('profile::docker::images')

  create_resources('::docker::image', $images)

  $runs = hiera('profile::docker::runs')

  create_resources('::docker::run', $runs)
}
