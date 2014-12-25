# A wrapper that contains all thr functionality needed for a standard java web
# application --- does not support JEE applications
class profile::tomcat_container {
  #  include ::tomcat
  ::tomcat::war { 'sample.war':
    catalina_base => '/usr/local/tomcat',
    war_source    => 'http://artifactory.azcender.com/artifactory/ext-release-local/org/apache/tomcat/sample/1.0.0/sample-1.0.0.war',
  }
}
