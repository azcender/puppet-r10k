# A wrapper that contains all thr functionality needed for a standard java web
# application --- does not support JEE applications

class profile::java_web_application_server inherits profile {

  # Java is needed to run the applications
  # A standard tomcat instace needs to be instantiated before building separate
  # instances
  include ::java
  include ::tomcat
  include ::apache

  require ::staging::params

  # Since this uses wget to obtain the war files make the cache directory
  file { '/var/cache/wget':
    ensure => directory,
  }

  # Default tomcat home to catalina_home
  $instances_default = {
    instance_basedir => hiera('tomcat::catalina_home'),
    source_url       => hiera('profile:java_web_application_server::source_url'),
  }

  # The tomcat class relies on the staging class. The staging class uses a
  # cache directory. The permissions on the cache directory must be loose
  # enough to be read globally.
  #
  # We will create the staging directory here for more control.
  file { $::staging::params::path:
    owner   => $::staging::params::owner,
    group   => $::staging::params::group,
    mode    => $::staging::params::mode,
    recurse => true,
    before  => Class['::Staging'],
  }

  # The instances to be configured on this node
  $instances = hiera('profile::java_web_application_server::instances')

  create_resources('::java_web_application_server::instance', $instances, $instances_default)
}
