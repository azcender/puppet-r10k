# Set up a haproxy proxy
#

class profile::haproxy {
  # Include base class
  include ::profile
  include ::haproxy

  ::haproxy::listen { 'docker':
    ipaddress => $::ipaddress_ens33,
    mode      => 'http',
    ports     => '8140',
  }

  ::haproxy::frontend { 'http-in':
    bind    => {
      '*:80' => []
    },

    options => {
      'acl'             => 'has_special_uri path_beg /special',
      'use_backend'     => 'special_server if has_special_uri',
      'default_backend' => 'webfarm',
    }
  }

  #  ::haproxy::balancermember { '70b223b40eab':
  #  listening_service => 'puppet00',
  #  server_names      => '70b223b40eab',
  #  ipaddresses       => '172.17.0.2',
  #  ports             => '8080',
  #}

  #$balancermember_defaults = {
  #  listening_service => 'puppet00',
  #  require           =>
  #[Class['::docker'], File['/etc/puppetlabs/facter/facts.d/containers.rb']],
  #}

  # Create balance members if containers exist
  #create_resources('::haproxy::balancermember', $::containers,
  #$balancermember_defaults)

  # Pull images
  #  $images_defaults = {
  #  before => Class['::haproxy::balancermember'],
  #}

  ::Docker::Run <<||>> -> ::Haproxy::Balancermember <<| listening_service == 'docker' |>>

  #$images = hiera('profile::docker::images', {})

  #create_resources('::docker::image', $images)

  #  $runs_defaults = {
  #  before => Class['::haproxy::balancermember'],
  #}
  }
