# A wrapper that contains all thr functionality needed for a standard java web
# application.
# Does not support JEE applications
class profile::java_web_application_server inherits profile {

  # Java is needed to run the applications
  # A standard tomcat instace needs to be instantiated before building separate
  # instances
  include ::java
  include ::tomcat

  # The instances to be configured on this node
  $instances = hiera('profile::java_web_application_server::instances')

  create_resources('::java_web_application_server::instance', $instances)
}
