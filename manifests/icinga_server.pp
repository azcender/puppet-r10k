# A wrapper class that installs an icinga server
#
class profile::icinga_server(
  $icinga::db_user = undef,
  $icinga::db_password  = undef,
) {
  # Include base class
  include ::profile

  # Include postgresql classes
  include ::postgresql
  include ::postgresql::server

  include ::icinga2
  include ::icinga2::server
}
