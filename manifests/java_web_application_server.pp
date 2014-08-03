# A wrapper that contains all thr functionality needed for a standard java web
# application.
# Does not support JEE applications
class profile::java_web_application_server {

  # Java is needed to run the applications¬
  include java

  # We use Maven to deploy applications

  # Get any maven repositories we need to search for packaging
  $maven_repos = hiera('profile::java_web_application_server::maven_repos')

  # The maven class requires a version number
  $maven_version = hiera('profile::java_web_application_server::maven_version')

  # Install Maven
  class { "maven::maven":
    version => $maven_version, # version to install
  }

  # A standard tomcat instace needs to be instantiated before building separate
  # instances.
  class{ '::tomcat': }

  # Create the default information needed to create an instance
  #
  # tomcat_libraries (hash):
  #   The shared tomcat libraries needed for these instances
  #
  # applications (hash):
  #   The applications available to these instances. Likely the entire list
  #   of applications hosted by this organization. Only a fraction will likely
  #   be hosted at any given time
  # 
  # Type: maven
  $applications_default = {
    tomcat_libraries       => hiera('profile::java_web_application_server::tomcat_libraries'),
    available_applications => hiera('profile::java_web_application_server::applications'),
  }

  # The instances to be configured on this node
  $instances = hiera('profile::java_web_application_server::instances')

  create_resources('java_web_application_server::instance', $instances, $applications_default)
}
