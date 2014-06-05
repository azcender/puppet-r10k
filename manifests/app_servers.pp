# Profile for a tomcat application instance
# Should be extended to new classes for other app servers
class profiles::app_servers inherits profiles {


  include java

  class { 'tomcat':
    version     => 7,
    sources     => true,
    sources_src => 'http://archive.apache.org/dist/tomcat/',
  }

  tomcat::instance {'myapp':
    ensure    => present,
    http_port => '8080',
  }
}
