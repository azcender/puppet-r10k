class profiles::app_servers inherits profiles {
  class { 'java': }

  include tomcat

  tomcat::instance {'myapp':
    ensure    => present,
    http_port => '8080',
  }
}
