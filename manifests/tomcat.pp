# A wrapper that contains all thr functionality needed for a standard java web
# application --- does not support JEE applications

class profile::tomcat (
  $groupid,
  $artifactid,
  $version,
  $default_resource_auth,
  $default_resource_type,
  $default_resource_driverClassName,
  $default_resource_maxTotal,
  $default_resource_maxIdle,
  $default_resource_maxWaitMillis,
  $tomcat_resources = {}
) {
  include ::profile

  # Java is needed to run the applications
  # A standard tomcat instace needs to be instantiated before building separate
  # instances
  include ::java
  include ::tomcat

  # Setup context resources
  $tomcat_resources_defaults = {
    catalina_base   => '/opt/tomcat',
    auth            => $default_resource_auth,
    type            => $default_resource_type,
    driverClassName => $default_resource_driverClassName,
    maxTotal        => $default_resource_maxTotal,
    maxIdle         => $default_resource_maxIdle,
    maxWaitMillis   => $default_resource_maxWaitMillis,
    require         => ::Tomcat::Config::Context[$name],
    notify          => ::Tomcat::Service[$name],
  }

  # A the database driver
  file { '/opt/tomcat/lib':
    ensure  => file,
    source  => 'puppet:///modules/profile/ojdbc7.jar',
    require => ::Tomcat::Instance[$name],
    notify  => ::Tomcat::Service[$name],
  }

  # Hard fix of staging dirs
  # TODO: Fix this
  file { '/opt/staging/tomcat':
    ensure  => directory,
    mode    => 'a=rx',
    require => File['/opt/staging'],
  }

  $source_url = hiera('source_url')

  $apache_file = regsubst($source_url, '.*/(.*)', '\1')

  file { "/opt/staging/tomcat/${apache_file}" :
    ensure  => file,
    mode    => 'ug=rw,o=r',
    require => ::Staging::File[$apache_file],
  }


  # Since this uses wget to obtain the war files make the cache directory
  file { '/var/cache/wget':
    ensure => directory,
  }

  ::tomcat::instance { $name:
    catalina_base => '/opt/tomcat',
    source_url    => $source_url,
  }

  ::java_web_application_server::maven { $name:
    ensure        => present,
    war_name      => "${::artifactid}.war",
    groupid       => $groupid,
    artifactid    => $artifactid,
    version       => $version,
    maven_repo    => 'http://artifactory.azcender.com/artifactory/ext-release-local',
    catalina_base => '/opt/tomcat',
    packaging     => 'war',
    require       => ::Tomcat::Instance[$name],
  }

  ::tomcat::service { $name:
    service_name  => $name,
    catalina_home => '/opt/tomcat',
    catalina_base => '/opt/tomcat',
    require       => ::Java_web_application_server::Maven[$name],
  }

  ::tomcat::config::context { $name:
    catalina_base => '/opt/tomcat',
    require       => ::Tomcat::Instance[$name],
  }

  create_resources('::tomcat::config::context::resource', $tomcat_resources,
  $tomcat_resources_defaults)
}
