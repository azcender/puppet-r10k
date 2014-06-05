# Setup a reverse proxy using apache
class profiles::reverse_proxy inherits profiles {

  # Hiera lookups
  $proxies = hiera('profiles::reverse_proxy::proxies')

  class {'apache':}

  create_resources('apache::vhost', $proxies)
}
