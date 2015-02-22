# Installs the Docker daemon
class profile::docker {
  # Include base class
  include ::profile

  include ::docker
  include ::haproxy

  file { '/etc/puppetlabs/facter':
    ensure => directory,
  }

  file { '/etc/puppetlabs/facter/facts.d':
    ensure  => directory,
    require => File['/etc/puppetlabs/facter'],
  }

  file {'/etc/puppetlabs/facter/facts.d/containers.rb':
    ensure  => file,
    source  => 'puppet:///modules/profile/containers.rb',
    require => File['/etc/puppetlabs/facter/facts.d'],
  }

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
    require           => [Class['::docker'], File['/etc/puppetlabs/facter/facts.d/containers.rb']],
  }

  # Create balance members if containers exist
  create_resources('::haproxy::balancermember', $::containers,
  $balancermember_defaults)

  # Pull images
  #  $images_defaults = {
  #  before => Class['::haproxy::balancermember'],
  #}

  ::Docker::Image <<||>> -> ::Haproxy::Balancermember <<||>>
  ::Docker::Run <<||>> -> ::Haproxy::Balancermember <<||>>

  $images = hiera('profile::docker::images', {})

  create_resources('::docker::image', $images)

  #  $runs_defaults = {
  #  before => Class['::haproxy::balancermember'],
  #}

  $runs = hiera('profile::docker::runs', {})

  create_resources('::docker::run', $runs)
}
