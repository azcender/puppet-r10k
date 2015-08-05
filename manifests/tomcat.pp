# A wrapper that contains all thr functionality needed for a standard java web
# application --- does not support JEE applications

class profile::tomcat (
  $source_url,
  $snapshot_repo,
  $release_repo,
  $production_repo,
  $default_resource_auth,
  $default_resource_type,
  $default_resource_driver_class_name,
  $default_resource_max_total,
  $default_resource_max_idle,
  $default_resource_max_wait_millis,
  $catalina_base    = '/opt/tomcat',
  $application_name = undef,
  $groupid = undef,
  $artifactid = undef,
  $version = undef,
  $packaging = war,
) {
  include ::profile

  # Java is needed to run the applications
  # A standard tomcat instace needs to be instantiated before building separate
  # instances
  include ::java
  include ::tomcat

  # Find the artifactory host
  $artifactory_host = hiera('artifactory_host')

  # Use the correct repo based on version
  if empty(grep([$version], '.+SNAPSHOT$')) {
    $_repo = $release_repo
  }
  else {
    $_repo = $snapshot_repo
  }

  # If war name is empty use artifact id
  if $application_name {
    $_war_name = "${application_name}.war"
  }
  else {
    $_war_name = "${artifactid}.war"
  }

  # A the database driver
  file { '/opt/tomcat/lib/ojdbc6dms.jar':
    ensure  => file,
    source  => 'puppet:///modules/profile/ojdbc6dms.jar',
    owner   => 'tomcat',
    group   => 'tomcat',
    mode    => '0600',
    require => ::Tomcat::Instance[$name],
    notify  => ::Tomcat::Service[$name],
  }

  file { '/opt/tomcat/lib/dms.jar':
    ensure  => file,
    source  => 'puppet:///modules/profile/dms.jar',
    owner   => 'tomcat',
    group   => 'tomcat',
    mode    => '0600',
    require => ::Tomcat::Instance[$name],
    notify  => ::Tomcat::Service[$name],
  }

  file { '/opt/tomcat/lib/ojdl.jar':
    ensure  => file,
    source  => 'puppet:///modules/profile/ojdl.jar',
    owner   => 'tomcat',
    group   => 'tomcat',
    mode    => '0600',
    require => ::Tomcat::Instance[$name],
    notify  => ::Tomcat::Service[$name],
  }

  file { '/opt/tomcat/lib/ojdl2.jar':
    ensure  => file,
    source  => 'puppet:///modules/profile/ojdl2.jar',
    owner   => 'tomcat',
    group   => 'tomcat',
    mode    => '0600',
    require => ::Tomcat::Instance[$name],
    notify  => ::Tomcat::Service[$name],
  }

  file { '/opt/tomcat/lib/odl-12.1.2-0-0.jar':
    ensure  => file,
    source  => 'puppet:///modules/profile/odl-12.1.2-0-0.jar',
    owner   => 'tomcat',
    group   => 'tomcat',
    mode    => '0600',
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

  # All of groupid, artifactid and version must be supplied to autodeploy an
  # application
  if($groupid and $artifactid and $version) {
    $_group_id = regsubst($groupid, '\.', '/', 'G')

    $artifactory_path = "${_repo}/${_group_id}/${artifactid}/${version}/${artifactid}-${version}.${packaging}"

    $destination = "${catalina_base}/webapps/${_war_name}"

    ::tomcat::artifactory { $destination:
      artifactory_host => $artifactory_host,
      artifactory_path => $artifactory_path,
      require          => [::Tomcat::Instance[$name], ::Tomcat::Service[$name]],
    }
  }
  else {
    warning("One or more of groupid, artifactid and version was not supplied to\
    the Tomcat instance ${name}. An application will not be deployed")
  }

  ::tomcat::service { $name:
    service_name  => $name,
    catalina_home => $catalina_base,
    catalina_base => $catalina_base,
  }

  ::tomcat::config::context { $name:
    catalina_base => $catalina_base,
    require       => ::Tomcat::Instance[$name],
  }

  # Setup context resources
  $tomcat_resources_defaults = {
    catalina_base     => $catalina_base,
    auth              => $default_resource_auth,
    resource_type     => $default_resource_type,
    driver_class_name => $default_resource_driver_class_name,
    max_total         => $default_resource_max_total,
    max_idle          => $default_resource_max_idle,
    max_wait_millis   => $default_resource_max_wait_millis,
    require           => ::Tomcat::Config::Context[$name],
    notify            => ::Tomcat::Service[$name],
  }

  # Obtain tomcat resources to create
  $tomcat_resources = hiera_hash('tomcat_resources', {})

  create_resources('::tomcat::config::context::resource', $tomcat_resources,
  $tomcat_resources_defaults)

  # Add resource links to context file
  $tomcat_resourcelinks = hiera_hash('tomcat_resourcelinks', {})

  create_resources('::tomcat::config::context::resourcelink',
  $tomcat_resourcelinks)

  # Add global resoure to server.xml
  $tomcat_global_resources = hiera_hash('tomcat_global_resources', {})

  create_resources('::tomcat::config::server::globalnamingresources',
  $tomcat_global_resources, $tomcat_resources_defaults)
}
