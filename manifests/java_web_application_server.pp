# A wrapper that contains all thr functionality needed for a standard java web
# application --- does not support JEE applications

class profile::java_web_application_server inherits profile {

  # Java is needed to run the applications
  # A standard tomcat instace needs to be instantiated before building separate
  # instances
  include ::java
  include ::apache
  include ::tomcat

  # Ensure basedir is available
  $_instance_basedir = hiera('tomcat::catalina_home')

  file { $_instance_basedir:
    ensure => directory,
  }

  # Hard fix of staging dirs
  # TODO: Fix this
  file { '/opt/staging/tomcat':
    ensure  => directory,
    mode    => 'ug=rw,o=r',
    require => File['/opt/staging'],
  }

  file { '/opt/staging/tomcat/apache-tomcat-8.0.14.tar.gz':
    ensure  => file,
    mode    => 'ug=rw,o=r',
    require => File['/opt/staging/tomcat'],
  }


  # Since this uses wget to obtain the war files make the cache directory
  file { '/var/cache/wget':
    ensure => directory,
  }

  # Default tomcat home to catalina_home
  $instances_default = {
    instance_basedir => $_instance_basedir,
    source_url       => hiera('profile:java_web_application_server::source_url'),
  }

  # The instances to be configured on this node
  $instances = hiera('profile::java_web_application_server::instances')

  create_resources('::java_web_application_server::instance', $instances, $instances_default)
}
