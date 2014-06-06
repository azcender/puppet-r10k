# Setup a reverse proxy using apache
class profile::reverse_proxy inherits profile {

  # Hiera lookups
  $proxies = hiera('profile::reverse_proxy::proxies')

  class {'apache':}

  create_resources('apache::vhost', $proxies)
}
