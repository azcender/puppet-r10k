# Profile for a tomcat application instance
# Should be extended to new classes for other app servers
class profile::tomcat {
  include java

  include tomcat

  tomcat::instance {'myapp':
    ensure    => present,
    http_port => '8080',
  }
}
