# A wrapper that contains all thr functionality needed for a standard java web
# application.
# Does not support JEE applications
class profile::balancer {
  include ::profile

  # The load balancer runs from the puppet apache module
  include ::apache

  # Apache submodules required for proxy

  apache::mod { 'proxy': }

  apache::mod { 'proxy_ajp':
    require => Apache::Mod['proxy'],
  }

  apache::mod { 'proxy_html':
    require => Apache::Mod['proxy'],
  }

  # Get the vhost balancers to create
  $vhosts = hiera('profile::balancer::balancers', {})

  create_resources('::balancer::vhost', $vhosts)
}
