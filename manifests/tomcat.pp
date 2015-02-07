# A wrapper that contains all thr functionality needed for a standard java web
# application --- does not support JEE applications

class profile::tomcat (
  $groupid,
  $artifactid,
  $version,
  $source_url,
  $snapshot_repo,
  $release_repo,
  $default_resource_auth,
  $default_resource_type,
  $default_resource_driverClassName,
  $default_resource_maxTotal,
  $default_resource_maxIdle,
  $default_resource_maxWaitMillis,
  $catalina_base = '/opt/tomcat',
) {
  include ::profile

  # Java is needed to run the applications
  # A standard tomcat instace needs to be instantiated before building separate
  # instances
  include ::java
  include ::tomcat

  # A the database driver
  file { '/opt/tomcat/lib/ojdbc7.jar':
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
    catalina_base => $catalina_base,
    source_url    => $source_url,
  }

  shellvar { 'test username':
    ensure   => present,
    target   => '/etc/environment',
    variable => 'MYORACLE_USERNAME',
    value    => 'system',
    notify   => ::Tomcat::Service[$name],
  }

  shellvar { 'test password':
    ensure   => present,
    target   => '/etc/environment',
    variable => 'MYORACLE_PASSWORD',
    value    => 'oracle',
    notify   => ::Tomcat::Service[$name],
  }

  ::tomcat::setenv::entry { $name:
    config_file => "${catalina_base}/bin/setenv.sh",
    param       => 'JAVA_OPTS',
    value       => '-Dmyoracle.username=$MYORACLE_USERNAME -Dmyoracle.password=$MYORACLE_PASSWORD',
    quote_char  => '"',
    notify      => ::Tomcat::Service[$name],
    require     => ::Tomcat::Instance[$name],
  }

  ::java_web_application_server::maven { $name:
    ensure        => present,
    war_name      => "${artifactid}.war",
    groupid       => $groupid,
    artifactid    => $artifactid,
    version       => $version,
    maven_repo    => $snapshot_repo,
    catalina_base => $catalina_base,
    packaging     => 'war',
    require       => ::Tomcat::Instance[$name],
  }

  ::tomcat::service { $name:
    service_name  => $name,
    catalina_home => $catalina_base,
    catalina_base => $catalina_base,
    require       => ::Java_web_application_server::Maven[$name],
  }

  ::tomcat::config::context { $name:
    catalina_base => $catalina_base,
    require       => ::Tomcat::Instance[$name],
  }

  # Setup context resources
  $tomcat_resources_defaults = {
    catalina_base   => $catalina_base,
    auth            => $default_resource_auth,
    type            => $default_resource_type,
    driverClassName => $default_resource_driverClassName,
    maxTotal        => $default_resource_maxTotal,
    maxIdle         => $default_resource_maxIdle,
    maxWaitMillis   => $default_resource_maxWaitMillis,
    require         => ::Tomcat::Config::Context[$name],
    notify          => ::Tomcat::Service[$name],
  }

  # Obtain tomcat resources to create
  $tomcat_resources = hiera_hash('tomcat_resources', {})

  create_resources('::tomcat::config::context::resource', $tomcat_resources,
  $tomcat_resources_defaults)
}
