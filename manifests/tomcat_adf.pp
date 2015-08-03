# A wrapper that contains all thr functionality needed for a standard java web
# application --- does not support JEE applications
class profile::tomcat_adf (
  $adf_libraries_source
) {
  include ::profile
  include ::profile::tomcat


  staging::deploy { 'sample.tar.gz':
    source => $adf_libraries_source,
    target => '/opt/tomcat/lib',
  }
}
