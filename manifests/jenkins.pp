class profiles::jenkins inherits profiles {

  # Hiera lookups
  $plugins = hiera('profiles::jenkins::plugins')
  $config  = hiera('profiles::jenkins::config')

  class {'jenkins':
    plugin_hash => $plugins,
    config      => $config
  }
}
