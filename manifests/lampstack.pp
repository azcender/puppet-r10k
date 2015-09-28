# Profile for standard LAMP (Linux Apache MySQL PHP) server.

class profile::lampstack(
  $app_name = undef,
  $vhosts = undef,
  $mysql_databases = {},
  $php_apps = {},
) {
  include ::profile
  include ::apache
  include ::apache::mod::php
  include ::mysql::server

  validate_hash($vhosts)
  validate_hash($mysql_databases)

  if $app_name == undef {
    fail('app_name is required for LAMP deployment...')
  }

  # need to ensure app_name exists in /var/www
  file { "/var/www/${app_name}":
    ensure  => directory,
    group   => 'apache',
    owner   => 'apache',
    mode    => 'ug=rx',
    require => Package['httpd'],
  }

  # Set the defaults for vhosts
  $default_vhost_params = {
    port          => 80,
    docroot_owner => 'apache',
    docroot_group => 'apache',
  }

  # Set the defaults for php
  $default_php_params = {
  }

  # Set the defaults for MySQL
  $default_mysql_params = {
  } 

  # Set the defaults for php_apps
  $default_php_apps_params = {
    ensure   => latest,
    owner    => 'apache',
    group    => 'apache',
    provider => git,
    require  => [ Package['git'] ],
  }  

  # vhosts
  create_resources(::apache::vhost, $vhosts, $default_vhost_params)

  # mysql
  create_resources(::mysql::db, $mysql_databases, $default_mysql_params)

  # php_apps
  create_resources(vcsrepo, $php_apps, $default_php_apps_params)

}
