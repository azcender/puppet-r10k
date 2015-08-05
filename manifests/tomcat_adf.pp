# Installs a tomcat with the needed ADF files
#
class profile::tomcat_adf (
  $adf_files
) {
  include ::profile
  include ::profile::tomcat

  # Ensure adf_files is a hash
  validate_hash($adf_files)

  # Set defaults for the artifactory resources
  $adf_files_defaults = {
    artifactory_host => hiera('artifactory_host'),
    require          => ::Tomcat::Instance['profile::tomcat'],
  }

  create_resources('::tomcat::artifactory', $adf_files, $adf_files_defaults)
}

