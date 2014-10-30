# A wrapper that contains all thr functionality needed for a standard java web
# application.
# Does not support JEE applications
class profile::balancer inherits profile {
  # The load balancer runs from the puppet apache module
  include ::apache

  file { '/etc/httpd/conf.d/proxy.load':
    ensure  => file,
    content => 'LoadModule proxy_module modules/mod_proxy.so',
  }

  # Apache submodules required for proxy
  apache::mod { 'proxy': }
  apache::mod { 'proxy_ajp': }
  apache::mod { 'proxy_html': }

  # Get the vhost balancers to create
  $vhosts = hiera('profile::balancer::balancers', {})

  create_resources('::balancer::vhost', $vhosts)
}
