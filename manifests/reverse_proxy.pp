class profiles::reverse_proxy {

  # Hiera lookups
  $proxies = hiera('profiles::reverse_proxy::proxies')

  class {'apache':}

  create_resources('apache::vhost', $proxies)
}
