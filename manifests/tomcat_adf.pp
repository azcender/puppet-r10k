# Installs a tomcat with the needed ADF files
#
class profile::tomcat_adf (
  $adf_files,
  $catalina_base = '/opt/tomcat',
) {
  include ::profile
  include ::profile::tomcat

  # Ensure adf_files is a hash
  validate_hash($adf_files)

  $wait_command = 'curl --silent --show-error --connect-timeout 1 -I http://localhost:8080'

  # Grab tomcat values from hiera
  $application_name = hiera('profile::tomcat::application_name', undef)

  $groupid          = hiera('profile::tomcat::groupid', undef)
  $artifactid       = hiera('profile::tomcat::artifactid', undef)
  $version          = hiera('profile::tomcat::version', undef)


  # If war name is empty use artifact id
  if $application_name {
    $_war_name = "${application_name}.war"
  }
  else {
    $_war_name = "${artifactid}.war"
  }

  # Wait for tomcat to start before dropping war
  # Only application if coordinates are set
  if($groupid and $artifactid and $version) {
    exec { 'wait for service':
      path      => '/bin',
      command   => $wait_command,
      onlyif    => 'test -z `curl --silent --show-error --connect-timeout 1 -I http://localhost:8080 | grep Coyote | cut -d : -f 2`',
      require   => Service['tomcat-profile::tomcat'],
      tries     => 12,
      try_sleep => 10,
      before    => ::Tomcat::Artifactory["${catalina_base}/webapps/${_war_name}"],
    }
  }


  # Set Oracle cache
  file_line { 'adf_catalina_opts':
    require  => ::Tomcat::Instance['profile::tomcat'],
    notify   => ::Tomcat::Service['profile::tomcat'],
    path     => "${catalina_base}/bin/catalina.sh",
    line     => 'CATALINA_OPTS=-Doracle.mds.cache=simple',
    match    => '^\#   CATALINA_OUT.*',
    multiple => false,
  }


  # Set defaults for the artifactory resources
  $adf_files_defaults = {
    artifactory_host => hiera('artifactory_host'),
    before           => ::Tomcat::Service['profile::tomcat'],
    require          => ::Tomcat::Instance['profile::tomcat'],
  }

  create_resources('::tomcat::artifactory', $adf_files, $adf_files_defaults)
}

