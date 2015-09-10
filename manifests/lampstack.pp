# Profile for standard LAMP (Linux Apache MySQL PHP) server.

class profile::lampstack(
  $vhosts = undef,
  $mysql_databases = undef,
) {
  include ::profile
  include ::apache
  include ::apache::mod::php
  include ::mysql::server

  validate_hash($vhosts)
  validate_hash($mysql_databases)

  # Set the defaults for vhosts
  $default_vhost_params = {
    port => 80,
  }

  # Set the defaults for php
  $default_php_params = {
  }

  # Set the defaults for MySQL
  $default_mysql_params = {
  } 

  # vhosts
  create_resources(::apache::vhost, $vhosts, $default_vhost_params)

  # php
  #create_resources(::php::install, $phps, $default_php_params)

  # mysql
  create_resources(::mysql::db, $mysql_databases, $default_mysql_params)
}
