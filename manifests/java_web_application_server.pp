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

  # Create the default tomcat libraries
  # 
  # Type: maven
  $applications_default = {
    tomcat_libraries => hiera('java_web_application_server::tomcat_libraries')
  }

  # The applications are configured in hiera
  $applications = hiera('profile::java_web_application_server::applications')

  create_resources('java_web_application_server::instance', $applications, $applications_default)
}
