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

  # A standard tomcat instace needs to be instantiated before building separate
  # instances.
  class{ '::tomcat': }

  # The applications are configured in hiera
  $applications = hiera('profile::java_web_application_server::applications')

  create_resources(java_web_application_server, $applications)
}
