# Lays foundation for Oracle Database
class profile::oracle_database (
) {
  include ::profile

  # Pull the instance variables here for use in templates
  $db_instance = hiera('profile::oracle_database::db_instance')
  $grid_instance = hiera('profile::oracle_database::grid_instance')

  # Add concat fragments
  ::concat::fragment { 'sudoers_oracle_tail' :
    target  =>'/etc/sudoers.d/oracle',
    content => template('profile/oracle/oracle_database_sudoers.erb'),
    order   => '10',
  }
}
