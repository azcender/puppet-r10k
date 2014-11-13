# A wrapper that contains all thr functionality needed for a standard java web
# application --- does not support JEE applications

class profile::weblogic {
  include ::profile
  include ::java
  include ::orawls::weblogic
  include ::orautils

  group { 'dba' :
    ensure => present,
  }

  user { 'oracle' :
    ensure     => present,
    groups     => 'dba',
    shell      => '/bin/bash',
    password   => 'password1',
    home       => "/home/oracle",
    comment    => 'Oracle oracle user created by Puppet',
    managehome => true,
    require    => Group['dba'],
  }

  Class['java'] -> Class['orawls::weblogic']
}
