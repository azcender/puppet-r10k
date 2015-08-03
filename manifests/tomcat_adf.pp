# A wrapper that contains all thr functionality needed for a standard java web
# application --- does not support JEE applications
#
#
class profile::tomcat_adf (
  $adf_artifactory_location
) {
  include ::profile
  include ::profile::tomcat

  create_resources('::archive::artifactory', $adf_artifactory_location)
}
