# A wrapper that contains all thr functionality needed for a standard java web
# application --- does not support JEE applications

class profile::java_web_application_server inherits profile {

  # Java is needed to run the applications
  # A standard tomcat instace needs to be instantiated before building separate
  # instances
  include ::java
  include ::tomcat
  include ::apache

  # Default tomcat home to catalina_home
  $instances_default = {
    instance_basedir => hiera('tomcat::catalina_home'),
    source_url       => hiera('profile:java_web_application_server::source_url'),
  }

  # The instances to be configured on this node
  $instances = hiera('profile::java_web_application_server::instances')

  create_resources('::java_web_application_server::instance', $instances, $instances_default)
}
