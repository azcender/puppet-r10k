# A wrapper that contains all thr functionality needed for a standard java web
# application.
# Does not support JEE applications
class profile::java_web_application_server inherits profile {

  # Java is needed to run the applications
  # A standard tomcat instace needs to be instantiated before building separate
  # instances
  include ::java
  include ::tomcat
  include ::apache

  # Apache submodules required for proxy
  apache::mod { 'proxy_ajp': }
  apache::mod { 'proxy_html': }

  # Default tomcat home to catalina_home
  $instances_default = {
    instance_basedir => hiera('tomcat::catalina_home'),
    source_url       => hiera('profile:java_web_application_server::source_url'),
  }

  # Setup HTTPD balancer
  $apache_vhosts = hiera('profile::java_web_application_server::vhosts')
  create_resources('::apache::vhost', $apache_vhosts)

  # TODO - Move to a new profile. Do not reused $apache_vhosts - SLOPPY
  $apache_balancers = hiera('profile::java_web_application_server::balancers')
  create_resources('::apache::balancer', $apache_balancers, $apache_balancer_default)

  # The instances to be configured on this node
  $instances = hiera('profile::java_web_application_server::instances')

  create_resources('::java_web_application_server::instance', $instances, $instances_default)
}
