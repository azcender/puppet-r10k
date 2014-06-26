# Profile for a tomcat application instance
# Should be extended to new classes for other app servers
class profile::tomcat {
  $files = hiera('profile::tomcat::file')

  # Create file resources
  create_resources(file, $files)

  include java

  class{ '::tomcat': }

  ::tomcat::instance {'myapp':
    ensure           => present,
    http_port        => '8080',
  }
}
