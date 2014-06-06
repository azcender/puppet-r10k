# Loads jenkins with plugins defined in hiera
class profile::jenkins inherits profile {

  # Hiera lookups
  $plugins = hiera('profile::jenkins::plugins')
  $config  = hiera('profile::jenkins::config')

  class {'jenkins':
    plugin_hash => $plugins,
    config      => $config
  }
}
