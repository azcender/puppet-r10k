# Installs a tomcat with the needed ADF files
#
class profile::tomcat_adf (
  $adf_files
) {
  include ::profile
  include ::profile::tomcat

  # Ensure adf_files is a hash
  validate_hash($adf_files)

  # Set Oracle cache
  file_lines { 'adf_catalina_opts':
    require  => ::Tomcat::Instance['profile:tomcat'],
    before   => ::Tomcat::Service['profile::tomcat'],
    path     => '/opt/tomcat/bin/catalina.sh',
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

